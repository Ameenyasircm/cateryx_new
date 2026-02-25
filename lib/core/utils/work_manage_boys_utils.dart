
import 'package:flutter/material.dart';


Color attendanceColor(String status) {
  switch (status) {
    case 'PRESENT':
      return Colors.green;
    case 'ABSENT':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }


}


Future<void> confirmAttendance({
  required BuildContext context,
  required VoidCallback onConfirm,
  required String title,
}) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm Attendance'),
      content: Text(title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}


// ─── Color Palette ─────────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1A237E);
const _kBg        = Color(0xFFF8F9FB);
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF9E9E9E);
const _kAccent    = Color(0xFFFF5722);
// ───────────────────────────────────────────────────────────────────────────────

Future<void> showAttendanceChoiceDialog({
  required BuildContext context,
  required String boyName,
  required Function(String status) onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.how_to_reg_outlined,
                        color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mark Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close,
                          color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),

            // ── Boy Name ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: _kPrimary.withOpacity(0.09),
                    child: Text(
                      boyName[0].toUpperCase(),
                      style: const TextStyle(
                        color: _kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          boyName,
                          style: const TextStyle(
                            color: _kTextDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Select attendance status below',
                          style: TextStyle(
                              color: _kTextMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Action Buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  // Present
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm('PRESENT');
                      },
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Mark as Present',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Absent
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm('ABSENT');
                      },
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Mark as Absent',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Cancel
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: _kTextMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}


Future<void> showAddPaymentDialog({
  required BuildContext context,
  required String boyName,
  required double wage,
  required Function(double amount, double extraAmount, String remark) onSave,
}) {
  final amountController =
  TextEditingController(text: wage.toStringAsFixed(0));
  final extraController  = TextEditingController();
  final remarkController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
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
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.payments_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          boyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wage chip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _kPrimary.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.work_outline,
                              size: 16, color: _kPrimary),
                          const SizedBox(width: 8),
                          const Text(
                            'Wage:',
                            style: TextStyle(
                                color: _kTextMuted, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${wage.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: _kPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Amount
                    _label('Payment Amount'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: amountController,
                      hint: 'Enter amount',
                      icon: Icons.currency_rupee,
                      type: TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    // Extra Amount
                    _label('Extra Amount'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: extraController,
                      hint: 'Optional',
                      icon: Icons.add_circle_outline,
                      type: TextInputType.number,
                      accentColor: _kAccent,
                    ),

                    const SizedBox(height: 14),

                    // Remark
                    _label('Remark'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: remarkController,
                      hint: 'Optional note',
                      icon: Icons.sticky_note_2_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Actions ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                            color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: _kTextMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(
                            amountController.text.trim()) ??
                            0;
                        final extra = double.tryParse(
                            extraController.text.trim()) ??
                            0;
                        final remark = remarkController.text.trim();
                        if (amount <= 0) return;
                        Navigator.pop(context);
                        onSave(amount, extra, remark);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined,
                              color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Save Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

Widget _label(String text) {
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
  TextInputType type = TextInputType.text,
  int maxLines = 1,
  Color accentColor = _kPrimary,
}) {
  return TextField(
    controller: controller,
    keyboardType: type,
    maxLines: maxLines,
    style: const TextStyle(color: _kTextDark, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kTextMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: accentColor, size: 20),
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
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
    ),
  );
}


