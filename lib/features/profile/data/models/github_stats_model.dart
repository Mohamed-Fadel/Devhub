import 'package:devhub/core/data/database/hive_config.dart';
import 'package:devhub/features/profile/domain/entities/github_stats.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'github_stats_model.freezed.dart';
part 'github_stats_model.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.githubStats) // Use an appropriate type ID for your application
sealed class GithubStatsModel with _$GithubStatsModel {
  const factory GithubStatsModel({
    @HiveField(0) required int repositories,
    @HiveField(1) required int stars,
    @HiveField(2) required int followers,
    @HiveField(3) required int following,
    @HiveField(4) required int contributions,
    @HiveField(5) String? avatarUrl,
    @HiveField(6) String? profileUrl,
    @HiveField(7) @Default({}) Map<String, int>? languageStats,
    @HiveField(8) DateTime? lastFetched,
  }) = _GithubStatsModel;

  factory GithubStatsModel.fromJson(Map<String, dynamic> json) =>
      _$GithubStatsModelFromJson(json);

  factory GithubStatsModel.fromEntity(GithubStats stats) => GithubStatsModel(
    repositories: stats.repositories,
    stars: stats.stars,
    followers: stats.followers,
    following: stats.following,
    contributions: stats.contributions,
    avatarUrl: stats.avatarUrl,
    profileUrl: stats.profileUrl,
    languageStats: stats.languageStats,
    lastFetched: stats.lastFetched,
  );

  // factory GithubStatsModel.fromGithubApi(Map<String, dynamic> json) {
  //   return GithubStatsModel(
  //     repositories: json['public_repos'] ?? 0,
  //     stars: json['public_gists'] ?? 0, // This would need aggregation from repos
  //     followers: json['followers'] ?? 0,
  //     following: json['following'] ?? 0,
  //     contributions: 0, // Would need GraphQL API for contributions
  //     avatarUrl: json['avatar_url'],
  //     profileUrl: json['html_url'],
  //     lastFetched: DateTime.now(),
  //   );
  // }
}

extension GithubStatsModelX on GithubStatsModel {
  GithubStats toEntity() => GithubStats(
    repositories: repositories,
    stars: stars,
    followers: followers,
    following: following,
    contributions: contributions,
    avatarUrl: avatarUrl,
    profileUrl: profileUrl,
    languageStats: languageStats,
    lastFetched: lastFetched,
  );
}