part of 'onboarding_bloc.dart';

@freezed
sealed class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required List<OnboardingPage> pages,
    required int currentPageIndex,
    required bool isLoading,
    required bool isTransitioning,
    String? errorMessage,
    required bool shouldNavigateToAuth,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState(
    pages: [],
    currentPageIndex: 0,
    isLoading: true,
    isTransitioning: false,
    errorMessage: null,
    shouldNavigateToAuth: false,
  );
}

extension OnboardingStateX on OnboardingState {
  OnboardingPage? get currentPage =>
      pages.isNotEmpty && currentPageIndex < pages.length
          ? pages[currentPageIndex]
          : null;

  bool get isFirstPage => currentPageIndex == 0;
  bool get isLastPage => currentPageIndex == pages.length - 1;
  double get progress => pages.isEmpty ? 0 : (currentPageIndex + 1) / pages.length;
}