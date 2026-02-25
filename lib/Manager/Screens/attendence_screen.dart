import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1A237E); // deep indigo — MAIN
const _kAccent    = Color(0xFFFF5722); // orange-red  — highlights
const _kBg        = Color(0xFFF8F9FB);
const _kCardBg    = Colors.white;
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF9E9E9E);
// ───────────────────────────────────────────────────────────────────────────────

class EventAttendanceScreen extends StatelessWidget {
  final String eventId;

  const EventAttendanceScreen({super.key, required this.eventId});

  void _callNumber(String number) =>
      launchUrl(Uri.parse('tel:$number'));

  void _openWhatsApp(String number) =>
      launchUrl(Uri.parse('https://wa.me/$number'),
          mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kPrimary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }

          if (provider.confirmedBoysList.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.how_to_reg_outlined,
                        color: _kPrimary, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('No boys to mark attendance',
                      style: TextStyle(color: _kTextMuted, fontSize: 15)),
                ],
              ),
            );
          }

          // ── Summary strip ─────────────────────────────────────────────────
          final total = provider.confirmedBoysList.length;
          final present = provider.confirmedBoysList
              .where((b) => b.attendanceStatus.toLowerCase() == 'present')
              .length;
          final absent = provider.confirmedBoysList
              .where((b) => b.attendanceStatus.toLowerCase() == 'absent')
              .length;

          return Column(
            children: [
              // Summary bar
              Container(
                color: _kPrimary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _summaryChip('Total', total.toString(), Colors.white),
                    const SizedBox(width: 10),
                    _summaryChip('Present', present.toString(), Colors.green),
                    const SizedBox(width: 10),
                    _summaryChip('Absent', absent.toString(), Colors.red),
                    const SizedBox(width: 10),
                    _summaryChip(
                      'Pending',
                      (total - present - absent).toString(),
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              // Boys list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: provider.confirmedBoysList.length,
                  itemBuilder: (context, index) {
                    final boy = provider.confirmedBoysList[index];
                    final status = boy.attendanceStatus;
                    final statusColor = attendanceColor(status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _kCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Avatar with status indicator
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                  _kPrimary.withOpacity(0.09),
                                  child: Text(
                                    boy.boyName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: _kPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 12),

                            // Name + phone
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ${boy.boyName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _kTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(boy.boyPhone,
                                      style: const TextStyle(
                                          color: _kTextMuted, fontSize: 12)),
                                ],
                              ),
                            ),

                            // Call icon
                            _iconChip(
                              icon: Icons.call,
                              color: Colors.green,
                              onTap: () => _callNumber(boy.boyPhone),
                            ),
                            const SizedBox(width: 6),

                            // WhatsApp icon
                            _iconChip(
                              assetIcon: 'assets/whsp.png',
                              color: const Color(0xFF00897B),
                              onTap: () => _openWhatsApp(boy.boyPhone),
                            ),
                            const SizedBox(width: 8),

                            // Attendance chip/button
                            GestureDetector(
                              onTap: () {
                                showAttendanceChoiceDialog(
                                  context: context,
                                  boyName: boy.boyName,
                                  onConfirm: (status) async {
                                    final prefs =
                                    await SharedPreferences.getInstance();
                                    await provider.markAttendance(
                                      eventId: eventId,
                                      boy: boy,
                                      attendanceStatus: status,
                                      updatedById:
                                      prefs.getString('adminID') ?? '',
                                      updatedByName:
                                      prefs.getString('adminName') ?? '',
                                    );
                                    showSuccessAlert(
                                      context: context,
                                      title: 'Updated',
                                      message:
                                      '${boy.boyName} marked as $status',
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: statusColor.withOpacity(0.4),
                                      width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down_rounded,
                                        color: statusColor, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _summaryChip(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconChip({
    IconData? icon,
    String? assetIcon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: color, size: 18)
              : Image.asset(assetIcon!, color: color, scale: 8),
        ),
      ),
    );
  }
}