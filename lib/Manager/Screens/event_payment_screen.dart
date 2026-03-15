import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/alert_utils.dart';
import '../../core/utils/work_manage_boys_utils.dart';
import '../Providers/EventDetailProvider.dart';

// ─── App Color Palette ──────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF1A237E); // deep indigo — MAIN
const _kAccent    = Color(0xFFFF5722); // orange-red  — secondary highlights
const _kBg        = Color(0xFFF8F9FB); // off-white background
const _kCardBg    = Colors.white;
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF9E9E9E);
// ───────────────────────────────────────────────────────────────────────────────

class EventPaymentScreen extends StatelessWidget {
  final String eventId;

  const EventPaymentScreen({super.key, required this.eventId});

  void _callNumber(String number) => launchUrl(Uri.parse("tel:$number"));

  void _openWhatsApp(String number) =>
      launchUrl(Uri.parse("https://wa.me/$number"),
          mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      // ─── App Bar ───────────────────────────────────────────────────────────
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
          'Payments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }

          final presentBoys = provider.confirmedBoysList
              .where(
                  (boy) => boy.attendanceStatus.toLowerCase() == 'present')
              .toList();

          if (presentBoys.isEmpty) {
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
                    child: const Icon(Icons.payments_outlined,
                        color: _kPrimary, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No present boys for payment',
                    style: TextStyle(
                      color: _kTextMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: presentBoys.length,
            itemBuilder: (context, index) {
              final boy = presentBoys[index];
              final bool isPaid = boy.paymentAmount > 0;
              final double balance = boy.paymentAmount - boy.wage;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Band ──────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.withOpacity(0.06)
                            : _kPrimary.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isPaid
                                    ? [
                                  Colors.green.shade400,
                                  Colors.green.shade600
                                ]
                                    : [
                                  const Color(0xFF1A237E),
                                  const Color(0xFF283593),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 12),

                          // Name + phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  boy.boyName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _kTextDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 12, color: _kTextMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      boy.boyPhone,
                                      style: const TextStyle(
                                          fontSize: 12, color: _kTextMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Payment status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? Colors.green.withOpacity(0.12)
                                  : _kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPaid ? 'Paid' : 'Pending',
                              style: TextStyle(
                                color: isPaid ? Colors.green : _kPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Body ─────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wage row
                          _summaryRow(
                            icon: Icons.work_outline,
                            label: 'Wage',
                            value: '₹${boy.wage}',
                            valueColor: _kPrimary,
                          ),

                          // Payment details if paid
                          if (isPaid) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade200, width: 1),
                              ),
                              child: Column(
                                children: [
                                  _paymentDetailRow(
                                    label: 'Paid Amount',
                                    value: '₹${boy.paymentAmount}',
                                    valueColor: Colors.green,
                                  ),
                                  if (boy.extraAmount > 0) ...[
                                    _thinDivider(),
                                    _paymentDetailRow(
                                      label: 'Extra Amount',
                                      value: '₹${boy.extraAmount}',
                                      valueColor: _kAccent,
                                    ),
                                  ],
                                  if (boy.remark.isNotEmpty) ...[
                                    _thinDivider(),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.notes_outlined,
                                            size: 14, color: _kTextMuted),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Remark: ',
                                          style: TextStyle(
                                              color: _kTextMuted,
                                              fontSize: 13),
                                        ),
                                        Expanded(
                                          child: Text(
                                            boy.remark,
                                            style: const TextStyle(
                                              color: _kTextDark,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (balance > 0) ...[
                                    _thinDivider(),
                                    _paymentDetailRow(
                                      label: 'Extra Paid',
                                      value:
                                      '₹${balance.toStringAsFixed(0)}',
                                      valueColor: _kPrimary,
                                      bold: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Bottom: Call / WhatsApp / Payment button
                          Row(
                            children: [
                              _iconChip(
                                icon: Icons.call,
                                color: Colors.green,
                                onTap: () => _callNumber(boy.boyPhone),
                              ),
                              const SizedBox(width: 8),
                              _iconChip(
                                assetIcon: 'assets/whsp.png',
                                color: const Color(0xFF00897B),
                                onTap: () => _openWhatsApp(boy.boyPhone),
                              ),
                              const Spacer(),

                              // Payment CTA
                              GestureDetector(
                                onTap: () {
                                  showAddPaymentDialog(
                                    context: context,
                                    boyName: boy.boyName,
                                    wage: boy.wage,
                                    onSave: (amount, extraAmount,
                                        remark) async {
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
                                        title: 'Saved',
                                        message:
                                        '₹$total saved for ${boy.boyName}\nExtra: ₹$extraAmount',
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPaid
                                          ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ]
                                          : [
                                        const Color(0xFF1A237E),
                                        const Color(0xFF283593),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isPaid
                                            ? Colors.green
                                            : _kPrimary)
                                            .withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPaid
                                            ? Icons.edit_outlined
                                            : Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isPaid
                                            ? 'Edit Payment'
                                            : 'Add Payment',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
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
          );
        },
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kTextMuted),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: _kTextMuted, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _paymentDetailRow({
    required String label,
    required String value,
    required Color valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: _kTextMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() =>
      Divider(height: 12, thickness: 1, color: Colors.grey.shade200);

  Widget _iconChip({
    IconData? icon,
    String? assetIcon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
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