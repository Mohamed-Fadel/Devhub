import 'package:dartz/dartz.dart';
import 'package:devhub/core/error/failures.dart';
import 'package:devhub/features/onboarding/domain/entities/onboarding_page.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingPage>>> getOnboardingPages();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> isOnboardingCompleted();
}