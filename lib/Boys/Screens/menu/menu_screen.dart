import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/my_functions.dart';
import '../../../Manager/Providers/EventDetailProvider.dart';
import '../../../Manager/Providers/ManagerProvider.dart';
import '../../../Manager/Screens/LoginScreen.dart';
import '../../../Manager/Screens/closed_events_screen.dart';
import '../../../Manager/Screens/payment_report_screen.dart';
import '../../../Manager/Screens/update_password_screen.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/logout_alert.dart';
import 'captain_works_screen.dart';
import 'widgets/menu_header.dart';
import 'widgets/menu_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatelessWidget {
  final String boyName,boyID,boyPhone;
   const MenuScreen({super.key,required this.boyName,required this.boyID,required this.boyPhone});

  @override
  Widget build(BuildContext context) {
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);
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
          MenuHeader(boyName: boyName, boyID:boyID, boyPhone: boyPhone,),
          AppSpacing.h12,
          // MenuTile(
          //   icon: Icons.person_outline,
          //   title: 'Profile',
          //   onTap: () {
          //     // Navigator.push(...)
          //   },
          // ),

          MenuTile(
            icon: Icons.workspaces_outline,
            title: 'Captain Works',
            onTap: () {
              context.read<EventDetailsProvider>().fetchCaptainEvents(boyID);
              callNext(CaptainEventsScreen(captainId:boyID ,captainName:boyName ,), context);
            },
          ),   MenuTile(
            icon: Icons.task_alt_rounded,
            title: 'Completed Works',
            onTap: () {
              context.read<EventDetailsProvider>().fetchClosedEventsForBoy(boyID);
              callNext(ClosedEventsScreen(fromWhere: 'boy', boyId: boyID,), context);

            },
          ),
          MenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Payment Report',
            onTap: () {
              managerProvider.clearFilters();
              managerProvider.fetchFirstPage(boyId: boyID);
              callNext(
                ManagerPaymentReportScreen(fromWhere: 'boy', boyId: boyID),
                context,
              );

            },
          ),
          MenuTile(
            icon: Icons.lock_open_rounded,
            title: 'Change password',
            onTap: () {
              callNext(
                ChangePasswordScreen(managerID: boyID, fromWhere: 'boy',),
                context,
              );
            },
          ),
          Spacer(),
          MenuTile(
            showIcon: false,
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () async {
              final shouldLogout = await showLogoutDialog(context);
              if (shouldLogout == true) {
                logout(context);
              }

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
