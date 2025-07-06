import 'package:dartz/dartz.dart';
import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/network/error/exceptions.dart';
import 'package:devhub/core/network/error/failures.dart';
import 'package:devhub/core/network/network_info.dart';
import 'package:devhub/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../datasources/dashboard_local_datasource.dart';
import '../models/activity_item_model.dart';
import '../models/dashboard_stats_model.dart';

@Injectable(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final DashboardLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  DashboardRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final remoteStats = await _remoteDataSource.getDashboardStats();
          await _localDataSource.cacheDashboardStats(remoteStats);
          return Right(remoteStats.toEntity());
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        try {
          final localStats = await _localDataSource.getCachedDashboardStats();
          if (localStats != null) {
            return Right(localStats.toEntity());
          }
          return const Left(CacheFailure(message: 'No cached data available'));
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActivityItem>>> getActivityFeed({
    required int page,
    required int limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        try {
          final activities = await _remoteDataSource.getActivityFeed(
            page: page,
            limit: limit,
          );

          if (page == 1) {
            await _localDataSource.cacheActivityFeed(activities);
          }

          return Right(activities.map((a) => a.toEntity()).toList());
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        if (page == 1) {
          try {
            final cachedActivities =
                await _localDataSource.getCachedActivityFeed();
            return Right(cachedActivities.map((a) => a.toEntity()).toList());
          } on CacheException catch (e) {
            return Left(CacheFailure(message: e.message));
          }
        }
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markActivityAsRead(String activityId) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.markActivityAsRead(activityId);
        return const Right(null);
      }
      return const Left(NetworkFailure(message: 'No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> refreshDashboard() async {
    try {
      if (await _networkInfo.isConnected) {
        await _localDataSource.clearCache();
        return const Right(null);
      }
      return const Left(NetworkFailure(message: 'No internet connection'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // @override
  // Stream<DashboardStats> watchDashboardStats() {
  //   // This would connect to a WebSocket or other real-time data source
  //   return Stream.periodic(
  //     const Duration(seconds: 30),
  //         (_) async {
  //       final result = await getDashboardStats();
  //       return result.fold(
  //             (failure) => throw Exception(failure.message),
  //             (stats) => stats,
  //       );
  //     },
  //   ).asyncMap((event) => event);
  // }
  //
  // @override
  // Stream<List<ActivityItem>> watchActivityFeed() {
  //   // This would connect to a WebSocket or other real-time data source
  //   return Stream.periodic(
  //     const Duration(seconds: 10),
  //         (_) async {
  //       final result = await getActivityFeed(page: 1, limit: 20);
  //       return result.fold(
  //             (failure) => throw Exception(failure.message),
  //             (activities) => activities,
  //       );
  //     },
  //   ).asyncMap((event) => event);
  // }
}
