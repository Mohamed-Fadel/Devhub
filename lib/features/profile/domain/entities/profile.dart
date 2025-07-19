import 'package:freezed_annotation/freezed_annotation.dart';
import 'skill.dart';
import 'achievement.dart';
import 'github_stats.dart';

part 'profile.freezed.dart';

@freezed
sealed class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    String? bio,
    String? role,
    String? location,
    String? githubUsername,
    @Default([]) List<Skill> skills,
    @Default([]) List<Achievement> achievements,
    GithubStats? githubStats,
    DateTime? joinedDate,
    DateTime? lastUpdated,
  }) = _Profile;
}