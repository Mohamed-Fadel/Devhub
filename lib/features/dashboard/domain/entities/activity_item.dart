import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';

enum ActivityType {
  projectCreated,
  projectUpdated,
  newFollower,
  githubActivity,
  achievement,
  collaboration,
}

@freezed
sealed class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String id,
    required ActivityType type,
    required String title,
    required String description,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
    required bool isRead,
  }) = _ActivityItem;
}