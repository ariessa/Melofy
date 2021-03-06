import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/app.dart';
import 'package:melofy/login.dart';
import 'package:melofy/main.dart';
import 'package:melofy/miscellaneous.dart'
    show SizeConfig, ColourConfig;


enum ConfirmAction { CANCEL, CONFIRM }

class LogoutPage extends StatefulWidget {
  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(

            appBar: AppBar(
              title: Text(
                'LOG OUT',
                style: GoogleFonts.arimo(
                  color: ColourConfig().dodgerBlue,
                  fontWeight: FontWeight.bold,
                ),
                textScaleFactor: SizeConfig.safeBlockVertical * 0.1,
              ),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.white,

            ),
            body: SingleChildScrollView(
              child: Container(
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.screenHeight,
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                  height: SizeConfig.blockSizeVertical * 10),
                                  Image(
                                    image: AssetImage("assets/log-out-illustration.png")
                                  ),
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 2
                                  ),
                                  Text('Do you still want to log out?',
                                      textScaleFactor:
                                          SizeConfig.safeBlockVertical * 0.14,
                                      style: GoogleFonts.arimo(
                                        color: ColourConfig().frenchPass  
                                      )
                                  ),
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 8
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.only(
                                          top: SizeConfig.blockSizeVertical * 2.5,
                                          bottom: SizeConfig.blockSizeVertical * 2.5),
                                      margin: EdgeInsets.only(
                                          left: SizeConfig.blockSizeHorizontal * 10,
                                          right: SizeConfig.blockSizeHorizontal * 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(0)),
                                          color: ColourConfig().dodgerBlue),
                                      child: Text("Yes, log me out please",
                                          textAlign: TextAlign.center,
                                          textScaleFactor:
                                              SizeConfig.safeBlockVertical * 0.14,
                                          style: GoogleFonts.arimo(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                    onTap: () async {
                                      await auth.FirebaseAuth.instance.signOut();
                                      Navigator.of(context, rootNavigator: true)
                                        .pushReplacement(MaterialPageRoute(
                                          builder: (context) => new MyApp()));

                                      // Every time log in after log out, go to Melodies screen
                                      AppState.currentTab = 0;
                                    },
                                  )
                                ]
                              )
              )

                        

        )
        
        )
        
        );
    
  }
  
}