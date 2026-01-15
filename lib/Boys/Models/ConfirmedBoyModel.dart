import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmedBoyModel {
  final String boyId;
  final String boyName;
  final String boyPhone;
  final String status;
  final String attendanceStatus;
  final Timestamp? attendanceMarkedAt;
  final double paymentAmount;

  ConfirmedBoyModel({
    required this.boyId,
    required this.boyName,
    required this.boyPhone,
    required this.status,
    required this.attendanceStatus,
    this.attendanceMarkedAt,
    required this.paymentAmount,
  });

  factory ConfirmedBoyModel.fromMap(Map<String, dynamic> map) {
    return ConfirmedBoyModel(
      boyId: map['BOY_ID'] ?? '',
      boyName: map['BOY_NAME'] ?? '',
      boyPhone: map['BOY_PHONE'] ?? '',
      status: map['STATUS'] ?? '',
      attendanceStatus: map['ATTENDANCE_STATUS'] ?? 'PENDING',
      attendanceMarkedAt: map['ATTENDANCE_MARKED_AT'],
      paymentAmount: (map['PAYMENT_AMOUNT'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ConfirmedBoyModel copyWith({
    String? attendanceStatus,
    Timestamp? attendanceMarkedAt,
    double? paymentAmount,
  }) {
    return ConfirmedBoyModel(
      boyId: boyId,
      boyName: boyName,
      boyPhone: boyPhone,
      status: status,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      attendanceMarkedAt:
      attendanceMarkedAt ?? this.attendanceMarkedAt,
      paymentAmount: paymentAmount ?? this.paymentAmount,
    );
  }
}
