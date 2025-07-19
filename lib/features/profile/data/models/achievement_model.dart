import 'package:devhub/features/profile/domain/entities/achievement.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
sealed class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String title,
    required String description,
    required String icon,
    required DateTime earnedDate,
    AchievementType? type,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

  factory AchievementModel.fromEntity(Achievement achievement) =>
      AchievementModel(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        earnedDate: achievement.earnedDate,
        type: achievement.type,
      );
}

extension AchievementModelX on AchievementModel {
  Achievement toEntity() => Achievement(
    id: id,
    title: title,
    description: description,
    icon: icon,
    earnedDate: earnedDate,
    type: type,
  );
}