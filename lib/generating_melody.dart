import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/util/flutter_sound_helper.dart';
import 'package:melofy/view_generated_melody.dart';
import 'miscellaneous.dart';
import 'package:azblob/azblob.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:english_words/english_words.dart';

class GeneratingMelody extends StatefulWidget {

  final String filePath;

  const GeneratingMelody(
      {Key key, this.filePath}) 
      : super(key: key); 

  @override
  _GeneratingMelodyState createState() => _GeneratingMelodyState();
}

class _GeneratingMelodyState extends State<GeneratingMelody> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  String path = "";
  IOSink sink;
  double _duration;
  String _durationOfRecording = '';
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;


@override
void initState() {
  super.initState();
  _animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 10),
  );

  _animationController.addListener(() => setState(() {}));
  _animationController.repeat();

  // Upload recorded audio file to Azure's Blob Storage Container
  // Generate melody using Melofy API and get generated melody file link
  // Download generated melody from Azure's Blob Storage Container
  uploadRecordedAudioFileToAzure(context);

}

@override
void dispose() {
  _animationController.dispose();

  super.dispose();
}

Future<void> deleteAudioFileInCloudStorage(String fileUrl) async {

    var audioFile = firebaseStorage.refFromURL(fileUrl);
    await audioFile.delete();
}

Future uploadRecordedAudioFileToAzure(BuildContext context) async {

  var status = await Permission.storage.request();
  String generatedMelodyLink = "";
  if (status == PermissionStatus.granted) {

    // Get current date and time
    var now = DateTime.now();

    // Extract only date and time from variable now
    var dateTime = DateFormat('y-MM-dd-HH-mm-ss-').format(now);

    // Get current user id
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final currentUserId = user.uid;

    // Generate file name with date, time, and username
    String fileName = dateTime + currentUserId + ".wav";
    print("======> Filename: $fileName");

    // Name of Azure's Blob Service Container
    String container="melofy-api-input";

    // Azure's connection string
    String connectionString = 'DefaultEndpointsProtocol=https;AccountName=melofyapi;AccountKey=ucqmEO03FyTs7/z9JS7pQkA7bIai7O0ycBs09Iataco8xk3BcxRDNmy5+NqYLqYjiMxTP8ZRRsaHFT4HRvn0Dw==;EndpointSuffix=core.windows.net';
    
    // Location to put blob in Azure's Blob Service Container
    String blobLocation = "/$container/$fileName";

    try{
          File file = new File(widget.filePath);
            // read file as Uint8List 
            Uint8List content =  await file.readAsBytes();
            var storage = AzureStorage.parse(connectionString);

            // get the mine type of the file
            String contentType= lookupMimeType(widget.filePath);

            // Upload blob to specified location
            await storage.putBlob(
              blobLocation, 
              bodyBytes: content, 
              contentType: contentType,
              type: BlobType.BlockBlob
            );
            print("======> Audio File has been uploaded to Azure's Blob Service Container");

            // Send POST request to Melofy API to generate melody
            final response = await post(
              Uri.https('melofyapi.ap.ngrok.io', 'generate'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'audio_file_link': 'https://melofyapi.blob.core.windows.net/$container/$fileName',
              }),
            );

            print("======> Audio File has been uploaded to Azure's Blob Service Container");
            if (response.statusCode == 200) {
              // If the server did return a 200 OK response,
              // then parse the JSON.
              // Get generated melody link
              generatedMelodyLink = response.body;
              print("======> generatedMelodyLink: " + generatedMelodyLink);
              // print(jsonDecode(response.body));
            } else {
              // If the server did not return a 200 OK response,
              // then throw an exception.
              throw Exception('Failed to generate melody');
            }

            // Remove everything before the last /
            String generatedMelodyName = generatedMelodyLink.substring(generatedMelodyLink.lastIndexOf("/")+1);
            String generatedMelodyNameOnly = generatedMelodyName.trim();
            print("======> generatedMelodyNameOnly: " + generatedMelodyNameOnly);

            // Generate random name for melody
            WordPair _wordPair = WordPair.random();

            // Set new melody name
            String melodyName = _wordPair.asPascalCase;
            print("======> melodyName: $melodyName");

            // Remove everything before first -
            String generatedMelodyID = generatedMelodyLink.substring(generatedMelodyLink.indexOf("-")+1);
            generatedMelodyID = generatedMelodyID.trim();
            generatedMelodyID = generatedMelodyID.substring(0, generatedMelodyID.indexOf("."));
            generatedMelodyID = melodyName + "-" + generatedMelodyID;
            print("======> generatedMelodyID: " + generatedMelodyID);

            // Remove everything before first -
            // This is done to remove gm-
            // Example:
            // Original => gm-2021-05-14-03-26-39-wXHW9yuQ89QgW7C0z6sTlwJXKU63.wav  
            // Result => 2021-05-14-03-26-39-wXHW9yuQ89QgW7C0z6sTlwJXKU63.wav
            String generatedMelodyDate = generatedMelodyLink.substring(generatedMelodyLink.indexOf("-")+1);
            generatedMelodyDate = generatedMelodyDate.trim();

            // Remove everything after .
            // This is done to remove file extension (.wav)
            // Example:
            // Original: 2021-05-14-03-26-39-wXHW9yuQ89QgW7C0z6sTlwJXKU63.wav
            // Result: 2021-05-14-03-26-39-wXHW9yuQ89QgW7C0z6sTlwJXKU63
            generatedMelodyDate = generatedMelodyDate.substring(0, generatedMelodyDate.indexOf("."));

            // Get year from original file name
            String generatedMelodyYear = generatedMelodyDate.substring(0, 4);
            String generatedMelodyMonth = generatedMelodyDate.substring(5, 7);
            String generatedMelodyDay = generatedMelodyDate.substring(8, 10);
            String generatedMelodyHour = generatedMelodyDate.substring(11, 13);
            String generatedMelodyMinute = generatedMelodyDate.substring(14, 16);

            print("generatedMelodyYear: $generatedMelodyYear");            
            print("generatedMelodyMonth: $generatedMelodyMonth");  
            print("generatedMelodyDay: $generatedMelodyDay");  
            print("generatedMelodyHour: $generatedMelodyHour");  
            print("generatedMelodyMinute: $generatedMelodyMinute");  

            // Get Melofy's documents directory
            final directory = await getTemporaryDirectory();
            print(directory.path);

            // Set path to store generatedMelody
            path = "${directory.path}/$melodyName";
            print("======> path: " + path);

            File downloadToFile = File(path);

            // Download original generatedMelody file from Firebase Cloud Storage
            try {
              await FirebaseStorage.instance
                  .ref("$generatedMelodyNameOnly")
                  .writeToFile(downloadToFile);
            } on FirebaseException catch (e) {
              // ignore: unnecessary_statements
              e.code == 'Failed to download file';
            }

            print("======> Downloaded generatedMelody");

            String link = "https://firebasestorage.googleapis.com/v0/b/melofy-1b47c.appspot.com/o/" + generatedMelodyLink + "??alt=media&token=c18db385-9cc3-41e8-a860-73a05a5e4ec2";
            print("=======> Link: $link");
            
            // Delete original generatedMelody file in Firebase Cloud Storage
            deleteAudioFileInCloudStorage(link);

            File file6 = File(downloadToFile.path);

            // Create a Reference to the file
            Reference ref = FirebaseStorage.instance
                .ref()
                .child('/$generatedMelodyID');

            final metadata = SettableMetadata(
                contentType: 'audio/wav');

            // Upload file to Firebase Cloud Storage
            ref.putData(await file6.readAsBytes(), metadata);
            print("======> Uploaded melody to Cloud Storage"); 

            // Added generatedMelody to generatedMelodies/$currentUserId
            FirebaseFirestore.instance.collection('generatedMelodies')
              .doc(generatedMelodyID)
              .set({
                'name': melodyName,
                'userID': currentUserId,
                'day': generatedMelodyDay,
                'month': generatedMelodyMonth,
                'year': generatedMelodyYear,
                'hour': generatedMelodyHour,
                'minute': generatedMelodyMinute,
                'isFavourite': 0
            });

            getDuration(path);

            // Navigate to Play Recorded Audio page
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => ViewGeneratedMelody(
              filePath: path,
              durationOfRecording: _durationOfRecording,
              melodyName: _wordPair.asPascalCase,
              isFavourite: 0,
              melodyId: generatedMelodyID,
              isCloseButtonVisible: true)));

          } on AzureStorageException catch(ex){
            print(ex.message);
          } catch(err){
            print(err);
          }
    }
  }

  Future<void> getDuration(String path) async {
    // var path = widget.filePath;
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


@override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  height: SizeConfig.screenHeight,
                  child: Center(
                    child: SizedBox(
                      width: SizeConfig.blockSizeVertical * 35,
                      height: SizeConfig.blockSizeVertical * 35,
                      child: LiquidCircularProgressIndicator(
                        value: _animationController.value,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(ColourConfig().dodgerBlue),
                        borderColor: ColourConfig().frenchPass,
                        borderWidth: 10.0,
                        center: Text(
                          // "${percentage.toStringAsFixed(0)}%",
                          "Generating Melody...",
                          style: TextStyle(
                            color: Color(0xffBCE0FD),
                            fontSize: SizeConfig.safeBlockVertical * 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
              )
            ),
            
        )
    );
  }
}