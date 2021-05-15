import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/circle_thumb_shape.dart';
import 'package:melofy/generating_melody.dart';
import 'package:melofy/record_audio.dart';
import 'miscellaneous.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' show Uint8List;

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:melofy/circle_thumb_shape.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

// Command to enable microphone in Android emulator
// adb emu avd hostmicon

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

class ViewRecordedAudio extends StatefulWidget {

  final String durationOfRecording;
  final String filePath;

  const ViewRecordedAudio(
      {Key key, this.durationOfRecording, this.filePath}) 
      : super(key: key); 

  @override
  _ViewRecordedAudioState createState() => _ViewRecordedAudioState();
}

class _ViewRecordedAudioState extends State<ViewRecordedAudio> {

  bool useThisAudio = false;
  bool deleteThisAudio = false;

  String _durationOfRecording = "";

  _buildCard({
    Config config,
    Color backgroundColor = Colors.transparent,
    DecorationImage backgroundImage,
    double height = 140,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      child: WaveWidget(
          config: config,
          backgroundColor: backgroundColor,
          backgroundImage: backgroundImage,
          size: Size(double.infinity, double.infinity),
          waveAmplitude: 0,
      ),
    );
  }

  MaskFilter _blur;
  final List<MaskFilter> _blurs = [
    null,
    MaskFilter.blur(BlurStyle.normal, 10.0),
    MaskFilter.blur(BlurStyle.inner, 10.0),
    MaskFilter.blur(BlurStyle.outer, 10.0),
    MaskFilter.blur(BlurStyle.solid, 16.0),
  ];
  int _blurIndex = 0;
  MaskFilter _nextBlur() {
    if (_blurIndex == _blurs.length - 1) {
      _blurIndex = 0;
    } else {
      _blurIndex = _blurIndex + 1;
    }
    _blur = _blurs[_blurIndex];
    return _blurs[_blurIndex];
  }

  bool _showPlayIcon = true;

  StreamSubscription _playerSubscription;
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  String _playerTxt = '00:00';
  String _endPlayerTxt = '00:00';
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media _media = Media.file;
  Codec _codec = Codec.pcm16WAV;
  bool _decoderSupported = true; // Optimist

  // Whether the user wants to use the audio player features
  bool _isAudioPlayer = false;

  double _duration;
  IOSink sink;

  Future<void> _initializeExample(bool withUI) async {
    await playerModule.closeAudioSession();
    _isAudioPlayer = withUI;
    await playerModule.openAudioSession(
        withUI: withUI,
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    // _endPlayerTxt = widget.durationOfRecording;
    // print("_endPlayerTxt: $_endPlayerTxt");
  }

  Future<void> init() async {
    await _initializeExample(false);
  }


  @override
  void initState() {
    super.initState();
    getDuration();
    _endPlayerTxt = _durationOfRecording;
    print("_durationOfRecording: $_endPlayerTxt");
    init();
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    releaseFlauto();
    print("path: ${widget.filePath}");
  }

  Future<void> releaseFlauto() async {
    try {
      await playerModule.closeAudioSession();
    } on Exception {
      print('Released unsuccessful');
    }
  }

  Future<void> getDuration() async {
    var path = widget.filePath;
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

  void _addListeners() async {

    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
      // _endPlayerTxt = e.duration.inMilliseconds;
      if (maxDuration <= 0) maxDuration = 0.0;

      sliderCurrentPosition =
          min(e.position.inMilliseconds.toDouble(), maxDuration);
      if (sliderCurrentPosition < 0.0) {
        sliderCurrentPosition = 0.0;
      }

      var date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds,
          isUtc: true);
      var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _playerTxt = txt.substring(3, 8);
        
        // print("playerTxt: $_playerTxt");
        // print("duration: $_endPlayerTxt");
      });
    });
  }

  Future<Uint8List> _readFileByte(String filePath) async {
    var myUri = Uri.parse(filePath);
    var audioFile = File.fromUri(myUri);
    Uint8List bytes;
    var b = await audioFile.readAsBytes();
    bytes = Uint8List.fromList(b);
    print('reading of bytes is completed');
    return bytes;
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  final int blockSize = 4096;
  Future<void> feedHim(String path) async {
    var buffer = await _readFileByte(path);
    //var buffer = await getAssetData('assets/samples/sample.pcm');

    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !playerModule.isStopped) {
      var bsize = totalLength > blockSize ? blockSize : totalLength;
      await playerModule
          .feedFromStream(buffer.sublist(lnData, lnData + bsize)); // await !!!!
      lnData += bsize;
      totalLength -= bsize;
    }
  }

  Future<void> startPlayer() async {
    try {
      String audioFilePath;
      var codec = _codec;
      audioFilePath = widget.filePath;

      if (audioFilePath != null) {
        print("if (audioFilePath != null)");
          await playerModule.startPlayer(
              fromURI: audioFilePath,
              codec: codec,
              sampleRate: tSTREAMSAMPLERATE,
              whenFinished: () {
                print('Play finished');
                setState(() {});
              });
      } 
      _addListeners();
      setState(() {});
      print('<--- startPlayer');
    } on Exception catch (err) {
      print('error: $err');
    }
  }

  void pauseResumePlayer() async {
    try {
      if (playerModule.isPlaying) {
        await playerModule.pausePlayer();
      } else {
        await playerModule.resumePlayer();
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  Future<void> seekToPlayer(int milliSecs) async {
    //print('-->seekToPlayer');
    try {
      if (playerModule.isPlaying) {
        await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
    //print('<--seekToPlayer');
  }

  void Function() onPauseResumePlayerPressed() {
    if (playerModule.isPaused || playerModule.isPlaying) {
      
      return pauseResumePlayer;
    }
    return null;
  }

  void Function() onStartPlayerPressed() {

    return (playerModule.isStopped) ? startPlayer : null;
  }

  void Function() startPauseResumePlayer() {
    if (playerModule.isPlaying || playerModule.isPaused) {
      return onPauseResumePlayerPressed();
    } else {
      return onStartPlayerPressed();
    }
  }

  AssetImage playerAssetImage() {
    if (onStartPlayerPressed() == null) {
      return AssetImage('assets/player-play-button.png');
    }
    return (playerModule.isPaused)
        ? AssetImage('assets/player-play-button.png')
        : AssetImage('assets/player-pause-button.png');
  }

@override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  child: Stack(
                    children: [
                      Column(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.blockSizeVertical * 25,
                          child: Container(
                              color: ColourConfig().dodgerBlue,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 10),
                                  Text('View Recorded Audio',
                                      textScaleFactor:
                                          SizeConfig.safeBlockVertical * 0.25,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )
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
                                  Container(
                                    height: SizeConfig.blockSizeVertical * 30,
                                    color: ColourConfig().frenchPass,
                                    child: _buildCard(
                                      height: SizeConfig.blockSizeVertical * 20,
                                      backgroundColor: Colors.white,
                                      config: CustomConfig(
                                        colors: [
                                            Color(0xff01579B),
                                            ColourConfig().dodgerBlue,
                                            ColourConfig().frenchPass,
                                            ColourConfig().aliceBlue
                                        ],
                                        durations: [35000, 19440, 10800, 6000],
                                        heightPercentages: [0.18, 0.25, 0.28, 0.30],
                                        blur: _blur,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical * 8),

                                  Container(
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeVertical * 9.4,
                                      right: SizeConfig.blockSizeVertical * 6
                                    ),
                                    height: 30.0,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: ColourConfig().dodgerBlue,
                                        inactiveTrackColor: ColourConfig().frenchPass,
                                        thumbColor: ColourConfig().dodgerBlue,
                                        overlayShape: RoundSliderOverlayShape(overlayRadius: 1),
                                        thumbShape: CircleThumbShape()
                                      ),
                                      child: Slider(
                                        value: min(sliderCurrentPosition, maxDuration),
                                        min: 0.0,
                                        max: maxDuration,
                                        onChanged: (value) async {
                                          await seekToPlayer(value.toInt());
                                        },
                                        divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt())
                                  )),
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeVertical * 8,
                                      right: SizeConfig.blockSizeVertical * 8
                                    ),
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_playerTxt,
                                          textScaleFactor: SizeConfig.blockSizeVertical * 0.16,
                                          style: GoogleFonts.arimo(
                                            color: ColourConfig().dodgerBlue)
                                          ),
                                        Text(
                                          // (widget.durationOfRecording == null) ? _endPlayerTxt : widget.durationOfRecording,
                                          _endPlayerTxt,
                                          textScaleFactor: SizeConfig.blockSizeVertical * 0.16,
                                          style: GoogleFonts.arimo(
                                            color: ColourConfig().dodgerBlue)),
                                      ]
                                    )
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical * 4),

                                  Container(
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeVertical * 8,
                                      right: SizeConfig.blockSizeVertical * 8
                                    ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    ClipOval(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: ColourConfig().aliceBlue,
                                          shape: CircleBorder(),
                                        ),
                                        child: Icon(
                                          Icons.clear_rounded,
                                          size: SizeConfig.blockSizeVertical * 7,
                                          color: ColourConfig().dodgerBlue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            deleteThisAudio = true;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: ColourConfig().aliceBlue, width: 4),
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        iconSize: SizeConfig.blockSizeVertical * 9,
                                        icon: Icon(
                                          (playerModule.isPaused || playerModule.isStopped) ? 
                                          Icons.play_arrow_rounded : Icons.pause_rounded,
                                          color: ColourConfig().dodgerBlue,
                                        ),
                                        onPressed: startPauseResumePlayer(),
                                      ),
                                    ),
                                    ClipOval(
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: ColourConfig().aliceBlue,
                                          shape: CircleBorder(),
                                        ),
                                        child: Icon(
                                          Icons.done_rounded,
                                          size: SizeConfig.blockSizeVertical * 7,
                                          color: ColourConfig().dodgerBlue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            useThisAudio = true;
                                          });
                                        },
                                      ),
                                    ),
                                  ]
                                  )
                                  ),
                                ]  
                          )
                        ), flex: 1),
                      
                      Container(
                        height: SizeConfig.blockSizeVertical * 8,
                          color: ColourConfig().dodgerBlue,
                        ), 
                      
                      
                      ]
                  ),
                    
                      Positioned.fill(
                        child: Align(
                        alignment: Alignment.centerRight,
                        child: useThisAudio ? transparentWidgetUse(context, 
                        "Use Recorded Audio",
                        "Are you sure you want to use the recorded audio?",
                        widget.filePath) : Container(),
                  ),
                ),

                  Positioned.fill(
                        child: Align(
                        alignment: Alignment.centerRight,
                        child: deleteThisAudio ? transparentWidgetDelete(context, 
                        "Delete Recorded Audio",
                        "Are you sure you want to delete the recorded audio?") : Container(),
                  ),
                ),
                    ],
                  ),

        )
    )
        )
    );
  }


  Widget transparentWidgetUse(BuildContext context, String dialogTitle, 
    String dialogInfo, String filePath) {
    
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  width: SizeConfig.screenWidth,
                  color: ColourConfig().frenchPass,
                  child: new CupertinoAlertDialog(
                    title: new Text(dialogTitle),
                    content: new Text(dialogInfo),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Yes"),
                        onPressed: () {
                          // Navigate to Generating Melody screen
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => GeneratingMelody(filePath : filePath)));
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text("No"),
                        onPressed: () {

                          // Navigate to Record Audio screen
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => RecordAudio()));
                        },
                      )
                    ],
                  )
              )
            ),
            
        )
    );
  
}


  Widget transparentWidgetDelete(BuildContext context, String dialogTitle, String dialogInfo) {
    
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  width: SizeConfig.screenWidth,
                  color: ColourConfig().frenchPass,
                  child: new CupertinoAlertDialog(
                    title: new Text(dialogTitle),
                    content: new Text(dialogInfo),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("Yes"),
                        onPressed: () {
                          // TODO: Popup message that says recorded audio has been deleted
                          // TODO: Set timer for the popup message


                          // Navigate to Record Audio screen
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => RecordAudio()));
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text("No"),
                        onPressed: () {
                          setState(() {
                            deleteThisAudio = false;
                        });
                        },
                      )
                    ],
                  )
              )
            ),
            
        )
    );
  
}

}

