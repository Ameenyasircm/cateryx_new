import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Screens/payment_report_screen.dart';
import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Boys/Providers/boys_provider.dart';
import '../../core/utils/url_launcher.dart';
import '../Providers/ManagerProvider.dart';
import 'boy_work_history_screen.dart';

class BoyDetailsScreen extends StatelessWidget {
  final Map boy;

  const BoyDetailsScreen({super.key, required this.boy});

  static const primaryBlue = Color(0xff1A237E);
  static const primaryOrange = Color(0xffE65100);

  @override
  Widget build(BuildContext context) {
    final boysProvider = context.watch<BoysProvider>();
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Boy Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 👤 Profile Icon
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 50, color: primaryBlue),
            ),
            AppSpacing.h20,

            /// 📋 Work History Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: () => _navigateToWorkHistory(
                  context,
                  boy['BOY_ID'],
                  boy['NAME'],
                ),
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text(
                  "View Work History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: (){
                  managerProvider.clearFilters();
                  managerProvider.fetchFirstPage(boyId: boy['BOY_ID']);
                  callNext(
                    ManagerPaymentReportScreen(fromWhere: 'boy', boyId: boy['BOY_ID']),
                    context,
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text(
                  "Payment History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            _infoTile("Name", boy['NAME']),
            _infoTile("Phone", boy['PHONE']),
            _infoTile("Guardian Contact", boy['GUARDIAN_PHONE']),
            _infoTile("Date of Birth", boy['DOB']),
            _infoTile("Blood Group", boy['BLOOD_GROUP']),
            _infoTile("Place", boy['PLACE']),
            _infoTile("District", boy['DISTRICT']),
            _infoTile("Pin Code", boy['PIN']),
            _infoTile("Address", boy['ADDRESS']),
            AppSpacing.h30,

            /// ☎️ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => callNumber(boy['PHONE']),
                    icon: const Icon(Icons.call, color: Colors.white),
                    label: const Text("Call",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => openWhatsApp(boy['PHONE']),
                    icon: Image.asset(
                      'assets/whsp.png',
                      height: 22,
                      color: Colors.white,
                    ),
                    label: const Text("WhatsApp",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.h30,

            /// 🚫 BLOCK / UNBLOCK BUTTON
            _blockUnblockButton(context, boysProvider),
          ],
        ),
      ),
    );
  }

  /// 🔹 BLOCK / UNBLOCK BUTTON UI
  Widget _blockUnblockButton(BuildContext context, BoysProvider provider) {
    final isBlocked = boy['BLOCK_STATUS'] == "BLOCKED";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          isBlocked
              ? _showUnblockDialog(context, provider, boy['BOY_ID'])
              : _showBlockDialog(context, provider, boy['BOY_ID']);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlocked ? Colors.green : Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isBlocked ? "Unblock Boy" : "Block Boy",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 🔹 Block Confirmation Dialog
  void _showBlockDialog(
      BuildContext context, BoysProvider provider, String boyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Block Boy?"),
        content: const Text(
            "Are you sure you want to block this boy? He will not be able to login anymore."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await provider.blockBoy(boyId);
              Navigator.pop(context);
              Navigator.pop(context); // go back to list
            },
            child: const Text("Block", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 🔹 Unblock Confirmation Dialog
  void _showUnblockDialog(
      BuildContext context, BoysProvider provider, String boyId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unblock Boy?"),
        content: const Text("Allow this boy to login again."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await provider.unblockBoy(boyId);
              Navigator.pop(context);
              Navigator.pop(context); // go back to list
            },
            child:
            const Text("Unblock", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  /// 🔹 Navigate to Work History Screen
  void _navigateToWorkHistory(
      BuildContext context, String boyId, String boyName) {
    final state = context.read<ManagerProvider>();
    state.fetchBoyWorkHistory(boyId);

    callNext(
      BoyWorkHistoryScreen(boyId: boyId, boyName: boyName),
      context,
    );
  }

  /// 🔹 Info Tile
  Widget _infoTile(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? "-",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
