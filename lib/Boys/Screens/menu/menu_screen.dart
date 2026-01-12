import 'package:flutter/material.dart';
import '../../../Manager/Screens/LoginScreen.dart';
import '../../../core/theme/app_spacing.dart';
import 'widgets/menu_header.dart';
import 'widgets/menu_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatelessWidget {
   MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
           MenuHeader(),
          AppSpacing.h12,
          MenuTile(
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              // Navigator.push(...)
            },
          ),
          MenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Payment Report',
            onTap: () {
              // Navigator.push(...)
            },
          ),
          Spacer(),
          MenuTile(
            showIcon: false,
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () {
              logout(context);
            },
          ),
          AppSpacing.h24,
        ],
      ),
    );
  }
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
          (route) => false,
    );
  }
}
