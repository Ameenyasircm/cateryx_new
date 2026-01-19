
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

Future<void> showAttendanceChoiceDialog({
  required BuildContext context,
  required String boyName,
  required Function(String status) onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mark Attendance'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Text('Mark attendance for $boyName'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm('PRESENT');
            },
            child: const Text('Present'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm('ABSENT');
            },
            child: const Text('Absent'),
          ),
        ],
      );
    },
  );
}


Future<void> showAddPaymentDialog({
  required BuildContext context,
  required String boyName,
  required Function(double amount) onSave,
}) {
  final TextEditingController controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Add Payment'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(boyName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee),
                hintText: 'Enter amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(controller.text.trim()) ?? 0;
              if (amount <= 0) return;

              Navigator.pop(context);
              onSave(amount);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

