import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

class EventAllBoys extends StatelessWidget {
  final String eventId;

  const EventAllBoys({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Assigned Boys'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.confirmedBoysList.isEmpty) {
            return const Center(child: Text('No boys assigned'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.confirmedBoysList.length,
            itemBuilder: (context, index) {
              final boy = provider.confirmedBoysList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 HEADER
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                boy.boyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                boy.boyPhone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🟢 Attendance Chip
                        GestureDetector(
                          onTap: () {
                            showAttendanceChoiceDialog(
                              context: context,
                              boyName: boy.boyName,
                              onConfirm: (status) async {
                                SharedPreferences prefs =
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
                          child: Chip(
                            label: Text(boy.attendanceStatus),
                            backgroundColor:
                            attendanceColor(boy.attendanceStatus)
                                .withOpacity(0.15),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// 💰 PAYMENT STATUS + ADD BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 18,
                              color: boy.paymentAmount > 0
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              boy.paymentAmount > 0
                                  ? '₹${boy.paymentAmount} added'
                                  : 'Payment not added',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: boy.paymentAmount > 0
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        TextButton(
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
                                  title: 'Saved',
                                  message:
                                  '₹$amount saved for ${boy.boyName}',
                                );
                              },
                            );
                          },
                          child: const Text('Add Payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
