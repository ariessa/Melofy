import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/miscellaneous.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

final List<String> imgList = [
  "https://images.unsplash.com/photo-1523554888454-84137e72c3ce?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
  "https://images.unsplash.com/photo-1602781148267-a2cd13e98c74?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=375&q=80",
  "https://images.unsplash.com/photo-1614386962045-71da4a84a4c8?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=282&q=80"
];

final List<String> titleList = [
  "Melody",
  "Pitch",
  "Rhythm"
];

final List<String> descriptionList = [
  "A logical progression of tones and rhythms, a tune set to a beat.",
  "Position of a single sound in accordance  to the frequency of vibration of the sound waves producing them.",
  "The pattern of regular or irregular pulses caused in music by the occurrence of strong and weak melodic and harmonic beats.",
];

final List<Widget> imageSliders = imgList.map((item) => Container(
  
  child: Container(
    color: Colors.white,
    margin: EdgeInsets.all(5.0),
    child: Column(
        children: <Widget>[
          ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
          // SizedBox(height: SizeConfig.blockSizeVertical * 4),
          child: Image.network(
            item,
            fit: BoxFit.cover, 
            height: SizeConfig.blockSizeVertical * 45, 
            width: SizeConfig.screenWidth - SizeConfig.blockSizeHorizontal * 4),),
          SizedBox(height: SizeConfig.blockSizeVertical * 8),

          Text(
                '${titleList[imgList.indexOf(item)]}',
                style: TextStyle(
                  color: Color(0xff2699FB),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
        SizedBox(height: SizeConfig.blockSizeVertical * 5),
        Container(
          padding: EdgeInsets.only(
            right: SizeConfig.blockSizeHorizontal * 3.5,
            left: SizeConfig.blockSizeHorizontal * 3.5
          ),
          child: Text(
                '${descriptionList[imgList.indexOf(item)]}',
                textAlign: TextAlign.center,
                textScaleFactor: SizeConfig.safeBlockVertical * 0.1,
                style: GoogleFonts.arimo(
                  height: 1.5,
                  color: Color(0xff2699FB),
                  fontSize: 20.0,
                  // fontWeight: FontWeight.bold,
                ),
              ),
        ),

        ],
    ),
  ),
)).toList();


class ViewInAppTutorials extends StatefulWidget {

  @override
  _ViewInAppTutorialsState createState() => _ViewInAppTutorialsState();
}

class _ViewInAppTutorialsState extends State<ViewInAppTutorials> {
  final CarouselController _controller = CarouselController();
  
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

      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                'Tutorials'.toUpperCase(),
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
                color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  CarouselSlider(
                    items: imageSliders,
                    options: CarouselOptions(
                      enlargeCenterPage: true, 
                      height: SizeConfig.blockSizeVertical * 100,
                      aspectRatio: 2.0),
                    carouselController: _controller,
                  ),
                ],
              ),
              ),


              ),
            
            ),
        );
    }
}