import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/dependency_injection.dart';
import 'package:devhub/shared/presentation/widgets/loading_overlay.dart';
import 'package:devhub/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:devhub/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:devhub/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:devhub/features/onboarding/presentation/widgets/animated_background.dart';
import 'package:devhub/features/onboarding/presentation/widgets/skip_button.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _backgroundAnimationController;
  late final AnimationController _contentAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start initial animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _triggerContentAnimation() {
    _contentAnimationController.reverse().then((_) {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              getIt<OnboardingBloc>()..add(const OnboardingEvent.started()),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          // Handle navigation
          if (state.shouldNavigateToAuth) {
            context.router.replaceAll([const SignInRoute()]);
          }

          // Handle page transitions from bloc
          if (_pageController.hasClients &&
              state.currentPageIndex != _pageController.page?.round()) {
            _animateToPage(state.currentPageIndex);
            _triggerContentAnimation();
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final currentPage = state.currentPage;

          if (state.isLoading && state.pages.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    Text(
                      'Failed to load onboarding',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceLG),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OnboardingBloc>().add(
                          const OnboardingEvent.started(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: LoadingOverlay(
              isLoading: state.isLoading,
              child: Stack(
                children: [
                  // Animated Background
                  if (currentPage != null)
                    AnimatedBackground(
                      controller: _backgroundAnimationController,
                      primaryColor: currentPage.primaryColor,
                      secondaryColor: currentPage.secondaryColor,
                    ),

                  // Content
                  SafeArea(
                    child: Column(
                      children: [
                        // Skip Button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.spaceMD),
                            child: SkipButton(
                              onSkip:
                                  () => context.read<OnboardingBloc>().add(
                                    const OnboardingEvent.skipRequested(),
                                  ),
                              color:
                                  currentPage?.primaryColor ??
                                  theme.colorScheme.primary,
                            ),
                          ),
                        ),

                        // Main Content
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              context.read<OnboardingBloc>().add(
                                OnboardingEvent.pageChanged(index),
                              );
                            },
                            itemCount: state.pages.length,
                            itemBuilder: (context, index) {
                              final page = state.pages[index];
                              return OnboardingContent(
                                data: page,
                                animationController:
                                    _contentAnimationController,
                                isActive:
                                    index == state.currentPageIndex &&
                                    !state.isTransitioning,
                              );
                            },
                          ),
                        ),

                        // Bottom Controls
                        Container(
                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                          child: Column(
                            children: [
                              // Page Indicator
                              PageIndicator(
                                pageCount: state.pages.length,
                                currentPage: state.currentPageIndex,
                                color:
                                    currentPage?.primaryColor ??
                                    theme.colorScheme.primary,
                              ),

                              const SizedBox(height: AppConstants.spaceLG),

                              // Navigation Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Previous Button
                                  AnimatedOpacity(
                                    opacity: state.isFirstPage ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: IconButton(
                                      onPressed:
                                          state.isFirstPage
                                              ? null
                                              : () => context
                                                  .read<OnboardingBloc>()
                                                  .add(
                                                    const OnboardingEvent.previousPageRequested(),
                                                  ),
                                      icon: Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color:
                                            currentPage?.primaryColor ??
                                            theme.colorScheme.primary,
                                      ),
                                      iconSize: 28,
                                    ),
                                  ),

                                  // Next/Get Started Button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed:
                                          () => context.read<OnboardingBloc>().add(
                                            state.isLastPage
                                                ? const OnboardingEvent.completeRequested()
                                                : const OnboardingEvent.nextPageRequested(),
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            currentPage?.primaryColor ??
                                            theme.colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              state.isLastPage
                                                  ? AppConstants.spaceXL
                                                  : AppConstants.spaceLG,
                                          vertical: AppConstants.spaceMD,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: currentPage?.primaryColor
                                            .withOpacity(0.4),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Row(
                                          key: ValueKey(state.isLastPage),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              state.isLastPage
                                                  ? 'Get Started'
                                                  : 'Next',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(
                                              width: AppConstants.spaceSM,
                                            ),
                                            Icon(
                                              state.isLastPage
                                                  ? Icons.rocket_launch_rounded
                                                  : Icons
                                                      .arrow_forward_ios_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Spacer for alignment
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
