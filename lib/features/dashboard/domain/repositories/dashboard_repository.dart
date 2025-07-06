import 'package:dartz/dartz.dart';
import 'package:devhub/core/network/error/failures.dart';
import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, List<ActivityItem>>> getActivityFeed({
    required int page,
    required int limit,
  });
  Future<Either<Failure, void>> markActivityAsRead(String activityId);
  Future<Either<Failure, void>> refreshDashboard();
  // Stream<DashboardStats> watchDashboardStats();
  // Stream<List<ActivityItem>> watchActivityFeed();
}
