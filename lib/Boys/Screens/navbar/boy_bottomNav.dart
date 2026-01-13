import 'package:flutter/material.dart';

import '../../../Constants/colors.dart';
import '../home/boy_home.dart';
import '../menu/menu_screen.dart';

class BoyBottomNavBar extends StatefulWidget {
  final String boyName;
  final String boyID;
  final String boyPhone;

  const BoyBottomNavBar({
    super.key,
    required this.boyName,
    required this.boyID,
    required this.boyPhone,
  });

  @override
  State<BoyBottomNavBar> createState() => _BoyBottomNavBarState();
}

class _BoyBottomNavBarState extends State<BoyBottomNavBar> {
  int _currentPage = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      BoyHome(
        boyName: widget.boyName,
        boyID: widget.boyID,
        boyPhone: widget.boyPhone,
      ),
       MenuScreen(
         boyName: widget.boyName,
         boyID: widget.boyID,
         boyPhone: widget.boyPhone,
       ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentPage = index;
    });

    if (index == 0) {
      _onHomeTab();
    } else if (index == 1) {
      _onMenuTab();
    }
  }

  void _onHomeTab() {
    debugPrint("Home tab clicked");
  }

  void _onMenuTab() {
    debugPrint("Menu tab clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentPage,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: _onTabSelected,
        backgroundColor: blue7E,
        selectedItemColor: red22,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
