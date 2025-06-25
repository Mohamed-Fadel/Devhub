import 'package:devhub/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:devhub/core/usecases/usecase.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';

part 'onboarding_bloc.freezed.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingPagesUseCase _getOnboardingPages;
  final CompleteOnboardingUseCase _completeOnboarding;

  OnboardingBloc(
      this._getOnboardingPages,
      this._completeOnboarding,
      ) : super(OnboardingState.initial()) {
    on<_Started>(_onStarted);
    on<_PageChanged>(_onPageChanged);
    on<_NextPageRequested>(_onNextPageRequested);
    on<_PreviousPageRequested>(_onPreviousPageRequested);
    on<_SkipRequested>(_onSkipRequested);
    on<_CompleteRequested>(_onCompleteRequested);
  }

  Future<void> _onStarted(_Started event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getOnboardingPages(NoParams());

    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
          (pages) => emit(state.copyWith(
        pages: result.getOrElse(() => []),
        isLoading: false,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onPageChanged(
      _PageChanged event,
      Emitter<OnboardingState> emit,
      ) async {
    if (event.pageIndex >= 0 && event.pageIndex < state.pages.length) {
      emit(state.copyWith(
        currentPageIndex: event.pageIndex,
        isTransitioning: false,
      ));
    }
  }

  Future<void> _onNextPageRequested(
      _NextPageRequested event,
      Emitter<OnboardingState> emit,
      ) async {
    if (state.isLastPage) {
      add(const OnboardingEvent.completeRequested());
    } else {
      emit(state.copyWith(isTransitioning: true));

      await Future.delayed(const Duration(milliseconds: 50));

      emit(state.copyWith(
        currentPageIndex: state.currentPageIndex + 1,
        isTransitioning: false,
      ));
    }
  }

  Future<void> _onPreviousPageRequested(
      _PreviousPageRequested event,
      Emitter<OnboardingState> emit,
      ) async {
    if (!state.isFirstPage) {
      emit(state.copyWith(isTransitioning: true));

      await Future.delayed(const Duration(milliseconds: 50));

      emit(state.copyWith(
        currentPageIndex: state.currentPageIndex - 1,
        isTransitioning: false,
      ));
    }
  }

  Future<void> _onSkipRequested(
      _SkipRequested event,
      Emitter<OnboardingState> emit,
      ) async {
    await _completeOnboardingFlow(emit);
  }

  Future<void> _onCompleteRequested(
      _CompleteRequested event,
      Emitter<OnboardingState> emit,
      ) async {
    await _completeOnboardingFlow(emit);
  }

  Future<void> _completeOnboardingFlow(Emitter<OnboardingState> emit) async {
    emit(state.copyWith(isLoading: true));

    final result = await _completeOnboarding(NoParams());

    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
          (_) => emit(state.copyWith(
        isLoading: false,
        shouldNavigateToAuth: true,
      )),
    );
  }
}