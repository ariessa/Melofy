import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melofy/generating_melody.dart';
import 'package:melofy/record_audio.dart';
import 'package:melofy/view_recorded_audio.dart';
import 'login.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitUp]);
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: MaterialApp(
            // Start the app with the "/" named route. In this case, the app starts
            // on the FirstScreen widget.
            initialRoute: '/',
            routes: {
              // When navigating to the "/second" route, build the SecondScreen widget.
              // '/deleted': (context) => VisitorDeleted(),
            },
            debugShowCheckedModeBanner: false,
            title: 'Melofy',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: StreamBuilder<auth.User>(
              stream: auth.FirebaseAuth.instance.authStateChanges(),
              builder:
                  (BuildContext context, AsyncSnapshot<auth.User> snapshot) {
                // if (snapshot.hasData) {
                //   print("There is a user logged in");
                //   return RecordAudio();
                // } else {
                //   return LoginPage();
                // }
                return GeneratingMelody();
              },
            )));
  }
}