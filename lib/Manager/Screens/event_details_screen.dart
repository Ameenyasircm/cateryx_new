import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/ManagerProvider.dart';
import 'package:cateryyx/Manager/Screens/create_new_event.dart';
import 'package:cateryyx/Manager/Screens/work_wise_boys_screen.dart';
import 'package:cateryyx/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/confirm_dialog_utils.dart';
import '../widgets/event_details_widgets.dart';
import 'attendence_screen.dart';
import 'event_payment_screen.dart';
import 'note_screen.dart';

// ─── App Color Constants ───────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF2C2CB4); // deep indigo
const _kAccent    = Color(0xFFE64A19); // deep orange-red
const _kBg        = Color(0xFFF8F9FB); // light grey-white
const _kCardBg    = Colors.white;
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF757575);
// ──────────────────────────────────────────────────────────────────────────────

class EventDetailedScreen extends StatefulWidget {
  final String eventID;
  final String fromWhere;

  const EventDetailedScreen({
    super.key,
    required this.eventID,
    required this.fromWhere,
  });

  @override
  State<EventDetailedScreen> createState() => _EventDetailedScreenState();
}

class _EventDetailedScreenState extends State<EventDetailedScreen> {
  bool isWorkAllowed = true;

  @override
  Widget build(BuildContext context) {
    final managerProvider = Provider.of<ManagerProvider>(context);

    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.eventModel == null) {
            return const Center(child: CircularProgressIndicator(color: _kPrimary));
          }
          final event = provider.eventModel!;

          return CustomScrollView(
            slivers: [
              // ── Collapsible App Bar ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: _kPrimary,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(event),
                ),
                title: Text(
                  event.eventName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),

              // ── Body Content ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Quick Stats Row ──────────────────────────────────────
                      _buildStatsRow(event),

                      const SizedBox(height: 20),

                      // ── Action Buttons ───────────────────────────────────────
                      _buildSectionLabel('Quick Actions'),
                      const SizedBox(height: 10),
                      _buildActionGrid(context, provider, managerProvider),

                      const SizedBox(height: 24),

                      // ── Work Status ──────────────────────────────────────────
                      _buildSectionLabel('Work Status'),
                      const SizedBox(height: 10),
                      _buildWorkStatusCard(context, provider),

                      const SizedBox(height: 24),

                      // ── Menu ─────────────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel('Menu'),
                          _addMenuButton(context, event.eventId),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildMenuList(provider),

                      const SizedBox(height: 24),

                      // ── Event Location ───────────────────────────────────────
                      _buildSectionLabel('Event Location'),
                      const SizedBox(height: 10),
                      _buildInfoCard([
                        _infoRow(Icons.location_on_outlined, 'Location',
                            event.locationName),
                        _divider(),
                        _infoRow(Icons.restaurant_outlined, 'Meal Type',
                            event.mealType),
                        _divider(),
                        _infoRow(Icons.calendar_month_outlined, 'Date',
                            event.eventDate),
                      ]),

                      const SizedBox(height: 16),

                      // ── Map ──────────────────────────────────────────────────
                      _buildSectionLabel('Map Location'),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: mapBox(event.latitude, event.longitude, context),
                      ),

                      const SizedBox(height: 24),

                      // ── Client Details ───────────────────────────────────────
                      _buildSectionLabel('Event Details'),
                      const SizedBox(height: 10),
                      _buildInfoCard([
                        _infoRow(Icons.description_outlined, 'Description',
                            event.description),
                        _divider(),
                        _infoRow(Icons.group_outlined, 'Boys Required',
                            event.boysRequired.toString()),
                        _divider(),
                        _infoRow(Icons.person_outline, 'Client', event.clientName),
                        _divider(),
                        _infoRow(Icons.phone_outlined, 'Phone', event.clientPhone),
                        _divider(),
                        _buildContactButtons(event.clientPhone),
                        _divider(),
                        _infoRow(Icons.info_outline, 'Status', event.status),
                      ]),

                      const SizedBox(height: 28),

                      // ── Cancel Button ────────────────────────────────────────
                      _buildCancelButton(context),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Hero Header ──────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(event) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.eventName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _headerChip(Icons.calendar_month_outlined, event.eventDate),
              const SizedBox(width: 10),
              _headerChip(Icons.location_on_outlined, event.locationName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 5),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────────
  Widget _buildStatsRow(event) {
    return Row(
      children: [
        _statCard(
          icon: Icons.people_alt_outlined,
          label: 'Boys',
          value: '${event.boysTaken}/${event.boysRequired}',
          color: _kPrimary,
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.event_available_outlined,
          label: 'Status',
          value: event.status,
          color: _kAccent,
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.restaurant_outlined,
          label: 'Meal',
          value: event.mealType,
          color: const Color(0xFF00897B),
        ),
      ],
    );
  }

  Widget _statCard(
      {required IconData icon,
        required String label,
        required String value,
        required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp)),
            Text(label,
                style: const TextStyle(color: _kTextMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: _kAccent,
            margin: const EdgeInsets.only(right: 8)),
        Text(title,
            style: const TextStyle(
                color: _kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ],
    );
  }

  // ── Action Grid ──────────────────────────────────────────────────────────────
  Widget _buildActionGrid(BuildContext context, EventDetailsProvider provider,
      ManagerProvider managerProvider) {
    final event = provider.eventModel!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _primaryActionBtn(
                icon: Icons.group_add_outlined,
                label: 'Boys (${event.boysTaken}/${event.boysRequired})',
                onTap: () => callNext(
                    EventAllBoys(
                      eventId: event.eventId,
                      eventDate: event.eventDate,
                      eventLocation: event.locationName,
                    ),
                    context),
                hasBadge: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _primaryActionBtn(
                icon: Icons.payment_outlined,
                label: 'Make Payment',
                onTap: () => callNext(
                    EventPaymentScreen(eventId: event.eventId), context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _outlineActionBtn(
                icon: Icons.edit_calendar_rounded,
                label: 'Edit Event',
                onTap: () {
                  managerProvider.loadEventForEdit(event.eventId);
                  callNext(
                      CreateEventScreen(
                          eventId: event.eventId, isEdit: true),
                      context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _primaryActionBtn(
                icon: Icons.fact_check_outlined,
                label: 'Attendance',
                onTap: () => callNext(
                    EventAttendanceScreen(eventId: event.eventId), context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (widget.fromWhere == "upcoming")
              Expanded(
                child: _outlineActionBtn(
                  icon: Icons.publish_rounded,
                  label: 'Publish',
                  color: _kAccent,
                  onTap: () async {
                    final ok = await showConfirmationDialog(
                      context: context,
                      title: 'Publish Event',
                      message: 'Publish this event now?',
                      confirmText: 'Yes',
                      cancelText: 'No',
                    );
                    if (!ok) return;
                    managerProvider.publishEvent(event.eventId, context);
                    finish(context);
                  },
                ),
              ),
            if (widget.fromWhere == "upcoming") const SizedBox(width: 10),
            Expanded(
              child: _outlineActionBtn(
                icon: Icons.check_circle_outline,
                label: 'Complete',
                color: const Color(0xFF2E7D32),
                onTap: () async {
                  final ok = await showConfirmationDialog(
                    context: context,
                    title: 'Complete Event',
                    message: 'Mark event as completed?',
                    confirmText: 'Close',
                    cancelText: 'Cancel',
                  );
                  if (!ok) return;
                  managerProvider.closeEvent(event.eventId);
                  finish(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _outlineActionBtn(
                icon: Icons.notes_outlined,
                label: 'Notes',
                onTap: () {
                  provider.listenNotes(event.eventId);
                  callNext(NotesScreen(eventId: event.eventId), context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _primaryActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _outlineActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = _kPrimary,
  }) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Add Menu Button ──────────────────────────────────────────────────────────
  Widget _addMenuButton(BuildContext context, String eventId) {
    return GestureDetector(
      onTap: () => showAddMenuDialog(context, eventId),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _kAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kAccent, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: _kAccent),
            SizedBox(width: 4),
            Text('Add Item',
                style: TextStyle(
                    color: _kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Menu List ────────────────────────────────────────────────────────────────
  Widget _buildMenuList(EventDetailsProvider provider) {
    if (provider.menuList.isEmpty) {
      return Container(
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('No menu items yet',
            style: TextStyle(color: _kTextMuted, fontSize: 13)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.menuList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = provider.menuList[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu,
                    color: _kPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['FOOD_NAME'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item['CATEGORY'] ?? '',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _kTextMuted)),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '₹${item['PRICE'] ?? 0}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Work Status Card ─────────────────────────────────────────────────────────
  Widget _buildWorkStatusCard(BuildContext context, EventDetailsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWorkAllowed
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isWorkAllowed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWorkAllowed ? Icons.work_outline : Icons.work_off_outlined,
              color: isWorkAllowed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Work Status',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kTextDark)),
                const SizedBox(height: 2),
                Text(
                  isWorkAllowed ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                      color: isWorkAllowed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: isWorkAllowed,
            activeColor: Colors.green,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (v) async {
              setState(() => isWorkAllowed = v);
              await context.read<EventDetailsProvider>().updateWorkActiveStatus(
                eventId: provider.eventModel!.eventId,
                isActive: v,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Info Card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _kPrimary),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    color: _kTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: _kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.shade100, thickness: 1);

  Widget _buildContactButtons(String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: phone.isEmpty
                  ? null
                  : () => launchUrl(Uri.parse('tel:$phone')),
              icon: const Icon(Icons.call, color: Colors.white, size: 18),
              label: const Text('Call',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: phone.isEmpty
                  ? null
                  : () => launchUrl(Uri.parse('https://wa.me/$phone')),
              icon: Image.asset('assets/whsp.png',
                  color: Colors.white, scale: 12),
              label: const Text('WhatsApp',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancel Button ────────────────────────────────────────────────────────────
  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => showCancelDialog(context),
        icon: const Icon(Icons.cancel_outlined, color: _kAccent),
        label: const Text(
          'Cancel Work',
          style: TextStyle(
              color: _kAccent,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.5),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _kAccent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────
  Future<void> showCancelDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _kAccent),
            SizedBox(width: 8),
            Text('Cancel Work?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text('This action cannot be undone. Are you sure?',
            style: TextStyle(color: _kTextMuted)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kTextMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('No', style: TextStyle(color: _kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final eventDetailsProvider =
              Provider.of<EventDetailsProvider>(context, listen: false);
              final managerProvider =
              Provider.of<ManagerProvider>(context, listen: false);

              bool boysExist =
              await eventDetailsProvider.hasConfirmedBoys(widget.eventID);
              if (boysExist) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Cannot cancel — boys already confirmed.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              await eventDetailsProvider.cancelEvent(widget.eventID);
              managerProvider.cancelWorkRemoveList(widget.eventID);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Work cancelled successfully'),
                backgroundColor: _kAccent,
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void showAddMenuDialog(BuildContext context, String eventId) {
    final foodController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, color: _kPrimary),
            SizedBox(width: 8),
            Text('Add Food Item',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(foodController, 'Food Name', Icons.fastfood_outlined),
            const SizedBox(height: 12),
            _dialogTextField(
                categoryController, 'Category', Icons.category_outlined),
            const SizedBox(height: 12),
            _dialogTextField(priceController, 'Price (₹)', Icons.currency_rupee,
                type: TextInputType.number),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _kTextMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel', style: TextStyle(color: _kTextMuted)),
          ),
          Consumer<EventDetailsProvider>(
            builder: (ctx, val, _) => ElevatedButton(
              onPressed: () async {
                await val.addMenuItem(
                  eventId: eventId,
                  foodName: foodController.text,
                  category: categoryController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField(
      TextEditingController controller, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _kPrimary, size: 20),
        filled: true,
        fillColor: _kBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}