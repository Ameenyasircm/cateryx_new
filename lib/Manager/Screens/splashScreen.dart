import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Constants/colors.dart';
import '../../Constants/my_functions.dart';
import '../Providers/LoginProvider.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  SharedPreferences? prefs;
  String? packageName;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    getPackageName();
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getPackageName(), localDB()]);
    LoginProvider loginProvider = LoginProvider();

    // Small delay to ensure the splash is visible before navigating
    Timer(const Duration(seconds: 3), () {
      if (!mounted || prefs == null) return;

      var user = prefs!.getString("phone_number");
      var userPassword = prefs!.getString("password");

      // Navigation logic based on Package Name
      if (packageName == "com.evento.boys" || packageName == "com.evento.manager") {
        navigateUser(user, loginProvider, const Loginscreen(),userPassword);
      }
    });
  }

  Future<void> localDB() async {
    prefs = await SharedPreferences.getInstance();

  }

  Future<void> getPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageName = packageInfo.packageName;
      print(packageName.toString()+' FRJ FNRJF ');
    });
  }

  void navigateUser(String? phoneNumber, LoginProvider loginProvider, Widget screen,String? userPassword) {
    if (phoneNumber == null) {
      loginProvider.loginphoneController.clear();
      callNextReplacement(screen, context);
    } else {
      loginProvider.userAuthorized(context: context,phone:phoneNumber,password: userPassword!);
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Important: Dispose controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Make sure your logo filename matches exactly
                  Image.asset(
                    'assets/Logo.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                  const SizedBox(height: 24),
                  // const Text(
                  //   "CATERING CREW MANAGEMENT",
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     letterSpacing: 1.5,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF1A237E), // Navy Blue
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE64A19)), // Orange
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}