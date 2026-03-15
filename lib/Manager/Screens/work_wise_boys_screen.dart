import 'package:cateryyx/Constants/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

class EventAllBoys extends StatelessWidget {
  final String eventId, eventLocation, eventDate;

  const EventAllBoys({
    super.key,
    required this.eventId,
    required this.eventLocation,
    required this.eventDate,
  });

  void _callNumber(String phone) async =>
      await launchUrl(Uri(scheme: 'tel', path: phone));

  void _openWhatsApp(String phone) async =>
      await launchUrl(Uri.parse('https://wa.me/$phone'),
          mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventDetailsProvider>(context);

    return Scaffold(
      backgroundColor: _kBg,

      // ── AppBar ──────────────────────────────────────────────────────────────
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
          'Event Boys',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => provider.copyEventDetails(
                  eventLocation, eventDate, context),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(Icons.copy_outlined,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              // ── Event Info Card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.location_on_outlined, 'Site', eventLocation),
                    const SizedBox(height: 8),
                    _infoRow(Icons.calendar_month_outlined, 'Date', eventDate),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Add Boy Button ───────────────────────────────────────────
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showBoySearchDialog(context, eventId, provider),
                  icon: const Icon(Icons.person_add_outlined,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Add Boy',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Site Captain ─────────────────────────────────────────────
              _sectionLabel('Site Captain'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (provider.confirmedBoysList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No boys available to assign as captain'),
                    ));
                    return;
                  }
                  showSelectCaptainDialog(context, provider, eventId);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: provider.siteCaptainName.isEmpty
                          ? [Colors.grey.shade500, Colors.grey.shade600]
                          : [
                        const Color(0xFF1A237E),
                        const Color(0xFF283593),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.siteCaptainName.isEmpty
                              ? 'Choose Captain'
                              : 'Captain: ${provider.siteCaptainName}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (provider.siteCaptainId.isNotEmpty)
                        GestureDetector(
                          onTap: () => showRemoveCaptainConfirmation(
                              eventId, context, provider),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Confirmed Boys Header ────────────────────────────────────
              Row(
                children: [
                  _sectionLabel('Confirmed Boys'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.confirmedBoysList.length}',
                      style: const TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Boys List ────────────────────────────────────────────────
              provider.confirmedBoysList.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.confirmedBoysList.length,
                itemBuilder: (context, index) {
                  final boy = provider.confirmedBoysList[index];
                  final isCaptain =
                      boy.boyId == provider.siteCaptainId;

                  return GestureDetector(
                    onLongPress: () => showDeleteBoyDialog(context,
                        eventId, boy.boyId, boy.boyName, provider),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: isCaptain
                            ? Border.all(
                            color: _kPrimary.withOpacity(0.4),
                            width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                _kPrimary.withOpacity(0.1),
                                child: ClipOval(
                                  child: Image.network(
                                    boy.photo ?? '',
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, _) =>
                                    const Icon(Icons.person,
                                        size: 28,
                                        color: _kPrimary),
                                  ),
                                ),
                              ),
                              if (isCaptain)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: _kPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white,
                                          width: 1.5),
                                    ),
                                    child: const Icon(
                                        Icons.star_rounded,
                                        color: Colors.white,
                                        size: 10),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // Name + phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${index + 1}. ${boy.boyName}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _kTextDark,
                                      ),
                                    ),
                                    if (isCaptain) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _kPrimary
                                              .withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(
                                              6),
                                        ),
                                        child: const Text(
                                          'Captain',
                                          style: TextStyle(
                                            color: _kPrimary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  boy.boyPhone,
                                  style: const TextStyle(
                                      color: _kTextMuted,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // Action icons
                          _iconChip(
                            icon: Icons.call,
                            color: Colors.green,
                            onTap: () => _callNumber(boy.boyPhone),
                          ),
                          const SizedBox(width: 6),
                          _iconChip(
                            assetIcon: 'assets/whsp.png',
                            color: const Color(0xFF00897B),
                            onTap: () =>
                                _openWhatsApp(boy.boyPhone),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _kPrimary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: _kTextMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: _kTextDark,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(text,
            style: const TextStyle(
                color: _kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text('No boys added yet',
          style: TextStyle(color: _kTextMuted, fontSize: 13)),
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

// ─── Search Boy Dialog ────────────────────────────────────────────────────────
void showBoySearchDialog(BuildContext context, String eventId,
    EventDetailsProvider eventDetailsProvider) {
  String searchText = '';
  List<Map<String, dynamic>> results = [];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_search_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Search Boy',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: _kTextDark),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone',
                  hintStyle:
                  const TextStyle(color: _kTextMuted, fontSize: 13),
                  prefixIcon:
                  const Icon(Icons.search, color: _kPrimary, size: 20),
                  filled: true,
                  fillColor: _kBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: _kPrimary, width: 1.5),
                  ),
                ),
                onChanged: (value) async {
                  searchText = value;
                  if (searchText.length > 1) {
                    results =
                    await eventDetailsProvider.searchBoys(searchText);
                  } else {
                    results = [];
                  }
                  setState(() {});
                },
              ),
            ),

            // Results
            SizedBox(
              height: 260,
              child: results.isEmpty
                  ? Center(
                child: Text(
                  searchText.isEmpty
                      ? 'Type to search'
                      : 'No results found',
                  style: const TextStyle(
                      color: _kTextMuted, fontSize: 13),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: results.length,
                itemBuilder: (ctx, i) {
                  final boy = results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    leading: CircleAvatar(
                      backgroundColor: _kPrimary.withOpacity(0.1),
                      child: Text(
                        (boy['NAME'] as String)[0].toUpperCase(),
                        style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(boy['NAME'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _kTextDark)),
                    subtitle: Text(boy['PHONE'],
                        style: const TextStyle(
                            color: _kTextMuted, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      showConfirmAddBoyDialog(
                        context,
                        eventId,
                        boy['BOY_ID'],
                        boy['NAME'],
                        eventDetailsProvider,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

// ─── Confirm Add Boy Dialog ───────────────────────────────────────────────────
void showConfirmAddBoyDialog(
    BuildContext context,
    String eventId,
    String boyId,
    String boyName,
    EventDetailsProvider eventDetailsProvider,
    ) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_add_outlined,
                color: _kPrimary, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Confirm Assign',
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: _kTextMuted, fontSize: 14),
          children: [
            const TextSpan(text: 'Add '),
            TextSpan(
              text: boyName,
              style: const TextStyle(
                  color: _kPrimary, fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' to this work?'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel',
              style: TextStyle(color: _kTextMuted)),
        ),
        Consumer<EventDetailsProvider>(
          builder: (ctx, val, _) => val.addBoyBool
              ? const SizedBox(
              width: 80,
              child: Center(
                  child: CircularProgressIndicator(
                      color: _kPrimary, strokeWidth: 2)))
              : ElevatedButton(
            onPressed: () async {
              try {
                await eventDetailsProvider
                    .managerAssignBoyToEvent(eventId, boyId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$boyName added successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ));
                finish(context);
              } catch (e) {
                String msg = e.toString().replaceAll('Exception:', '').trim();
                if (msg.contains('Boy already added')) {
                  msg = 'This boy is already added';
                } else if (msg.contains('Already assigned')) {
                  msg = 'This boy already has this work';
                } else if (msg.contains('All slots filled')) {
                  msg = 'All required slots are already filled';
                } else if (msg.contains('Boy not found')) {
                  msg = 'Boy not found';
                } else {
                  msg = 'Something went wrong';
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(msg),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Boy',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}

// ─── Delete Boy Dialog ────────────────────────────────────────────────────────
void showDeleteBoyDialog(
    BuildContext context,
    String eventId,
    String boyId,
    String boyName,
    EventDetailsProvider provider,
    ) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_remove_outlined,
                color: Colors.red, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Remove Boy',
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: _kTextMuted, fontSize: 14),
          children: [
            const TextSpan(text: 'Remove '),
            TextSpan(
              text: boyName,
              style: const TextStyle(
                  color: _kTextDark, fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' from this work?'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel',
              style: TextStyle(color: _kTextMuted)),
        ),
        Consumer<EventDetailsProvider>(
          builder: (ctx, val, _) => val.removeBoyLoader
              ? const SizedBox(
              width: 80,
              child: Center(
                  child: CircularProgressIndicator(
                      color: Colors.red, strokeWidth: 2)))
              : ElevatedButton(
            onPressed: () async {
              await provider.removeBoyFromEvent(
                  eventId, boyId, context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$boyName removed from work'),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}

// ─── Select Captain Dialog ────────────────────────────────────────────────────
void showSelectCaptainDialog(
    BuildContext context,
    EventDetailsProvider provider,
    String eventId,
    ) {
  final searchController = TextEditingController();
  List filteredList = provider.confirmedBoysList;
  String? selectedBoyId = provider.siteCaptainId;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.star_outline_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Select Site Captain',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: _kTextDark),
                decoration: InputDecoration(
                  hintText: 'Search boys...',
                  hintStyle:
                  const TextStyle(color: _kTextMuted, fontSize: 13),
                  prefixIcon:
                  const Icon(Icons.search, color: _kPrimary, size: 20),
                  filled: true,
                  fillColor: _kBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: _kPrimary, width: 1.5),
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    filteredList = provider.confirmedBoysList
                        .where((boy) =>
                    boy.boyName
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                        boy.boyPhone.contains(query))
                        .toList();
                  });
                },
              ),
            ),

            // Boys list
            SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final boy = filteredList[index];
                  final isSelected = selectedBoyId == boy.boyId;

                  return GestureDetector(
                    onTap: () => setState(() => selectedBoyId = boy.boyId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _kPrimary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _kPrimary.withOpacity(0.4)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isSelected
                                ? _kPrimary
                                : Colors.grey.shade200,
                            child: Text(
                              boy.boyName[0].toUpperCase(),
                              style: TextStyle(
                                color:
                                isSelected ? Colors.white : _kTextMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(boy.boyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isSelected
                                          ? _kPrimary
                                          : _kTextDark,
                                    )),
                                Text(boy.boyPhone,
                                    style: const TextStyle(
                                        color: _kTextMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: _kPrimary, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (selectedBoyId == null || selectedBoyId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a captain first'),
                              behavior: SnackBarBehavior.floating));
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Confirm Captain',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: _kTextMuted, fontSize: 14),
                            children: [
                              const TextSpan(text: 'Assign '),
                              TextSpan(
                                text: filteredList
                                    .firstWhere(
                                        (b) => b.boyId == selectedBoyId)
                                    .boyName,
                                style: const TextStyle(
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w700),
                              ),
                              const TextSpan(text: ' as Site Captain?'),
                            ],
                          ),
                        ),
                        actionsPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: _kTextMuted)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              final selectedBoy = filteredList.firstWhere(
                                      (b) => b.boyId == selectedBoyId);
                              await provider.assignSiteCaptain(
                                boyId: selectedBoy.boyId,
                                boyName: selectedBoy.boyName,
                                currentEventId: eventId,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Assign',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.star_outline_rounded,
                      color: Colors.white, size: 18),
                  label: const Text('Save Captain',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Remove Captain Dialog ────────────────────────────────────────────────────
void showRemoveCaptainConfirmation(
    String eventID,
    BuildContext context,
    EventDetailsProvider provider,
    ) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star_border_rounded,
                color: Colors.red, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Remove Captain',
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: _kTextMuted, fontSize: 14),
          children: [
            const TextSpan(text: 'Remove '),
            TextSpan(
              text: provider.siteCaptainName,
              style: const TextStyle(
                  color: _kTextDark, fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' as site captain?'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Cancel',
              style: TextStyle(color: _kTextMuted)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await provider.removeSiteCaptain(eventID);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Site Captain removed'),
              behavior: SnackBarBehavior.floating,
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Remove',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}