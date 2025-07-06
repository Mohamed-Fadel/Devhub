import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:devhub/features/dashboard/domain/usecases/get_activity_feed.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_feed_notifier.freezed.dart';

@freezed
sealed class ActivityFeedState with _$ActivityFeedState {
  const factory ActivityFeedState({
    @Default([]) List<ActivityItem> activities,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(1) int currentPage,
    String? error,
  }) = _ActivityFeedState;
}

class ActivityFeedNotifier extends StateNotifier<ActivityFeedState> {
  final GetActivityFeed _getActivityFeed;
  static const int _pageSize = 20;

  ActivityFeedNotifier({
    required GetActivityFeed getActivityFeed,
  })  : _getActivityFeed = getActivityFeed,
        super(const ActivityFeedState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getActivityFeed(
      const ActivityFeedParams(page: 1, limit: _pageSize),
    );

    result.fold(
          (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
          (activities) => state = state.copyWith(
        isLoading: false,
        activities: activities,
        currentPage: 1,
        hasReachedEnd: activities.length < _pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _getActivityFeed(
      ActivityFeedParams(
        page: state.currentPage + 1,
        limit: _pageSize,
      ),
    );

    result.fold(
          (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      ),
          (activities) => state = state.copyWith(
        isLoadingMore: false,
        activities: [...state.activities, ...activities],
        currentPage: state.currentPage + 1,
        hasReachedEnd: activities.length < _pageSize,
      ),
    );
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  void markAsRead(String activityId) {
    state = state.copyWith(
      activities: state.activities.map((activity) {
        if (activity.id == activityId) {
          return activity.copyWith(isRead: true);
        }
        return activity;
      }).toList(),
    );
  }
}
