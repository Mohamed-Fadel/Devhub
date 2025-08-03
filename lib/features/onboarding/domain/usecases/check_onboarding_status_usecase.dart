import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/domain/vo/failures.dart';
import 'package:devhub/shared/domain/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

@injectable
class CheckOnboardingStatusUseCase implements UseCase<bool, NoParams> {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isOnboardingCompleted();
  }
}