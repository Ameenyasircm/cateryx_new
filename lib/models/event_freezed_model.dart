import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String eventId;
  String eventName;
  String eventDate;
  Timestamp? eventDateTs;
  String mealType;
  String locationName;
  double latitude;
  double longitude;
  int boysRequired;
  int boysTaken;
  String description;
  String eventStatus;
  String status;
  String onOffStatus;
  Timestamp? createdTime;
  String clientName;
  String clientPhone;

  EventModel({
    this.eventId = '',
    this.eventName = '',
    this.eventDate = '',
    this.eventDateTs,
    this.mealType = '',
    this.locationName = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.boysRequired = 0,
    this.boysTaken = 0,
    this.description = '',
    this.eventStatus = '',
    this.status = '',
    this.onOffStatus = '',
    this.createdTime,
    this.clientName = '',
    this.clientPhone = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['EVENT_ID'] ?? '',
      eventName: json['EVENT_NAME'] ?? '',
      eventDate: json['EVENT_DATE'] ?? '',
      eventDateTs: json['EVENT_DATE_TS'] as Timestamp?,
      mealType: json['MEAL_TYPE'] ?? '',
      locationName: json['LOCATION_NAME'] ?? '',
      latitude: (json['LATITUDE'] ?? 0.0).toDouble(),
      longitude: (json['LONGITUDE'] ?? 0.0).toDouble(),
      boysRequired: json['BOYS_REQUIRED'] ?? 0,
      boysTaken: json['BOYS_TAKEN'] ?? 0,
      description: json['DESCRIPTION'] ?? '',
      eventStatus: json['EVENT_STATUS'] ?? '',
      status: json['STATUS'] ?? '',
      onOffStatus: json['WORK_ACTIVE_STATUS'] ?? '',
      createdTime: json['CREATED_TIME'] as Timestamp?,
      clientName: json['CLIENT_NAME'] ?? '',
      clientPhone: json['CLIENT_PHONE'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
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
      'CREATED_TIME': createdTime,
      'CLIENT_NAME': clientName,
      'CLIENT_PHONE': clientPhone,
    };
  }
}
