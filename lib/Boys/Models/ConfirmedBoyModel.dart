import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmedBoyModel {
  final String boyId;
  final String boyName;
  final String boyPhone;
  final String status;

  final String attendanceStatus;
  final Timestamp? attendanceMarkedAt;

  final double paymentAmount;
  final double extraAmount;
  final double wage;

  final String remark;
  final String photo;

  ConfirmedBoyModel({
    required this.boyId,
    required this.boyName,
    required this.boyPhone,
    required this.status,
    required this.attendanceStatus,
    this.attendanceMarkedAt,
    required this.paymentAmount,
    required this.extraAmount,
    required this.wage,
    required this.remark,
    required this.photo,
  });

  /// 🔹 From Firestore Map
  factory ConfirmedBoyModel.fromMap(Map<String, dynamic> map) {
    return ConfirmedBoyModel(
      boyId: map['BOY_ID'] ?? '',
      boyName: map['BOY_NAME'] ?? '',
      boyPhone: map['BOY_PHONE'] ?? '',
      status: map['STATUS'] ?? '',
      attendanceStatus: map['ATTENDANCE_STATUS'] ?? 'PENDING',
      attendanceMarkedAt: map['ATTENDANCE_MARKED_AT'] as Timestamp?,
      paymentAmount:
      (map['PAYMENT_AMOUNT'] as num?)?.toDouble() ?? 0.0,
      extraAmount:
      (map['EXTRA_AMOUNT'] as num?)?.toDouble() ?? 0.0,
      wage: (map['WAGE'] as num?)?.toDouble() ?? 0.0,
      remark: map['REMARK'] ?? '',
      photo: map['BOY_PHOTO_URL'] ?? '',
    );
  }

  /// 🔹 CopyWith for local updates
  ConfirmedBoyModel copyWith({
    String? attendanceStatus,
    Timestamp? attendanceMarkedAt,
    double? paymentAmount,
    double? extraAmount,
    double? wage,
    String? remark,
  }) {
    return ConfirmedBoyModel(
      boyId: boyId,
      boyName: boyName,
      boyPhone: boyPhone,
      status: status,
      attendanceStatus:
      attendanceStatus ?? this.attendanceStatus,
      attendanceMarkedAt:
      attendanceMarkedAt ?? this.attendanceMarkedAt,
      paymentAmount:
      paymentAmount ?? this.paymentAmount,
      extraAmount:
      extraAmount ?? this.extraAmount,
      wage: wage ?? this.wage,
      remark: remark ?? this.remark,
      photo: photo ?? this.photo,
    );
  }

  /// 🔹 Convert to Map (optional but useful)
  Map<String, dynamic> toMap() {
    return {
      "BOY_ID": boyId,
      "BOY_NAME": boyName,
      "BOY_PHONE": boyPhone,
      "STATUS": status,
      "ATTENDANCE_STATUS": attendanceStatus,
      "ATTENDANCE_MARKED_AT": attendanceMarkedAt,
      "PAYMENT_AMOUNT": paymentAmount,
      "EXTRA_AMOUNT": extraAmount,
      "WAGE": wage,
      "REMARK": remark,
      'BOY_PHOTO_URL':photo
    };
  }
}
