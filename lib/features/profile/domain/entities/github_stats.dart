import 'package:freezed_annotation/freezed_annotation.dart';

part 'github_stats.freezed.dart';

@freezed
sealed class GithubStats with _$GithubStats {
  const factory GithubStats({
    required int repositories,
    required int stars,
    required int followers,
    required int following,
    required int contributions,
    String? avatarUrl,
    String? profileUrl,
    Map<String, int>? languageStats,
    DateTime? lastFetched,
  }) = _GithubStats;
}