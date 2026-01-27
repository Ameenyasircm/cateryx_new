import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String eventName;
  final String eventDate;
  final Timestamp eventDateTs;
  final String mealType;
  final String locationName;
  final double latitude;
  final double longitude;
  final int boysRequired;
  final int boysTaken;
  final String description;
  final String eventStatus;
  final String status;
  final String onOffStatus;
  final Timestamp? createdTime;

  // 👉 NEW FIELDS
  final String clientName;
  final String clientPhone;

  EventModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.eventDateTs,
    required this.mealType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.boysRequired,
    required this.boysTaken,
    required this.description,
    required this.eventStatus,
    required this.status,
    required this.onOffStatus,
    this.createdTime,

    /// NEW
    required this.clientName,
    required this.clientPhone,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['EVENT_ID'] ?? '',
      eventName: map['EVENT_NAME'] ?? '',
      eventDate: map['EVENT_DATE'] ?? '',
      eventDateTs: map['EVENT_DATE_TS'] as Timestamp,
      mealType: map['MEAL_TYPE'] ?? '',
      locationName: map['LOCATION_NAME'] ?? '',
      latitude: (map['LATITUDE'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['LONGITUDE'] as num?)?.toDouble() ?? 0.0,
      boysRequired: (map['BOYS_REQUIRED'] as num?)?.toInt() ?? 0,
      boysTaken: (map['BOYS_TAKEN'] as num?)?.toInt() ?? 0,
      description: map['DESCRIPTION'] ?? '',
      eventStatus: map['EVENT_STATUS'] ?? '',
      status: map['STATUS'] ?? '',
      onOffStatus: map['WORK_ACTIVE_STATUS'] ?? '',
      createdTime: map['CREATED_TIME'] as Timestamp?,

      /// 👉 NEW FIELDS
      clientName: map['CLIENT_NAME'] ?? '',
      clientPhone: map['CLIENT_PHONE'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'EVENT_ID': eventId,
      'EVENT_NAME': eventName,
      'EVENT_DATE': eventDate,
      'EVENT_DATE_TS': eventDateTs,
      'MEAL_TYPE': mealType,
      'LOCATION_NAME': locationName,
      'LATITUDE': latitude,
      'LONGITUDE': longitude,
      'BOYS_REQUIRED': boysRequired,
      'BOYS_TAKEN': boysTaken,
      'DESCRIPTION': description,
      'EVENT_STATUS': eventStatus,
      'STATUS': status,
      'WORK_ACTIVE_STATUS': onOffStatus,
      'CREATED_TIME': createdTime ?? FieldValue.serverTimestamp(),

      /// 👉 NEW FIELDS
      'CLIENT_NAME': clientName,
      'CLIENT_PHONE': clientPhone,
    };
  }
}
