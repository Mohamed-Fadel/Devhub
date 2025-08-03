import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:devhub/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:devhub/features/dashboard/domain/usecases/refresh_dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub/shared/domain/usecases/usecase.dart';

class DashboardStateNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final GetDashboardStats _getDashboardStats;
  final RefreshDashboard _refreshDashboard;

  DashboardStateNotifier({
    required GetDashboardStats getDashboardStats,
    required RefreshDashboard refreshDashboard,
  })  : _getDashboardStats = getDashboardStats,
        _refreshDashboard = refreshDashboard,
        super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();

    final result = await _getDashboardStats(NoParams());

    result.fold(
          (failure) => state = AsyncValue.error(failure, StackTrace.current),
          (stats) => state = AsyncValue.data(stats),
    );
  }

  Future<void> refresh() async {
    final result = await _refreshDashboard(NoParams());

    result.fold(
          (failure) => state = AsyncValue.error(failure, StackTrace.current),
          (_) => loadDashboard(),
    );
  }
}