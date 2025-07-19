import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';

@freezed
sealed class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required DateTime earnedDate,
    AchievementType? type,
  }) = _Achievement;
}

enum AchievementType { contribution, milestone, certification, special }
