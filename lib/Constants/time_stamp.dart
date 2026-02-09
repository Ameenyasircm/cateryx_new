import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<Timestamp?, Object?> {
  const TimestampConverter();

  @override
  Timestamp? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json;
    return null;
  }

  @override
  Object? toJson(Timestamp? object) {
    return object;
  }
}
