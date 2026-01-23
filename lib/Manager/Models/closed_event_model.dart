class ClosedEventModel {
  final String eventId;
  final String eventName;
  final String eventDate;
  final String location;
  final String closedByName;
  final int boysRequired;

  ClosedEventModel({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    required this.location,
    required this.closedByName,
    required this.boysRequired,
  });

  factory ClosedEventModel.fromMap(Map<String, dynamic> map) {
    return ClosedEventModel(
      eventId: map['EVENT_ID'] ?? '',
      eventName: map['EVENT_NAME'] ?? '',
      eventDate: map['EVENT_DATE'] ?? '',
      location: map['LOCATION_NAME'] ?? '',
      closedByName: map['WORK_CLOSED_BY'] ?? '',
      boysRequired: (map['BOYS_REQUIRED'] ?? 0) is int
          ? map['BOYS_REQUIRED']
          : int.tryParse(map['BOYS_REQUIRED'].toString()) ?? 0,
    );
  }
}
