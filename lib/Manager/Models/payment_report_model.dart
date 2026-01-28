import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentReportModel {
  final String paymentId; // PAYMENT_REPORT docId
  final String eventId;
  final String boyId;

  final String eventName;
  final String eventDate;
  final String locationName;

  final String boyName;
  final String boyPhone;

  final double paymentAmount;
  final DateTime paymentUpdatedAt;

  PaymentReportModel({
    required this.paymentId,
    required this.eventId,
    required this.boyId,
    required this.eventName,
    required this.eventDate,
    required this.locationName,
    required this.boyName,
    required this.boyPhone,
    required this.paymentAmount,
    required this.paymentUpdatedAt,
  });

  factory PaymentReportModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentReportModel(
      paymentId: data['PAYMENT_ID']??"",
      eventId: data["EVENT_ID"] ?? "",
      boyId: data["BOY_ID"] ?? "",
      eventName: data["EVENT_NAME"] ?? "",
      eventDate: data["EVENT_DATE"] ?? "",
      locationName: data["LOCATION_NAME"] ?? "",
      boyName: data["BOY_NAME"] ?? "",
      boyPhone: data["BOY_PHONE"] ?? "",
      paymentAmount: data["PAYMENT_AMOUNT"] ?? 0,
      paymentUpdatedAt: (data["PAYMENT_UPDATED_AT"] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "PAYMENT_ID": paymentId,
      "EVENT_ID": eventId,
      "BOY_ID": boyId,
      "EVENT_NAME": eventName,
      "EVENT_DATE": eventDate,
      "LOCATION_NAME": locationName,
      "BOY_NAME": boyName,
      "BOY_PHONE": boyPhone,
      "PAYMENT_AMOUNT": paymentAmount,
      "PAYMENT_UPDATED_AT": Timestamp.fromDate(paymentUpdatedAt),
    };
  }
}

