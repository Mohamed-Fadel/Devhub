import 'package:devhub/features/dashboard/domain/entities/developer_metric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:devhub/core/dependency_injection.dart';
import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:devhub/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:devhub/features/dashboard/domain/usecases/get_activity_feed.dart';
import 'package:devhub/features/dashboard/domain/usecases/refresh_dashboard.dart';
import 'dashboard_state_notifier.dart';
import 'activity_feed_notifier.dart';

// Dashboard Stats Provider
final dashboardStatsProvider = StateNotifierProvider<DashboardStateNotifier, AsyncValue<DashboardStats>>(
      (ref) => DashboardStateNotifier(
    getDashboardStats: getIt<GetDashboardStats>(),
    refreshDashboard: getIt<RefreshDashboard>(),
  ),
);

// Activity Feed Provider
final activityFeedProvider = StateNotifierProvider<ActivityFeedNotifier, ActivityFeedState>(
      (ref) => ActivityFeedNotifier(
    getActivityFeed: getIt<GetActivityFeed>(),
  ),
);

// Selected Metric Provider
final selectedMetricProvider = StateProvider<MetricType?>((ref) => null);

// Dashboard Refresh Provider
final dashboardRefreshProvider = FutureProvider<void>((ref) async {
  await ref.read(dashboardStatsProvider.notifier).refresh();
  await ref.read(activityFeedProvider.notifier).refresh();
});