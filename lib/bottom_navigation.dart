import 'package:google_fonts/google_fonts.dart';
import 'package:melofy/miscellaneous.dart';
import 'package:flutter/material.dart';
import 'tab_item.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({
    this.onSelectTab,
    this.tabs,
  });
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.brown,
      type: BottomNavigationBarType.fixed,
      items: tabs
          .map(
            (e) => _buildItem(
              index: e.getIndex(),
              icon: e.icon,
              tabName: e.tabName,
            ),
          )
          .toList(),
      onTap: (index) => onSelectTab(
        index,
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
      {int index, IconData icon, String tabName}) {
    return BottomNavigationBarItem(
      
      icon: Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Icon(icon, color: ColourConfig().dodgerBlue),
      ),

      title: Text(
        tabName,
        style: GoogleFonts.arimo(
          color: ColourConfig().dodgerBlue,
          fontSize: 12,
        ),
      ),
    );
  }
}