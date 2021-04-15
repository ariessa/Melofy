import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/login.dart';
import 'package:melofy/miscellaneous.dart'
    show EmailValidator, SizeConfig, ColourConfig;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
  var dropDownValue = "Male";


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
                            onSaved: (value) => _email = value,
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
                          value: dropDownValue,
                          onChanged: (String value) {
                            setState(() {
                              dropDownValue = value;
                            });
                          },
                          items: <String>['Male', 'Female']
                              .map((gender) => DropdownMenuItem(
                                  value: gender, child: Text(
                                    "$gender",
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
                              try {
                                await auth.FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: _email, password: _password);
                              } on auth.FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  print('No user found for that email.');
                                  _showMyDialog(
                                      context, 'No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  print(
                                      'Wrong password provided for that user.');
                                  _showMyDialog(context,
                                      'Wrong password provided for that user.');
                                }
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
              title: Text('Invalid Login'),
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
