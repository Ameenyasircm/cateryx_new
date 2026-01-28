
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Screens/payment_report_screen.dart';
import 'package:cateryyx/Manager/Screens/update_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../Constants/my_functions.dart';
import '../Providers/ManagerProvider.dart';
import 'about_screen.dart';
import 'boys_requests.dart';
import 'closed_events_screen.dart';

class ManagerMenuScreen extends StatelessWidget {
  final String managerName;
  final String managerId;
  final String phoneNumber;

  const ManagerMenuScreen({
    Key? key,
    required this.managerName,
    required this.managerId,
    required this.phoneNumber,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      body: Column(
        children: [
          // 🔹 COMPACT HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1A237E), Color(0xff3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 34, color: Color(0xff1A237E)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        managerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        phoneNumber,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildRoleBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 🔹 MENU
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.payment_rounded,
                  title: "Payment Report",
                  subtitle: "View all payments",
                  onTap: () {
                    managerProvider.clearFilters();
                    callNext(ManagerPaymentReportScreen(), context);
                  },
                ),
                _menuTile(
                  icon: Icons.group_add_rounded,
                  title: "Boys Request",
                  subtitle: "Pending & approved requests",
                  onTap: () {
                    managerProvider.fetchPendingBoysRequests();
                    callNext(BoysRequestScreen(), context);
                  },
                ),
                _menuTile(
                  icon: Icons.task_alt_rounded,
                  title: "Completed Works",
                  subtitle: "Finished job details",
                  onTap: () {
                    context.read<EventDetailsProvider>().fetchClosedEvents();
                    callNext(ClosedEventsScreen(), context);
                  },
                ),
                _menuTile(
                  icon: Icons.lock_open_rounded,
                  title: "Security",
                  subtitle: "Change password",
                  onTap: () {
                    callNext(
                      ChangePasswordScreen(managerID: managerId, fromWhere: 'manager',),
                      context,
                    );
                  },
                ),
                FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final info = snapshot.data!;
                    return _menuTile(
                      icon: Icons.info_outline_rounded,
                      title: "About Cateryx",
                      subtitle: "Version ${info.version}+${info.buildNumber}",
                      onTap: () {
                        callNext(AboutScreen(), context);
                      },
                    );
                  }
                ),

                const SizedBox(height: 8),

                // 🔹 LOGOUT INSIDE SCROLL
                _logoutTile(context),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),


          // 🔹 LOGOUT
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: const Text(
        "MANAGER",
        style: TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff1A237E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xff1A237E)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
Widget _logoutTile(BuildContext context) {
  ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.red.withOpacity(0.3)),
    ),
    child: ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      title: const Text(
        "Logout",
        style: TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: const Text(
        "End current session",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () => managerProvider.logout(context),
    ),
  );
}
