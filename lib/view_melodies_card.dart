import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:melofy/miscellaneous.dart';
import 'package:melofy/view_melody.dart';
import 'package:melofy/view_generated_melody.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';

class MelodyCard extends StatelessWidget {
  MelodyCard(
      {@required this.melodyId,
      this.melodyName,
      this.melodyDay,
      this.melodyMonth,
      this.melodyYear,
      this.melodyHour,
      this.melodyMinute,
      this.isFavourite});

  final melodyId;
  final melodyName;
  final melodyDay;
  final melodyMonth;
  final melodyYear;
  final melodyHour;
  final melodyMinute;
  final isFavourite;

  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () async {
            
            print("AppState.disableNavbar: ${AppState.disableNavbar}");

            // Get Melofy's documents directory
            final directory = await getApplicationDocumentsDirectory();
            print(directory.path);

            // Set path to store generatedMelody
            var path = "${directory.path}/$melodyName";
            print("======> path: " + path);

            File downloadToFile = File(path);

            // Download original generatedMelody file from Firebase Cloud Storage
            try {
              await FirebaseStorage.instance
                  .ref(melodyId)
                  .writeToFile(downloadToFile);
            } on FirebaseException catch (e) {
              // e.g, e.code == 'canceled'
            }

            print("====> Downloaded file to Melofy's Temporary Directory");

            // Navigate to View Generated Melody page
            return Navigator.push(context, MaterialPageRoute(
              builder: (context) => ViewGeneratedMelody(
              filePath: path,
              melodyName: melodyName,
              isFavourite: isFavourite,)));

            },   
            child: Container(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      padding: EdgeInsets.only(
                          top: SizeConfig.blockSizeVertical * 1,
                          bottom: SizeConfig.blockSizeVertical * 1,
                          left: SizeConfig.blockSizeHorizontal * 2.5,
                          right: SizeConfig.blockSizeHorizontal * 2.5),
                      child: Image(
                        width: SizeConfig.blockSizeHorizontal * 18,
                        height: SizeConfig.blockSizeVertical * 8,
                        image: AssetImage('assets/music_note-black-18dp.png'),
                      ),
                    ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal * 1,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: SizeConfig.blockSizeHorizontal * 30,
                            padding: EdgeInsets.only(
                                top: SizeConfig.blockSizeVertical * 1,
                                bottom: SizeConfig.blockSizeVertical * 1,
                                left: SizeConfig.blockSizeHorizontal * 2.5,
                                right: SizeConfig.blockSizeHorizontal * 2.5),
                            child: Text(
                              melodyName.toString().toUpperCase(),
                              textAlign: TextAlign.start,
                              textScaleFactor: 0.9,
                              style: TextStyle(
                                color: Color(0xff2699fb),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            width: SizeConfig.blockSizeHorizontal * 30,
                            padding: EdgeInsets.only(
                                top: SizeConfig.blockSizeVertical * 1,
                                bottom: SizeConfig.blockSizeVertical * 1,
                                left: SizeConfig.blockSizeHorizontal * 2.5,
                                right: SizeConfig.blockSizeHorizontal * 2.5),
                            child: Text(
                              melodyDay + " / " + melodyMonth + " / " + melodyYear,
                              textAlign: TextAlign.start,
                              textScaleFactor: 0.9,
                              style: TextStyle(color: Color(0xff2699fb)),
                            ),
                          ),
                          Container(
                            width: SizeConfig.blockSizeHorizontal * 30,
                            padding: EdgeInsets.only(
                                top: SizeConfig.blockSizeVertical * 1,
                                bottom: SizeConfig.blockSizeVertical * 1,
                                left: SizeConfig.blockSizeHorizontal * 2.5,
                                right: SizeConfig.blockSizeHorizontal * 2.5),
                            child: Text(
                              melodyHour + " : " + melodyMinute + " HRS",
                              textAlign: TextAlign.start,
                              textScaleFactor: 0.9,
                              style: TextStyle(color: Color(0xff2699fb)),
                            ),
                          ),
                        ]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: SizeConfig.blockSizeHorizontal * 30,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical * 1,
                              bottom: SizeConfig.blockSizeVertical * 1,
                              left: SizeConfig.blockSizeHorizontal * 2.5,
                              right: SizeConfig.blockSizeHorizontal * 2.5),
                          child: Text("MELODY NAME",
                              textAlign: TextAlign.end,
                              textScaleFactor: 0.9,
                              style: TextStyle(
                                  color: Color(0xffbce0fd),
                                  fontWeight: FontWeight.bold)),
                        ),

                        Container(
                          width: SizeConfig.blockSizeHorizontal * 20,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical * 1,
                              bottom: SizeConfig.blockSizeVertical * 1,
                              left: SizeConfig.blockSizeHorizontal * 2.5,
                              right: SizeConfig.blockSizeHorizontal * 2.5),
                          child: Text(
                            "DATE",
                            textScaleFactor: 0.9,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Color(0xffbce0fd),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal * 20,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical * 1,
                              bottom: SizeConfig.blockSizeVertical * 1,
                              left: SizeConfig.blockSizeHorizontal * 2.5,
                              right: SizeConfig.blockSizeHorizontal * 2.5),
                          child: Text(
                            "TIME",
                            textScaleFactor: 0.9,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Color(0xffbce0fd),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ))));
  }
}