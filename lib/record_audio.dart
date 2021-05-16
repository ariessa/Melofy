import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melofy/view_recorded_audio.dart';
import 'miscellaneous.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;

///
const int tSAMPLERATE = 8000;

/// Sample rate used for Streams
const int tSTREAMSAMPLERATE = 44000; // 44100 does not work for recorder on iOS

///
const int tBLOCKSIZE = 4096;

///
enum Media {
  ///
  file,

  ///
  buffer,

  ///
  asset,

  ///
  stream,

  ///
  remoteExampleFile,
}

///
enum AudioState {
  ///
  isPlaying,

  ///
  isPaused,

  ///
  isStopped,

  ///
  isRecording,

  ///
  isRecordingPaused,
}

class RecordAudio extends StatefulWidget {

  @override
  _RecordAudioState createState() => _RecordAudioState();
}

class _RecordAudioState extends State<RecordAudio> {

  bool _isRecording = false;

  // Data to pass to ViewRecordedAudio file
  String _path = "";
  String _durationOfRecording = '';

  StreamSubscription _recorderSubscription;
  StreamSubscription _recordingDataSubscription;

  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();

  String _recorderTxt = '00:00';
  double _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media _media = Media.file;
  Codec _codec = Codec.pcm16WAV;

  bool _encoderSupported = true; // Optimist

  // Whether the user wants to use the audio player features
  bool _isAudioPlayer = false;

  double _duration;
  StreamController<Food> recordingDataController;
  IOSink sink;

  // -------------------------------- Start here ----------------------------------- //
    Future<void> _initializeExample(bool withUI) async {
    await recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
  }

  Future<void> init() async {
    await recorderModule.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _initializeExample(false);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }

  void cancelRecordingDataSubscription() {
    if (_recordingDataSubscription != null) {
      _recordingDataSubscription.cancel();
      _recordingDataSubscription = null;
    }
    recordingDataController = null;
    if (sink != null) {
      sink.close();
      sink = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelRecorderSubscriptions();
    cancelRecordingDataSubscription();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {
      await recorderModule.closeAudioSession();
    } on Exception {
      print('Released unsuccessful');
    }
  }

  void startRecorder() async {
    try {
      // Request Microphone permission if needed
      // Move this after log in
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException(
              'Microphone permission not granted');
        }
      }
      var path = '';
      if (!kIsWeb) {
        var tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/flutter_sound.wav';
      } else {
        path = '_flutter_sound.wav';
      }

      if (_media == Media.stream) {
        assert(_codec == Codec.pcm16);
        if (!kIsWeb) {
          var outputFile = File(path);
          if (outputFile.existsSync()) {
            await outputFile.delete();
          }
          sink = outputFile.openWrite();
        } else {
          sink = null; // TODO
        }
        recordingDataController = StreamController<Food>();
        _recordingDataSubscription =
            recordingDataController.stream.listen((buffer) {
          if (buffer is FoodData) {
            sink.add(buffer.data);
          }
        });
        await recorderModule.startRecorder(
          toStream: recordingDataController.sink,
          codec: _codec,
          numChannels: 1,
          sampleRate: tSTREAMSAMPLERATE, //tSAMPLERATE,
        );
      } else {
        await recorderModule.startRecorder(
          toFile: path,
          codec: _codec,
          bitRate: 8000,
          numChannels: 1,
          sampleRate: (_codec == Codec.pcm16) ? tSTREAMSAMPLERATE : tSAMPLERATE,
        );
      }
      print('startRecorder');

      _recorderSubscription = recorderModule.onProgress.listen((e) {
        var date = DateTime.fromMillisecondsSinceEpoch(
            e.duration.inMilliseconds,
            isUtc: true);
        var txt = DateFormat('mm:ss:SS').format(date);

        setState(() {
          String _test = txt.substring(3,8);
          print("_test: $_test");
          print("recorderTxt: $_recorderTxt");
          _recorderTxt = txt.substring(3, 8);
          _dbLevel = e.decibels;
        });
      });

      setState(() {
        // AppState.isRecording = true;
        _isRecording = true;
        _path = path;
      });
    } on Exception catch (err) {
      print('startRecorder error: $err');
      setState(() {
        stopRecorder();
        // AppState.isRecording = false;
        _isRecording = false;
        cancelRecordingDataSubscription();
        cancelRecorderSubscriptions();
      });
    }
  }

  Future<void> getDuration() async {
    var path = _path;
    var d = path != null ? await flutterSoundHelper.duration(path) : null;
    _duration = d != null ? d.inMilliseconds / 1000.0 : null;
    _durationOfRecording = _duration.toString();

    // Round up to 2 decimal points and convert to string
    _durationOfRecording = _duration.toStringAsFixed(2);
    print("_durationOfRecording: $_durationOfRecording");

    // Replace . with :
    _durationOfRecording = _durationOfRecording.replaceAll('.', ':');
    print("_durationOfRecording: $_durationOfRecording");

    // If duration of recorded audio is less than 10 seconds
    // Add 0 before first character in string
    // Example ||  7.085375 => 07:09  ||
    if (_duration < 10) {
      _durationOfRecording = "0" + _durationOfRecording;
      print("_durationOfRecording: $_durationOfRecording");
    }

    print("_duration: $_duration");
    print("durationOfRecording: $_durationOfRecording");
  }

  void stopRecorder() async {
    try {
      await recorderModule.stopRecorder();
      print('stopRecorder');
      cancelRecorderSubscriptions();
      cancelRecordingDataSubscription();
      await getDuration();
    } on Exception catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      var file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      print('The file is ${contents.length} bytes long.');
      return contents;
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  void startStopRecorder() {
    if (recorderModule.isRecording || recorderModule.isPaused) {
      stopRecorder();
      // TODO: Add loading animation
      // 
      // Navigate to view recorded audio screen
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ViewRecordedAudio(
          durationOfRecording: _durationOfRecording,
          filePath: _path)));
    } else {
      startRecorder();
    }
  }

  void Function() onStartRecorderPressed() {
    if (!_encoderSupported) return null;
    if (_media == Media.stream && _codec != Codec.pcm16) return null;
    return startStopRecorder;
  }

  AssetImage recorderAssetImage() {
    if (onStartRecorderPressed() == null) {
      // return AssetImage('assets/record-audio-button.png');
      return AssetImage('assets/Group-record.png');
    }
    return (recorderModule.isStopped)
        // ? AssetImage('assets/record-audio-button.png')
        // : AssetImage('assets/record-stop-button.png');
        ? AssetImage('assets/Group-record.png')
        : AssetImage('assets/Group-stop.png');
  }

  // ------------------------ Stop here -------------------------- //

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // If not recording, don't hide bottom navbar
    // if (_isRecording == false) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  child: Column(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.blockSizeVertical * 48,
                          child: Container(
                              color: ColourConfig().dodgerBlue,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                  height: SizeConfig.blockSizeVertical * 10),
                                  Text(_isRecording
                                      ? 'Recording...'
                                      : 'Record Audio',
                                      textScaleFactor:
                                          SizeConfig.safeBlockVertical * 0.25,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )
                                  ),
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 12
                                  ),
                                    ClipOval(
                                      child: TextButton(
                                        onPressed: onStartRecorderPressed(),
                                        child: Image(
                                          image: recorderAssetImage(),
                                          // width: SizeConfig.blockSizeVertical * 30,
                                          // height: SizeConfig.blockSizeVertical * 14
                                        ),
                                      ),
                                    ),
                                ]
                              )
                          )
                        ),

                        Expanded(
                          child: Container(
                          color: Colors.white,
                          width: SizeConfig.screenWidth,
                              child: Column(
                                children: <Widget> [
                                  SizedBox(height: SizeConfig.blockSizeVertical * 15),
                                  Text(_recorderTxt,
                                      textAlign: TextAlign.center,
                                      textScaleFactor: SizeConfig.safeBlockVertical * 1,
                                      style: TextStyle(
                                        color: ColourConfig().dodgerBlue,
                                      )
                                  ),
                                ]  
                          )
                        ), flex: 1),
                      
                      _isRecording
                          ? LinearProgressIndicator(
                              value: 100.0 / 160.0 * (_dbLevel ?? 1) / 100,
                              minHeight: SizeConfig.blockSizeVertical * 6,
                              valueColor: AlwaysStoppedAnimation<Color>(ColourConfig().dodgerBlue),
                              backgroundColor: ColourConfig().frenchPass)
                          : Container(),

                      ]
                  )
              )
            ),
            
            //   bottomNavigationBar: BottomNavigationBar(
            //   items: <BottomNavigationBarItem>[
            //     BottomNavigationBarItem(
            //       icon: Padding(
            //         padding: EdgeInsets.only(bottom: 4),
            //         child: Icon(Icons.graphic_eq_rounded, color: ColourConfig().dodgerBlue),
            //       ),
            //       label: 'Record',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Padding(
            //         padding: EdgeInsets.only(bottom: 4),
            //         child: Icon(Icons.music_note, color: ColourConfig().dodgerBlue),
            //       ),
                  
            //       label: 'Melody',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Padding(
            //         padding: EdgeInsets.only(bottom: 4),
            //         child: Icon(Icons.favorite_border_rounded, color: ColourConfig().dodgerBlue),
            //       ),
                  
            //       label: 'Favourites',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Padding(
            //         padding: EdgeInsets.only(bottom: 4),
            //         child: Icon(Icons.school_rounded, color: ColourConfig().dodgerBlue),
            //       ),
                  
            //       label: 'Tutorials',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Padding(
            //         padding: EdgeInsets.only(bottom: 4),
            //         child: Icon(Icons.logout, color: ColourConfig().dodgerBlue),
            //       ),
                  
            //       label: 'Log Out',
            //     ),
            //   ],
            //   currentIndex: _selectedIndex,
            //   selectedItemColor: ColourConfig().dodgerBlue,
            //   onTap: _onItemTapped,
            //   showSelectedLabels: true,
            //   showUnselectedLabels: false,

            // ),
        
        
        )
    );
    // }
    
    // // Else if recording, hide bottom navbar
    // else {
    //   return WillPopScope(
    //     onWillPop: () => Future.value(false),
    //     child: Scaffold(
    //         body: SingleChildScrollView(
    //           child: Container(
    //               height: SizeConfig.screenHeight,
    //               child: Column(
    //                   children: <Widget>[
    //                     Container(
    //                       width: SizeConfig.screenWidth,
    //                       height: SizeConfig.blockSizeVertical * 48,
    //                       child: Container(
    //                           color: ColourConfig().dodgerBlue,
    //                           child: Column(
    //                             children: <Widget>[
    //                               SizedBox(
    //                                   height: SizeConfig.blockSizeVertical * 10),
    //                               Text(_isRecording
    //                                   ? 'Recording...'
    //                                   : 'Record Audio',
    //                                   textScaleFactor:
    //                                       SizeConfig.safeBlockVertical * 0.25,
    //                                   style: TextStyle(
    //                                     color: Colors.white,
    //                                     fontWeight: FontWeight.bold,
    //                                   )
    //                               ),
    //                               SizedBox(
    //                                   height: SizeConfig.blockSizeVertical * 12
    //                               ),
    //                                 ClipOval(
    //                                   child: TextButton(
    //                                     onPressed: onStartRecorderPressed(),
    //                                     //padding: EdgeInsets.all(8.0),
    //                                     child: Image(
    //                                       image: recorderAssetImage(),
    //                                       width: SizeConfig.blockSizeVertical * 30,
    //                                       height: SizeConfig.blockSizeVertical * 14
    //                                     ),
    //                                   ),
    //                                 ),
    //                             ]
    //                           )
    //                       )
    //                     ),

    //                     Expanded(
    //                       child: Container(
    //                       color: Colors.white,
    //                       width: SizeConfig.screenWidth,
    //                           child: Column(
    //                             children: <Widget> [
    //                               SizedBox(height: SizeConfig.blockSizeVertical * 15),
    //                               Text(_recorderTxt,
    //                                   textAlign: TextAlign.center,
    //                                   textScaleFactor: SizeConfig.safeBlockVertical * 1,
    //                                   style: TextStyle(
    //                                     color: ColourConfig().dodgerBlue,
    //                                   )
    //                               ),
    //                             ]  
    //                       )
    //                     ), flex: 1),

    //                     _isRecording
    //                       ? LinearProgressIndicator(
    //                           value: 100.0 / 160.0 * (_dbLevel ?? 1) / 100,
    //                           minHeight: SizeConfig.blockSizeVertical * 6,
    //                           valueColor: AlwaysStoppedAnimation<Color>(ColourConfig().dodgerBlue),
    //                           backgroundColor: ColourConfig().frenchPass)
    //                       : Container(),

    //                   ]
    //               )
    //           )
    //         )
    //     )
    //   );
    // }
    
  }
}