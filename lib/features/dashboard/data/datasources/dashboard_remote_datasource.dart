import 'package:devhub/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/dashboard_stats_model.dart';
import '../models/activity_item_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<ActivityItemModel>> getActivityFeed({
    required int page,
    required int limit,
  });
  Future<void> markActivityAsRead(String activityId);
}

@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final HttpClient _apiClient;

  DashboardRemoteDataSourceImpl(@Named('hostHttpClient') this._apiClient);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/dashboard/stats');
      return DashboardStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<ActivityItemModel>> getActivityFeed({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiClient.get(
        '/dashboard/activity',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return (response.data['items'] as List)
          .map((item) => ActivityItemModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markActivityAsRead(String activityId) async {
    try {
      await _apiClient.patch('/dashboard/activity/$activityId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      return Exception(error.response?.data['message'] ?? 'Server error');
    }
    return Exception('Network error');
  }
}
