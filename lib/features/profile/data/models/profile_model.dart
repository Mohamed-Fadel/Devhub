import 'package:devhub/core/data/database/hive/hive_config.dart';
import 'package:devhub/features/profile/domain/entities/profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'achievement_model.dart';
import 'github_stats_model.dart';
import 'skill_model.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.profile)// Use an appropriate type ID for your application
sealed class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String email,
    @HiveField(3) String? avatarUrl,
    @HiveField(4) String? bio,
    @HiveField(5) String? role,
    @HiveField(6) String? location,
    @HiveField(7) String? githubUsername,
    @HiveField(8) @Default([]) List<SkillModel> skills,
    @HiveField(9) @Default([]) List<AchievementModel> achievements,
    @HiveField(10) GithubStatsModel? githubStats,
    @HiveField(11) DateTime? joinedDate,
    @HiveField(12) DateTime? lastUpdated,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  factory ProfileModel.fromEntity(Profile profile) => ProfileModel(
    id: profile.id,
    name: profile.name,
    email: profile.email,
    avatarUrl: profile.avatarUrl,
    bio: profile.bio,
    role: profile.role,
    location: profile.location,
    githubUsername: profile.githubUsername,
    skills: profile.skills.map((s) => SkillModel.fromEntity(s)).toList(),
    achievements: profile.achievements
        .map((a) => AchievementModel.fromEntity(a))
        .toList(),
    githubStats: profile.githubStats != null
        ? GithubStatsModel.fromEntity(profile.githubStats!)
        : null,
    joinedDate: profile.joinedDate,
    lastUpdated: profile.lastUpdated,
  );
}

extension ProfileModelX on ProfileModel {
  Profile toEntity() => Profile(
    id: id,
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    bio: bio,
    role: role,
    location: location,
    githubUsername: githubUsername,
    skills: skills.map((s) => s.toEntity()).toList(),
    achievements: achievements.map((a) => a.toEntity()).toList(),
    githubStats: githubStats?.toEntity(),
    joinedDate: joinedDate,
    lastUpdated: lastUpdated,
  );
}