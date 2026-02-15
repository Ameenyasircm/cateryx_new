import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

class EventPaymentScreen extends StatelessWidget {
  final String eventId;

  const EventPaymentScreen({super.key, required this.eventId});

  // 📞 CALL
  void _callNumber(String number) {
    launchUrl(Uri.parse("tel:$number"));
  }

  // 🟢 WHATSAPP
  void _openWhatsApp(String number) {
    final url = Uri.parse("https://wa.me/$number");
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payments")),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 Filter only Present boys
          final presentBoys = provider.confirmedBoysList
              .where((boy) => boy.attendanceStatus.toLowerCase() == "present")
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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 Top Row (Avatar + Info + Actions)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        const CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.person, size: 28),
                        ),
                        const SizedBox(width: 12),

                        /// 🔹 Name + Phone + Wage
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                boy.boyName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${boy.boyPhone} • Present",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Wage: ₹${boy.wage}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        /// CALL
                        IconButton(
                          onPressed: () => _callNumber(boy.boyPhone),
                          icon: const Icon(Icons.call, color: Colors.green),
                        ),

                        /// WHATSAPP
                        IconButton(
                          onPressed: () => _openWhatsApp(boy.boyPhone),
                          icon: Image.asset(
                            'assets/whsp.png',
                            color: Colors.teal,
                            scale: 8,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 PAYMENT DETAILS SECTION
                    if (boy.paymentAmount > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Paid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Paid Amount"),
                                Text(
                                  "₹${boy.paymentAmount}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            /// Extra
                            if (boy.extraAmount > 0) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Extra Amount"),
                                  Text(
                                    "₹${boy.extraAmount}",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            /// Remark
                            if (boy.remark.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text("Remark: "),
                                  Expanded(
                                    child: Text(
                                      boy.remark,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 6),

                            /// Balance
                           if((boy.paymentAmount - boy.wage)>0)
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Extra"),
                                Text(
                                  "₹${(boy.paymentAmount - boy.wage).toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    /// 🔹 Payment Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showAddPaymentDialog(
                            context: context,
                            boyName: boy.boyName,
                            wage: boy.wage,
                            onSave: (amount, extraAmount, remark) async {
                              await provider.saveBoyPayment(
                                eventId: eventId,
                                boyId: boy.boyId,
                                amount: amount,
                                extraAmount: extraAmount,
                                remark: remark,
                                wage: boy.wage,
                              );

                              final total = amount + extraAmount;

                              showSuccessAlert(
                                context: context,
                                title: "Saved",
                                message:
                                "₹$total saved for ${boy.boyName}\nExtra: ₹$extraAmount",
                              );
                            },
                          );
                        },
                        child: Text(
                          boy.paymentAmount > 0
                              ? "Edit Payment"
                              : "Add Payment",
                          style: TextStyle(
                            color: boy.paymentAmount > 0
                                ? Colors.green
                                : Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
