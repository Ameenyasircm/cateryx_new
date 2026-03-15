import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Color Palette ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1A237E);
const _kAccent    = Color(0xFFFF5722);
const _kBg        = Color(0xFFF8F9FB);
const _kCardBg    = Colors.white;
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF9E9E9E);
// ───────────────────────────────────────────────────────────────────────────────

class NotesScreen extends StatefulWidget {
  final String eventId;

  const NotesScreen({super.key, required this.eventId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventDetailsProvider>(context, listen: false)
        .listenNotes(widget.eventId);
  }

  void _showAddNoteDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.sticky_note_2_outlined,
                        color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),

            // ── Fields ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Title'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: titleCtrl,
                    hint: 'Enter note title',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel('Description'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: descCtrl,
                    hint: 'Write your note here...',
                    icon: Icons.description_outlined,
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Actions ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: _kTextMuted, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (titleCtrl.text.trim().isNotEmpty &&
                            descCtrl.text.trim().isNotEmpty) {
                          Provider.of<EventDetailsProvider>(context,
                              listen: false)
                              .addNewNote(
                            eventId: widget.eventId,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      icon: const Icon(Icons.save_outlined,
                          color: Colors.white, size: 18),
                      label: const Text('Save Note',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventDetailsProvider>(context);

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
          'Event Notes',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                '${provider.notesList.length} notes',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        backgroundColor: _kPrimary,
        elevation: 3,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Note',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: provider.notesList.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sticky_note_2_outlined,
                  color: _kPrimary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('No notes yet',
                style: TextStyle(
                    color: _kTextMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            const Text('Tap the button below to add one',
                style: TextStyle(color: _kTextMuted, fontSize: 13)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: provider.notesList.length,
        itemBuilder: (ctx, i) {
          final note = provider.notesList[i];
          final createdAt =
          DateTime.fromMillisecondsSinceEpoch(note.createdTime);
          final dateStr =
              '${createdAt.day.toString().padLeft(2, '0')}/'
              '${createdAt.month.toString().padLeft(2, '0')}/'
              '${createdAt.year}  '
              '${createdAt.hour.toString().padLeft(2, '0')}:'
              '${createdAt.minute.toString().padLeft(2, '0')}';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.sticky_note_2_outlined,
                            color: _kPrimary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Note index badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${i + 1}',
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Description + timestamp
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.description,
                        style: const TextStyle(
                          color: _kTextDark,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: _kTextMuted),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: _kTextMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────
Widget _fieldLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      color: _kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  );
}

Widget _inputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  int minLines = 1,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    minLines: minLines,
    maxLines: maxLines,
    style: const TextStyle(color: _kTextDark, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: _kPrimary, size: 20),
      filled: true,
      fillColor: _kBg,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPrimary, width: 1.5),
      ),
    ),
  );
}