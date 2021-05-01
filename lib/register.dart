import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/login.dart';
import 'package:melofy/miscellaneous.dart'
    show EmailValidator, SizeConfig, ColourConfig;
import 'package:melofy/record_audio.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _email;
  String _password;
  String _gender = "Male";


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          body: SingleChildScrollView(
              child: Container(
                height: SizeConfig.screenHeight,
                child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                  Column(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.screenWidth,
                          child: Container(
                              //constraints: BoxConstraints.expand(),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                      height: SizeConfig.blockSizeVertical * 10),
                                  Text('Create an Account',
                                      textScaleFactor:
                                          SizeConfig.safeBlockVertical * 0.25,
                                      style: GoogleFonts.arimo(
                                        color: ColourConfig().dodgerBlue,
                                        fontWeight: FontWeight.bold
                                      ))
                                ],
                              )),
                        ),
                      ],
                    ),
                    Column(children: <Widget>[
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeHorizontal * 10,
                              left: SizeConfig.blockSizeHorizontal * 10,
                              right: SizeConfig.blockSizeHorizontal * 10),
                          child: Text('Name',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.arimo(
                                  color: ColourConfig().dodgerBlue))),
                      Container(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeHorizontal * 2,
                            left: SizeConfig.blockSizeHorizontal * 10,
                            right: SizeConfig.blockSizeHorizontal * 10),
                        child: TextFormField(
                            style: GoogleFonts.arimo(
                                color: ColourConfig().dodgerBlue),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Name cannot be empty';
                              }
                              return null;
                            },
                            onSaved: (value) => _name = value,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              // labelText: "Name",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0),
                                borderSide: new BorderSide(
                                    color: ColourConfig().dodgerBlue),
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0),
                                borderSide: new BorderSide(
                                    color: ColourConfig().frenchPass),
                              ),
                            )),
                      ),
                      SizedBox(height: SizeConfig.blockSizeHorizontal * 3),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeHorizontal * 2,
                              left: SizeConfig.blockSizeHorizontal * 10,
                              right: SizeConfig.blockSizeHorizontal * 10),
                          child: Text('Email',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.arimo(
                                  color: ColourConfig().dodgerBlue))),
                      Container(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeHorizontal * 2,
                            left: SizeConfig.blockSizeHorizontal * 10,
                            right: SizeConfig.blockSizeHorizontal * 10),
                        child: TextFormField(
                            style: GoogleFonts.arimo(
                                color: ColourConfig().dodgerBlue),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Email address cannot be empty';
                              }
                              if (!value.isValidEmail()) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              // labelText: "Email Address",
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0),
                                borderSide: new BorderSide(
                                    color: ColourConfig().dodgerBlue),
                              ),
                              enabledBorder: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0),
                                borderSide: new BorderSide(
                                    color: ColourConfig().frenchPass),
                              ),
                            )),
                      ),
                      SizedBox(height: SizeConfig.blockSizeHorizontal * 3),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeHorizontal * 2,
                              left: SizeConfig.blockSizeHorizontal * 10,
                              right: SizeConfig.blockSizeHorizontal * 10),
                          child: Text('Password',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.arimo(
                                  color: ColourConfig().dodgerBlue))),
                      Container(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeHorizontal * 2,
                            left: SizeConfig.blockSizeHorizontal * 10,
                            right: SizeConfig.blockSizeHorizontal * 10),
                        child: TextFormField(
                            style: GoogleFonts.arimo(
                                color: ColourConfig().dodgerBlue),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Password cannot be empty';
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value,
                            obscureText: true,
                            decoration: InputDecoration(
                                // labelText: "Password",
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(0),
                                  borderSide: new BorderSide(),
                                ),
                                enabledBorder: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(0),
                                    borderSide: new BorderSide(
                                        color: ColourConfig().frenchPass)))),
                      ),
                      SizedBox(height: SizeConfig.blockSizeHorizontal * 3),
                      Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: SizeConfig.blockSizeHorizontal * 2,
                              left: SizeConfig.blockSizeHorizontal * 10,
                              right: SizeConfig.blockSizeHorizontal * 10),
                          child: Text('Gender',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.arimo(
                                  color: ColourConfig().dodgerBlue))
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeHorizontal * 2,
                            left: SizeConfig.blockSizeHorizontal * 10,
                            right: SizeConfig.blockSizeHorizontal * 10,
                            bottom: SizeConfig.blockSizeHorizontal * 3),
                        child: DropdownButtonFormField(
                          elevation: 2,
                          icon: Image.asset('assets/arrow-downward.png'),
                          style: GoogleFonts.arimo(
                            color: ColourConfig().dodgerBlue),
                          decoration: InputDecoration(
                                          border: new OutlineInputBorder(
                                              borderRadius: new BorderRadius.circular(0),
                                              borderSide: new BorderSide(),
                                            ),
                                            enabledBorder: new OutlineInputBorder(
                                                borderRadius: new BorderRadius.circular(0),
                                                borderSide: new BorderSide(
                                                    color: ColourConfig().frenchPass))
                              ),
                          value: _gender,
                          onChanged: (String value) {
                            setState(() {
                              _gender = value;
                            });
                          },
                          items: <String>['Male', 'Female']
                              .map((_gender) => DropdownMenuItem(
                                  value: _gender, child: Text(
                                    "$_gender",
                                    )
                                    ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockSizeHorizontal * 6),
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
                            child: Text("REGISTER",
                                textAlign: TextAlign.center,
                                textScaleFactor:
                                    SizeConfig.safeBlockVertical * 0.16,
                                style: GoogleFonts.arimo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          onTap: () async {
                            // save the fields..
                            final form = _formKey.currentState;
                            form.save();

                            // Validate will return true if is valid, or false if invalid.
                            if (form.validate()) {

                              // Create user account with _email and _password
                              try {
                                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: _email,
                                  password: _password
                                );

                                // Add _name as displayName in currentUser's profile 
                                await FirebaseAuth.instance.currentUser.updateProfile(
                                  displayName: _name,
                                ).then((value) => print("Added displayName to user's profile"));

                                // Add a new user document under collection users
                                FirebaseFirestore.instance.collection('users').add({
                                  'name': _name,
                                  'email': _email,
                                  'gender': _gender
                                });

                                // Navigate to homepage
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RecordAudio()));
                              
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  print('The password provided is too weak.');
                                  _showMyDialog(context, 'The password provided is too weak.');
                                } else if (e.code == 'email-already-in-use') {
                                  print('The account already exists for that email.');
                                  _showMyDialog(context, 'The account already exists for that email.');
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          }),
                          GestureDetector(
                              child: Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.only(
                                    top: SizeConfig.blockSizeHorizontal * 4,
                                    left: SizeConfig.blockSizeHorizontal * 10,
                                    right: SizeConfig.blockSizeHorizontal * 10),
                                child: Text("Already have an account?",
                                    textScaleFactor:
                                        SizeConfig.safeBlockVertical * 0.13,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.arimo(
                                        color: ColourConfig().dodgerBlue)),
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage())),
                            ),
                      
                      ],
            ),
              ]))),
        )
        )
    );
  }

  Future<void> _showMyDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () => Future.value(false),
            child: AlertDialog(
              title: Text('Invalid Registration'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text(message)],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
      },
    );
  }
}
