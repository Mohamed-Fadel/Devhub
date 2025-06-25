import 'package:dartz/dartz.dart';
import 'package:devhub/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/error/failures.dart';
import 'package:devhub/core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

@injectable
class GetOnboardingPagesUseCase implements UseCase<List<OnboardingPage>, NoParams> {
  final OnboardingRepository repository;

  GetOnboardingPagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnboardingPage>>> call(NoParams params) async {
    return await repository.getOnboardingPages();
  }
}