import 'package:freezed_annotation/freezed_annotation.dart';

part 'canceled_works_model.freezed.dart';
part 'canceled_works_model.g.dart';

@freezed
class CanceledWorkModel with _$CanceledWorkModel {
  const factory CanceledWorkModel({
    required String eventId,
    required String eventName,
    required String status,
    required int eventDateTs,
  }) = _CanceledWorkModel;

  factory CanceledWorkModel.fromJson(Map<String, dynamic> json) =>
      _$CanceledWorkModelFromJson(json);
}
