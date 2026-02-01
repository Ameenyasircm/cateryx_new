import 'package:cloud_firestore/cloud_firestore.dart';

class ClosedEventModel {
  final String eventId;
  final String eventName;
  final String eventDate;
  final String location;
  final String closedByName;
  final int boysRequired;
  final String mealType;
  final String locationName;
  final double latitude;
  final double longitude;
  final int boysTaken;
  final String description;
  final String eventStatus;

  /// ✅ new
  final DateTime closedTime;

  ClosedEventModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.location,
    required this.closedByName,
    required this.boysRequired,
    required this.mealType,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.boysTaken,
    required this.description,
    required this.eventStatus,

    /// ✅ new
    required this.closedTime,
  });

  factory ClosedEventModel.fromMap(Map<String, dynamic> map) {
    final dynamic closedTimeRaw = map['CLOSED_TIME'];

    DateTime parsedClosedTime = DateTime.fromMillisecondsSinceEpoch(0);

    if (closedTimeRaw is Timestamp) {
      parsedClosedTime = closedTimeRaw.toDate();
    } else if (closedTimeRaw is DateTime) {
      parsedClosedTime = closedTimeRaw;
    } else if (closedTimeRaw != null) {
      // fallback if stored as string/number
      parsedClosedTime = DateTime.tryParse(closedTimeRaw.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ClosedEventModel(
      eventId: map['EVENT_ID'] ?? '',
      eventName: map['EVENT_NAME'] ?? '',
      eventDate: map['EVENT_DATE'] ?? '',
      location: map['LOCATION_NAME'] ?? '',
      closedByName: map['WORK_CLOSED_BY'] ?? '',
      boysRequired: (map['BOYS_REQUIRED'] ?? 0) is int
          ? map['BOYS_REQUIRED']
          : int.tryParse(map['BOYS_REQUIRED'].toString()) ?? 0,
      mealType: map['MEAL_TYPE'] as String? ?? '',
      locationName: map['LOCATION_NAME'] as String? ?? '',
      latitude: (map['LATITUDE'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['LONGITUDE'] as num?)?.toDouble() ?? 0.0,
      boysTaken: (map['BOYS_TAKEN'] as num?)?.toInt() ?? 0,
      description: map['DESCRIPTION'] as String? ?? '',
      eventStatus: map['EVENT_STATUS'] as String? ?? '',

      /// ✅ new
      closedTime: parsedClosedTime,
    );
  }
}

