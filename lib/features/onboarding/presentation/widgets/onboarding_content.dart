import 'package:devhub/features/onboarding/domain/entities/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:devhub/core/constants/app_constants.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingPage data;
  final AnimationController animationController;
  final bool isActive;

  const OnboardingContent({
    super.key,
    required this.data,
    required this.animationController,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6),
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation/Illustration
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  height: size.height * 0.35,
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // SVG Background
                        SvgPicture.asset(
                          data.imagePath,
                          height: size.height * 0.3,
                          colorFilter: ColorFilter.mode(
                            data.primaryColor.withOpacity(0.1),
                            BlendMode.srcIn,
                          ),
                        ),

                      // Lottie Animation Overlay
                      if (data.animationPath != null && isActive)
                        Lottie.asset(
                          data.animationPath!,
                          height: size.height * 0.35,
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: isActive,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceXL),

          // Title
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
              )),
              child: Text(
                data.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: data.primaryColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Subtitle
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
              )),
              child: Text(
                data.subtitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: data.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Description
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
              )),
              child: Text(
                data.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Feature Pills
          if (data.features.isNotEmpty)
            FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                )),
                child: Wrap(
                  spacing: AppConstants.spaceSM,
                  runSpacing: AppConstants.spaceSM,
                  alignment: WrapAlignment.center,
                  children: data.features.map((feature) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(
                        milliseconds: 300 + (data.features.indexOf(feature) * 100),
                      ),
                      tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceMD,
                              vertical: AppConstants.spaceSM,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  data.primaryColor.withOpacity(0.2),
                                  data.secondaryColor.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: data.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              feature,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: data.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}