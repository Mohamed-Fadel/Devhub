import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item_model.freezed.dart';
part 'activity_item_model.g.dart';

@freezed
sealed class ActivityItemModel with _$ActivityItemModel {
  const factory ActivityItemModel({
    required String id,
    required ActivityType type,
    required String title,
    required String description,
    String? imageUrl,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
    required bool isRead,
  }) = _ActivityItemModel;

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemModelFromJson(json);
}

extension ActivityItemModelX on ActivityItemModel {
  ActivityItem toEntity() => ActivityItem(
    id: id,
    type: type,
    title: title,
    description: description,
    imageUrl: imageUrl,
    timestamp: timestamp,
    metadata: metadata,
    isRead: isRead,
  );
}