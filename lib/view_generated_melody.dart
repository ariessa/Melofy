import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/circle_thumb_shape.dart';
import 'miscellaneous.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:melofy/view_melodies_main.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'app.dart';
import 'package:share_extend/share_extend.dart';


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

class ViewGeneratedMelody extends StatefulWidget {

  final String filePath;
  final String durationOfRecording;
  final String melodyName;
  final bool isFavourite;
  final String melodyId;

  const ViewGeneratedMelody(
      {Key key, this.filePath, this.durationOfRecording, this.melodyName,
      this.isFavourite, this.melodyId}) 
      : super(key: key); 

  @override
  _ViewGeneratedMelodyState createState() => _ViewGeneratedMelodyState();
}

class _ViewGeneratedMelodyState extends State<ViewGeneratedMelody> {

  bool useThisAudio = false;
  bool deleteThisAudio = false;
  bool closeThisMelody = false;
  bool favouriteThisMelody = false;
  bool disableShareButton = false;
  Color shareButtonColour = ColourConfig().dodgerBlue;
  File audioFile;


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

  StreamSubscription _playerSubscription;
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  String _playerTxt = '00:00';
  String _endPlayerTxt = '00:00';
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media _media = Media.file;
  Codec _codec = Codec.pcm16WAV;
  bool _decoderSupported = true; // Optimist
  String _melodyName = "";
  String generatedMelodyID = "";

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
    setState(() {
      _endPlayerTxt = widget.durationOfRecording;
      _melodyName = widget.melodyName;
      favouriteThisMelody = widget.isFavourite;
      generatedMelodyID = widget.melodyId;
      audioFile = File(widget.filePath);
    });

    print("===========> generatedMelodyID: $generatedMelodyID");
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

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress.listen((e) {
      maxDuration = e.duration.inMilliseconds.toDouble();
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

  Future<void> stopPlayer() async {
    try {
      await playerModule.stopPlayer();
      print('stopPlayer');
      if (_playerSubscription != null) {
        await _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
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

    try {
      if (playerModule.isPlaying) {
        await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});

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

  String getCurrentUserName() {
    // Get current user name
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final currentUserName = user.displayName;

    return currentUserName;
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

                        Expanded(
                          child: Container(
                          color: Colors.white,
                          width: SizeConfig.screenWidth,
                              child: Column(
                                children: <Widget> [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        height: SizeConfig.blockSizeVertical * 40,
                                        color: Colors.white,
                                        child: Image.network(
                                              "https://images.unsplash.com/photo-1518173184999-0381b5eb56d7?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
                                              height: SizeConfig.blockSizeVertical * 40,
                                              width: double.infinity,
                                              fit: BoxFit.cover
                                            ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          top: SizeConfig.blockSizeVertical * 1,
                                        ),
                                        child: ClipOval(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: ColourConfig().aliceBlue,
                                            shape: CircleBorder(),
                                          ),
                                          child: Icon(
                                            Icons.clear_rounded,
                                            size: SizeConfig.blockSizeVertical * 4,
                                            color: ColourConfig().dodgerBlue,
                                          ),
                                          onPressed: () {

                                            // Navigate to Record Audio screen
                                            return Navigator.pushReplacement(context, MaterialPageRoute(
                                              builder: (context) => ViewMelodiesMain()));
                                          },
                                        ),
                                      ), 
                                      )                                     
                                    ],
                                  ),

                                  Container(
                                    padding: EdgeInsets.only(
                                      top: SizeConfig.blockSizeVertical * 6,
                                    ),
                                    child: Text(
                                      (_melodyName == null) ? "Melody 1" : _melodyName,
                                      textScaleFactor: SizeConfig.safeBlockVertical * 0.2,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.arimo(
                                        color: ColourConfig().dodgerBlue,
                                        fontWeight: FontWeight.bold)
                                      ),
                                  ),

                                  Container(
                                    padding: EdgeInsets.only(
                                      top: SizeConfig.blockSizeVertical * 1,
                                    ),
                                    child: Text(
                                      getCurrentUserName(),
                                      textScaleFactor: SizeConfig.safeBlockVertical * 0.14,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.arimo(
                                        color: ColourConfig().dodgerBlue)
                                      ),
                                  ),

                                  SizedBox(height: SizeConfig.blockSizeVertical * 6),

                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 0,
                                      left: SizeConfig.blockSizeVertical * 4,
                                      right: SizeConfig.blockSizeVertical * 2
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
                                      left: SizeConfig.blockSizeVertical * 4,
                                      right: SizeConfig.blockSizeVertical * 4
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
                                          // (_endPlayerTxt == null) ? "00:00" : widget.durationOfRecording,
                                          "16:00",
                                          textScaleFactor: SizeConfig.blockSizeVertical * 0.16,
                                          style: GoogleFonts.arimo(
                                            color: ColourConfig().dodgerBlue)),
                                      ]
                                    )
                                  ),
                                  SizedBox(height: SizeConfig.blockSizeVertical * 4),

                                  Container(
                                    padding: EdgeInsets.only(
                                      left: SizeConfig.blockSizeVertical * 4,
                                      right: SizeConfig.blockSizeVertical * 4
                                    ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    ClipOval(
                                      child: TextButton(
                                        child: Icon(
                                          favouriteThisMelody ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          size: SizeConfig.blockSizeVertical * 7,
                                          color: ColourConfig().dodgerBlue,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if(favouriteThisMelody == true){
                                              favouriteThisMelody = false;

                                            } else {
                                              favouriteThisMelody = true;
                                            }
                                            // Update isFavourite
                                              FirebaseFirestore.instance.collection('generatedMelodies')
                                                .doc(generatedMelodyID)
                                                .update({
                                                  'isFavourite': favouriteThisMelody,

                                              });
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
                                        // style: TextButton.styleFrom(
                                        //   backgroundColor: ColourConfig().aliceBlue,
                                        //   shape: CircleBorder(),
                                        // ),
                                        child: Icon(
                                          Icons.share_rounded,
                                          size: SizeConfig.blockSizeVertical * 7,
                                          color: ColourConfig().dodgerBlue,
                                        ),
                                        onPressed: () {
                                          setState(() async {

                                            String madeWith = "\n\n\nMade with ❤️ using the Melofy App.";

                                            File audioFile = new File("${widget.filePath}");
                                            if (!await audioFile.exists()) {
                                              await audioFile.create(recursive: true);
                                              audioFile.writeAsStringSync("test for share documents file");
                                            }
                                            ShareExtend.share(
                                              audioFile.path, 
                                              "audio",
                                              sharePanelTitle: "Share $_melodyName with Your Friends and Family",
                                              subject: "I Created A Melody Using the Melofy App!",
                                              extraText: "Listen to my new melody called $_melodyName." + madeWith
                                              );
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
                        height: SizeConfig.blockSizeVertical * 10,
                        color: Colors.white,
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
                    ]
                  ),
                    
                    ]
                  ),

        )
    )
        )
    );
  }
}

