import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:melofy/main.dart';
import 'package:melofy/record_audio.dart';
import 'package:melofy/view_in-app_tutorials.dart';
import 'package:melofy/view_melodies_main.dart';
import 'package:melofy/view_favourites.dart';
import 'tab_item.dart';
import 'bottom_navigation.dart';
import 'package:melofy/logout.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;
  static bool disableNavbar = false;

  // list tabs here
  final List<TabItem> tabs = [
    // TabItem(
    //   tabName: "Record",
    //   icon: Icons.graphic_eq_rounded,
    //   page: RecordAudio(),
    // ),
    TabItem(
      tabName: "Melodies",
      icon: Icons.music_note,
      page: ViewMelodiesMain(),
    ),
    TabItem(
      tabName: "Favourites",
      icon: Icons.favorite_border_rounded,
      page: ViewFavouritesMain(),
    ),
    TabItem(
      tabName: "Tutorials",
      icon: Icons.school_rounded,
      page: ViewInAppTutorials(),
    ),
    TabItem(
      tabName: "Log Out",
      icon: Icons.logout,
      page: LogoutPage(),
    ),
  ];

  AppState() {
    // indexing is necessary for proper funcationality
    // of determining which tab is active
    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void _selectTab(int index) {
    // if (index == currentTab && AppState.isRecording == true) {
    //   tabs[index].key.currentState.popUntil((route) => route.isFirst);
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (context) => RecordingAudio()),
    //   );
    // }
    if (index != 0) {
      setState(() {
        AppState.disableNavbar = false;
        currentTab = index;
      });
      
    }
    else if (index == currentTab) {
      // pop to first route
      // if the user taps on the active tab
      tabs[index].key.currentState.popUntil((route) => route.isFirst);
    } else {
      // update the state
      // in order to repaint
      setState(() => currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope handle android back btn

    if (AppState.currentTab != 0) {
      return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            _selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
        // indexed stack shows only one child
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        // Bottom navigation
        bottomNavigationBar: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
      //   floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //   floatingActionButton: new FloatingActionButton(
      //   onPressed:(){ 
      //     Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => RecordAudio()));
      //    },
      //   tooltip: 'Create New Melody',
      //   child: new Icon(Icons.add),
      // ), 
      ),
    );

    }


    else if (AppState.disableNavbar == false) {

      return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            _selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
        // indexed stack shows only one child
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        // Bottom navigation
        bottomNavigationBar: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: new FloatingActionButton(
        onPressed:(){ 
          Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => RecordAudio()));
         },
        tooltip: 'Create New Melody',
        child: new Icon(Icons.add),
      ), 
      ),
    );
    }



    else {

      return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            _selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
      //   // indexed stack shows only one child
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        // Bottom navigation
        bottomNavigationBar: AppState.disableNavbar ? null: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
      //   floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      //   floatingActionButton: new FloatingActionButton(
      //   onPressed:(){ 
      //     Navigator.pushReplacement(context, MaterialPageRoute(
      //     builder: (context) => RecordAudio()));
      //    },
      //   tooltip: 'Create New Melody',
      //   child: new Icon(Icons.add),
      // ), 
      ),
    );

    }






  }
}


enum ConfirmAction { CANCEL, CONFIRM }

Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button to close dialog!
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () => Future.value(false),
          child: AlertDialog(
            title: Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(ConfirmAction.CANCEL);
                },
              ),
              FlatButton(
                child: const Text('CONFIRM'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop(ConfirmAction.CONFIRM);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
              )
            ],
          ));
    },
  );
}