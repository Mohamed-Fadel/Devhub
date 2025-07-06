import 'package:dartz/dartz.dart';
import 'package:devhub/core/domain/usecases/usecase.dart';
import 'package:devhub/core/network/error/failures.dart';
import 'package:devhub/features/dashboard/domain/entities/activity_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../repositories/dashboard_repository.dart';

part 'get_activity_feed.freezed.dart';

@injectable
class GetActivityFeed implements UseCase<List<ActivityItem>, ActivityFeedParams> {
  final DashboardRepository repository;

  GetActivityFeed(this.repository);

  @override
  Future<Either<Failure, List<ActivityItem>>> call(ActivityFeedParams params) async {
    return await repository.getActivityFeed(
      page: params.page,
      limit: params.limit,
    );
  }
}

@freezed
sealed class ActivityFeedParams with _$ActivityFeedParams {
  const factory ActivityFeedParams({
    required int page,
    @Default(20) int limit,
  }) = _ActivityFeedParams;
}