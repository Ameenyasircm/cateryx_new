import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmedBoyModel {
  final String boyId;
  final String boyName;
  final String boyPhone;
  final Timestamp confirmedAt;
  final String status;

  ConfirmedBoyModel({
    required this.boyId,
    required this.boyName,
    required this.boyPhone,
    required this.confirmedAt,
    required this.status,
  });

  factory ConfirmedBoyModel.fromMap(Map<String, dynamic> map) {
    return ConfirmedBoyModel(
      boyId: map['BOY_ID'] ?? '',
      boyName: map['BOY_NAME'] ?? '',
      boyPhone: map['BOY_PHONE'] ?? '',
      confirmedAt: map['CONFIRMED_AT'],
      status: map['STATUS'] ?? '',
    );
  }
}
