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
  final String description;
  final String eventStatus;
  final String status;
  final Timestamp? createdTime;

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
    required this.description,
    required this.eventStatus,
    required this.status,
    this.createdTime,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['EVENT_ID'] as String? ?? '',
      eventName: map['EVENT_NAME'] as String? ?? '',
      eventDate: map['EVENT_DATE'] as String? ?? '',
      eventDateTs: map['EVENT_DATE_TS'] as Timestamp,
      mealType: map['MEAL_TYPE'] as String? ?? '',
      locationName: map['LOCATION_NAME'] as String? ?? '',
      latitude: (map['LATITUDE'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['LONGITUDE'] as num?)?.toDouble() ?? 0.0,
      boysRequired: (map['BOYS_REQUIRED'] as num?)?.toInt() ?? 0,
      description: map['DESCRIPTION'] as String? ?? '',
      eventStatus: map['EVENT_STATUS'] as String? ?? '',
      status: map['STATUS'] as String? ?? '',
      createdTime: map['CREATED_TIME'] as Timestamp?,
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
      'DESCRIPTION': description,
      'EVENT_STATUS': eventStatus,
      'STATUS': status,
      'CREATED_TIME': createdTime ?? FieldValue.serverTimestamp(),
    };
  }
}
