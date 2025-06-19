import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/routing/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo rotation and pulse animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start fade animation
    _fadeController.forward();

    // Start logo animation with delay
    await Future.delayed(AppConstants.mediumAnimation);
    _logoController.forward();

    // Wait for animations to complete, then navigate to main container
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateToMainContainer();
  }

  void _navigateToMainContainer() {
    if (mounted) {
      context.router.replacePath(RoutePaths.app);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_logoController, _fadeController]),
            builder: (context, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoAnimation.value * 2 * 3.14159,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.hub_outlined,
                              size: 60,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOutBack,
                        )),
                        child: Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceMD),

                    // Tagline
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.8),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOutBack,
                        )),
                        child: Text(
                          'Flutter Architecture Showcase',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceXXL),

                    // Loading Indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOutBack,
                        )),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceMD),

                    // Loading Text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Loading...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
