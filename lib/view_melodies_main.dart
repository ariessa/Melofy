import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:melofy/miscellaneous.dart';
import 'package:melofy/record_audio.dart';
import 'package:melofy/view_melodies_card.dart';
import 'package:melofy/app.dart';

class ViewMelodiesMain extends StatefulWidget {
  @override
  _ViewMelodiesMainState createState() => _ViewMelodiesMainState();
}

class _ViewMelodiesMainState extends State<ViewMelodiesMain> {
  String searchQuery = '';
  bool displayFavouritesOnly = false;
  bool isFiltered = false;

  void initiateSearch(String val) {
    setState(() {
      searchQuery = val.toLowerCase().trim();
    });
  }

    @override
  void initState() {
    setState(() {
      AppState.disableNavbar = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    
    // Get current user id
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final currentUserId = user.uid;

    // Else, navigate to add check in screen
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
            // resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              // leading: GestureDetector(
              //   child: Image.asset('assets/Menu.png'),
              //   onTap: () => Navigator.push(context,
              //       MaterialPageRoute(builder: (context) => HomePage())),
              // ),
              title: Text(
                'MELODIES',
                style: TextStyle(color: Color(0xff2699fb)),
                textScaleFactor: SizeConfig.safeBlockVertical * 0.1,
              ),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.white,
              // actions: <Widget>[

              //   GestureDetector(
              //       child: Icon(Icons.filter_alt_rounded, color: ColourConfig().dodgerBlue,),
              //       onTap: () {

              //         setState(() {

              //         // Navigate to View Favourites screen 
              //         });

                      
              //       }),
              // ],
            ),
            body: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal * 5,
                      right: SizeConfig.blockSizeHorizontal * 5,
                      top: SizeConfig.blockSizeVertical * 2.5,
                      bottom: SizeConfig.blockSizeVertical * 1),
                  height: SizeConfig.blockSizeVertical * 10,
                  width: SizeConfig.screenWidth,
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6.0,
                              offset: Offset(2.0, 5.0))
                        ]),
                    child: TextField(
                      onChanged: (value) => initiateSearch(value),
                      style: TextStyle(color: Color(0xff2699fb)),
                      autofocus: true,
                      cursorColor: Color(0xff2699fb),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              top: SizeConfig.blockSizeVertical * 1,
                              bottom: SizeConfig.blockSizeVertical * 1,
                              left: SizeConfig.blockSizeHorizontal * 5,
                              right: SizeConfig.blockSizeHorizontal * 5),
                          hintText: 'Search for melody name...',
                          hintStyle:
                              TextStyle(color: Color(0xff2699fb), fontSize: 14),
                          border: InputBorder.none),
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                        padding:
                        EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                        color: Colors.white,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                                  .collection('generatedMelodies')
                                  .where("userID",
                                      isEqualTo: currentUserId)
                                  .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return LoadingCircle();
                              default:
                                return new ListView(
                                  children: snapshot.data.docs
                                      .map((DocumentSnapshot document) {
                                    return new MelodyCard(
                                        melodyId: document.id,
                                        melodyName: document['name'],
                                        melodyDay: document['day'],
                                        melodyMonth: document['month'],
                                        melodyYear: document['year'],
                                        melodyHour: document['hour'],
                                        melodyMinute: document['minute'],
                                        isFavourite: document['isFavourite']);
                                  }).toList(),
                                );
                            }
                          },
                        ))),
              ],
            )));
  }
}