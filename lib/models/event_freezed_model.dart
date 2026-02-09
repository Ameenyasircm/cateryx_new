import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../Constants/time_stamp.dart';

part 'event_freezed_model.freezed.dart';
part 'event_freezed_model.g.dart';

@freezed
class EventFreezedModel with _$EventFreezedModel {
  const factory EventFreezedModel({
    @JsonKey(name: 'EVENT_ID') @Default('') String eventId,
    @JsonKey(name: 'EVENT_NAME') @Default('') String eventName,
    @JsonKey(name: 'EVENT_DATE') @Default('') String eventDate,

    /// FIXED: Add Timestamp converter
    @TimestampConverter()
    @JsonKey(name: 'EVENT_DATE_TS')
    Timestamp? eventDateTs,

    @JsonKey(name: 'MEAL_TYPE') @Default('') String mealType,
    @JsonKey(name: 'LOCATION_NAME') @Default('') String locationName,
    @JsonKey(name: 'LATITUDE') @Default(0.0) double latitude,
    @JsonKey(name: 'LONGITUDE') @Default(0.0) double longitude,
    @JsonKey(name: 'BOYS_REQUIRED') @Default(0) int boysRequired,
    @JsonKey(name: 'BOYS_TAKEN') @Default(0) int boysTaken,
    @JsonKey(name: 'DESCRIPTION') @Default('') String description,
    @JsonKey(name: 'EVENT_STATUS') @Default('') String eventStatus,
    @JsonKey(name: 'STATUS') @Default('') String status,
    @JsonKey(name: 'WORK_ACTIVE_STATUS') @Default('') String onOffStatus,

    /// FIXED: Timestamp converter for optional timestamp
    @TimestampConverter()
    @JsonKey(name: 'CREATED_TIME')
    Timestamp? createdTime,

    @JsonKey(name: 'CLIENT_NAME') @Default('') String clientName,
    @JsonKey(name: 'CLIENT_PHONE') @Default('') String clientPhone,
  }) = _EventFreezedModel;

  factory EventFreezedModel.fromJson(Map<String, dynamic> json) =>
      _$EventFreezedModelFromJson(json);
}
