import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Constants/colors.dart';
import '../../Providers/boys_provider.dart';
import '../home/boy_home.dart';
import '../menu/menu_screen.dart';

class BoyBottomNavBar extends StatefulWidget {
  final String boyName;
  final String boyID;
  final String boyPhone;
  final String boyPhoto;
  bool isLockBool;
   BoyBottomNavBar({
    super.key,
    required this.boyName,
    required this.boyID,
    required this.boyPhone,
    required this.boyPhoto,
    required this.isLockBool,
  });

  @override
  State<BoyBottomNavBar> createState() => _BoyBottomNavBarState();
}

class _BoyBottomNavBarState extends State<BoyBottomNavBar> {
  int _currentPage = 0;
  late final List<Widget> _screens;


  // -------------------------------
  //   FORCE UPDATE POPUP
  // -------------------------------
  void _showForceUpdatePopup() {

    BoysProvider boysProvider = Provider.of<BoysProvider>(context, listen: false);
    boysProvider.getAppVersion();
    boysProvider.ReOpen(context);
    showDialog(
      context: context,
      barrierDismissible: false, // ❌ Not closable
      builder: (context) {
        return WillPopScope( // ❌ Back button disabled
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Update Required",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "A new version of the app is available.\n\nPlease update to continue.",
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () async {
                  const playStoreUrl =
                      "https://play.google.com/store/apps/details?id=com.yourapp.package";

                  if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                    await launchUrl(Uri.parse(playStoreUrl),
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("UPDATE"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isLockBool == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showForceUpdatePopup();
      });
    }else{
      print('${widget.isLockBool} FJRKJRF ');
    }

    _screens = [
      BoyHome(
        boyName: widget.boyName,
        boyID: widget.boyID,
        boyPhone: widget.boyPhone,
        boyPhoto: widget.boyPhoto,
      ),
       MenuScreen(
         boyName: widget.boyName,
         boyID: widget.boyID,
         boyPhone: widget.boyPhone,
         boyPhoto: widget.boyPhoto,
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
