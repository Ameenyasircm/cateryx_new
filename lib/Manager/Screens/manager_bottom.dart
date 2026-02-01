import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Boys/Providers/boys_provider.dart';
import 'all_boys_screen.dart';
import 'manager_home_screen.dart';
import 'manager_menu_screen.dart';
import 'package:provider/provider.dart';

class ManagerBottom extends StatefulWidget {
  String adminID,adminName,adminPhone;
  int initialIndex=0;
  bool isLockBool;
  ManagerBottom({Key? key,required this.adminID,required this.adminName
    ,required this.adminPhone,required this.isLockBool}) : super(key: key);

  @override
  State<ManagerBottom> createState() => _ManagerBottomState();
}

class _ManagerBottomState extends State<ManagerBottom> {

  late int _currentPage;
  final ScrollController _scrollController = ScrollController();

  late List<Widget> _screens;

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
    _currentPage = 0;

    _screens = [
      ManagerHomeScreen(),
      BoysListScreen(),
      ManagerMenuScreen(
        managerId: widget.adminID,
        managerName: widget.adminName,
        phoneNumber: widget.adminPhone,
      ),
    ];
  }

  void _showForceUpdatePopup() {

    BoysProvider boysProvider = Provider.of<BoysProvider>(context, listen: false);
    boysProvider.getAppVersion();
    boysProvider.reOpenGM();
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

  void _onTabSelected(int index) {
    setState(() {
      _currentPage = index;
    });

    // Call functions based on tab index
    switch (index) {
      case 0:
        _onHomeTab();
        break;
      case 1:
        _onBoysTab();
        break;
      case 2:
        _onMenuTab();
        break;
    }
  }

  void _onHomeTab() {
    print("Home tab clicked");
    // Example:
    // context.read<HomeProvider>().fetchDashboard();
  }

  void _onBoysTab() {
    print("Boys tab clicked");
    final boyProvider =
    Provider.of<BoysProvider>(context, listen: false);
    boyProvider.fetchBoys();
  }

  void _onMenuTab() {
    print("Menu tab clicked");
  }


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        // Display the body based on the selected index
        body: IndexedStack(
          index: _currentPage,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (index) {
            setState(() {
              _onTabSelected(index);
              _currentPage = index;
            });
          },
          // Styling to match your image
          backgroundColor: const Color(0xff1A237E), // Dark blue background
          selectedItemColor: const Color(0xffFF5722), // Orange for active
          unselectedItemColor: Colors.white, // White for inactive
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home), // Solid home when active
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: 'Boys',
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
