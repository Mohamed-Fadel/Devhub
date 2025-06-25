part of 'onboarding_bloc.dart';

@freezed
class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.started() = _Started;
  const factory OnboardingEvent.pageChanged(int pageIndex) = _PageChanged;
  const factory OnboardingEvent.nextPageRequested() = _NextPageRequested;
  const factory OnboardingEvent.previousPageRequested() = _PreviousPageRequested;
  const factory OnboardingEvent.skipRequested() = _SkipRequested;
  const factory OnboardingEvent.completeRequested() = _CompleteRequested;
}