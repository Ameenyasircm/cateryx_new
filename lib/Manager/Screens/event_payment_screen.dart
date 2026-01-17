import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

class EventPaymentScreen extends StatelessWidget {
  final String eventId;

  const EventPaymentScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payments")),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 FILTER: Only Present boys
          final presentBoys = provider.confirmedBoysList
              .where((boy) =>
          boy.attendanceStatus.toLowerCase() == "present")
              .toList();

          if (presentBoys.isEmpty) {
            return const Center(
              child: Text(
                "No Present boys to show for payment",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: presentBoys.length,
            itemBuilder: (context, index) {
              final boy = presentBoys[index];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(boy.boyName),
                subtitle: Text("${boy.boyPhone} • Present"),

                trailing: TextButton(
                  onPressed: () {
                    showAddPaymentDialog(
                      context: context,
                      boyName: boy.boyName,
                      onSave: (amount) async {
                        await provider.saveBoyPayment(
                          eventId: eventId,
                          boyId: boy.boyId,
                          amount: amount,
                        );

                        showSuccessAlert(
                          context: context,
                          title: "Saved",
                          message: "₹$amount added for ${boy.boyName}",
                        );
                      },
                    );
                  },
                  child: Text(
                    boy.paymentAmount > 0
                        ? "₹${boy.paymentAmount}"
                        : "Add Payment",
                    style: TextStyle(
                      color: boy.paymentAmount > 0 ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
