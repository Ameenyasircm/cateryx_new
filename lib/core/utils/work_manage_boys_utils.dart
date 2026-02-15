
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
  required double wage,
  required Function(double amount, double extraAmount, String remark) onSave,
}) {
  final TextEditingController amountController =
  TextEditingController(text: wage.toStringAsFixed(0)); // 🔥 AUTO FILL

  final TextEditingController extraController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Payment'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                boyName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              /// 🔹 Wage Display
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Wage: ₹$wage",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Payment Amount (AUTO FILLED)
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Payment Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Extra Amount
              TextField(
                controller: extraController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Extra Amount (Optional)",
                  prefixIcon: Icon(Icons.add),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Remark
              TextField(
                controller: remarkController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Remark (Optional)",
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0;

              final extra =
                  double.tryParse(extraController.text.trim()) ?? 0;

              final remark = remarkController.text.trim();

              if (amount <= 0) return;

              Navigator.pop(context);
              onSave(amount, extra, remark);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


