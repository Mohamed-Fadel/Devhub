import 'package:dartz/dartz.dart';
import 'package:devhub/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/network/error/failures.dart';
import 'package:devhub/core/domain/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}