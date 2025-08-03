import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/domain/vo/failures.dart';
import 'package:devhub/shared/domain/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class RefreshDashboard implements UseCase<void, NoParams> {
  final DashboardRepository repository;

  RefreshDashboard(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.refreshDashboard();
  }
}
