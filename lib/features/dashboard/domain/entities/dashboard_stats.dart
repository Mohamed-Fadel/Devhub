import 'package:freezed_annotation/freezed_annotation.dart';
import 'developer_metric.dart';

part 'dashboard_stats.freezed.dart';

@freezed
sealed class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required int totalProjects,
    required int totalFollowers,
    required int totalStars,
    required int totalCommits,
    required double weeklyGrowth,
    required DateTime lastUpdated,
    required Map<String, dynamic> githubStats,
    required List<DeveloperMetric> metrics,
  }) = _DashboardStats;
}