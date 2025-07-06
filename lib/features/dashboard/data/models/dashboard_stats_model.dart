import 'package:devhub/core/data/database/hive/hive_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:hive/hive.dart';
import 'developer_metric_model.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.developerStats)
sealed class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    @HiveField(0) required int totalProjects,
    @HiveField(1) required int totalFollowers,
    @HiveField(2) required int totalStars,
    @HiveField(3) required int totalCommits,
    @HiveField(4) required double weeklyGrowth,
    @HiveField(5) required DateTime lastUpdated,
    @HiveField(6) required Map<String, dynamic> githubStats,
    @HiveField(7) required List<DeveloperMetricModel> metrics,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
}

extension DashboardStatsModelX on DashboardStatsModel {
  DashboardStats toEntity() => DashboardStats(
    totalProjects: totalProjects,
    totalFollowers: totalFollowers,
    totalStars: totalStars,
    totalCommits: totalCommits,
    weeklyGrowth: weeklyGrowth,
    lastUpdated: lastUpdated,
    githubStats: githubStats,
    metrics: metrics.map((m) => m.toEntity()).toList(),
  );
}
