import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/dashboard_stats_model.dart';
import '../models/activity_item_model.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheDashboardStats(DashboardStatsModel stats);
  Future<DashboardStatsModel?> getCachedDashboardStats();
  Future<void> cacheActivityFeed(List<ActivityItemModel> activities);
  Future<List<ActivityItemModel>> getCachedActivityFeed();
  Future<void> clearCache();
}

@LazySingleton(as: DashboardLocalDataSource)
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  static const String _dashboardBox = 'dashboard_box';
  static const String _statsKey = 'dashboard_stats';
  static const String _activitiesKey = 'activity_feed';

  @override
  Future<void> cacheDashboardStats(DashboardStatsModel stats) async {
    final box = await Hive.openBox(_dashboardBox);
    await box.put(_statsKey, stats.toJson());
  }

  @override
  Future<DashboardStatsModel?> getCachedDashboardStats() async {
    final box = await Hive.openBox(_dashboardBox);
    final json = box.get(_statsKey);
    if (json != null) {
      return DashboardStatsModel.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  @override
  Future<void> cacheActivityFeed(List<ActivityItemModel> activities) async {
    final box = await Hive.openBox(_dashboardBox);
    final jsonList = activities.map((a) => a.toJson()).toList();
    await box.put(_activitiesKey, jsonList);
  }

  @override
  Future<List<ActivityItemModel>> getCachedActivityFeed() async {
    final box = await Hive.openBox(_dashboardBox);
    final jsonList = box.get(_activitiesKey, defaultValue: []);
    return (jsonList as List)
        .map((json) => ActivityItemModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    final box = await Hive.openBox(_dashboardBox);
    await box.clear();
  }
}