import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/domain/vo/failures.dart';
import 'package:devhub/shared/domain/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

@injectable
class CompleteOnboardingUseCase implements UseCase<void, NoParams> {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.completeOnboarding();
  }
}