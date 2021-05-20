import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/miscellaneous.dart';
import 'package:melofy/view_melodies_card.dart';

class ViewMelodiesMain extends StatefulWidget {
  ViewMelodiesMain({Key key}) : super(key: key);

  @override
  _ViewMelodiesMainState createState() => _ViewMelodiesMainState();
}

class _ViewMelodiesMainState extends State<ViewMelodiesMain> {

  String searchQuery = '';
  int displayFavouritesOnly = 0;
  bool isFiltered = false;

  void initiateSearch(String val) {
    setState(() {
      searchQuery = val.toLowerCase().trim();
    });
  }

    @override
  void initState() {
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
            appBar: AppBar(
              title: Text(
                'MELODIES',
                style: GoogleFonts.arimo(
                  color: ColourConfig().dodgerBlue,
                  fontWeight: FontWeight.bold
                ),
                textScaleFactor: SizeConfig.safeBlockVertical * 0.1,
              ),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.white,
              actions: <Widget>[
                GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                      child:Icon(
                        isFiltered ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                        color: ColourConfig().dodgerBlue
                      ),
                    ),

                    onTap: () {
                      setState(() {
                        if (displayFavouritesOnly == 0){
                          displayFavouritesOnly = 1;
                          isFiltered = true;
                          final snackBar = SnackBar(
                          content: Text('Showing Favourite Melodies Only'),
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        else {
                          displayFavouritesOnly = 0;
                          isFiltered = false;

                          final snackBar = SnackBar(
                          content: Text('Showing All Melodies'),
                          action: SnackBarAction(
                            label: 'Close',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      });

                    }),
              ],
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
                                  .orderBy("isFavourite")
                                  .where("userID",
                                      isEqualTo: currentUserId)
                                  .where("isFavourite",
                                      isGreaterThanOrEqualTo: displayFavouritesOnly)
                                  .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                              return new Column(
                                children: [
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 12
                                  ),
                                  Image(
                                    image: AssetImage("assets/undraw_compose_music_ovo2.png")),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2
                                  ),
                                  Text("Once you've generated a new melody,\nyou'll see it listed here",
                                      textScaleFactor:
                                          SizeConfig.safeBlockVertical * 0.14,
                                      style: GoogleFonts.arimo(
                                        color: ColourConfig().frenchPass,
                                        height: 1.5
                                      ),
                                      textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }

                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return LoadingCircle(); 

                                default: return new ListView(
                                  children: snapshot.data.docs
                                      .map((DocumentSnapshot document) {
                                    return new Dismissible(
                                      key: UniqueKey(), 
                                      onDismissed: (DismissDirection direction) {

                                          FirebaseFirestore.instance
                                            .collection('generatedMelodies')
                                            .doc(document.id)
                                            .delete()
                                            .then((value) => print("=====> Deleted generated melody" + document['name'].toString()));

                                      },
                                      secondaryBackground: Container(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: SizeConfig.blockSizeVertical * 4,
                                          ),
                                          child: Icon(
                                              Icons.delete_rounded,
                                              color: Colors.white,
                                              size: SizeConfig.blockSizeVertical * 5,
                                          ),
                                        ),
                                        
                                        color: Colors.red,
                                      ),
                                      background: Container(),
                                      direction: DismissDirection.endToStart,
                                      child: MelodyCard(
                                        melodyId: document.id,
                                        melodyName: document['name'],
                                        melodyDay: document['day'],
                                        melodyMonth: document['month'],
                                        melodyYear: document['year'],
                                        melodyHour: document['hour'],
                                        melodyMinute: document['minute'],
                                        isFavourite: document['isFavourite'])
                                      );

                                  }).toList(),
                                );
                            }
                          },
                        ))),
              ],
            )
            )
            );

  }
}