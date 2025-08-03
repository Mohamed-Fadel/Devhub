import 'package:devhub/core/services/key_value_storage.dart';
import 'package:injectable/injectable.dart';
import '../models/onboarding_page_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingPageModel>> getOnboardingPages();
  Future<void> setOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
}

@LazySingleton(as: OnboardingLocalDataSource)
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final KeyValueStorage _keyValueStorage;
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _firstTimeKey = 'first_time_user';

  OnboardingLocalDataSourceImpl(this._keyValueStorage);

  @override
  Future<List<OnboardingPageModel>> getOnboardingPages() async {
    // In a real app, this might come from a local JSON file or remote config
    return [
      const OnboardingPageModel(
        id: 'welcome',
        title: 'Welcome to DevHub',
        subtitle: 'Your Ultimate Flutter Architecture Showcase',
        description: 'Experience the power of clean architecture, modern patterns, and production-ready code in one comprehensive app.',
        imagePath: 'assets/images/onboarding/welcome.png',
        animationPath: 'assets/animations/onboarding/welcome_animation.json',
        primaryColorValue: 0xFF6366F1,
        secondaryColorValue: 0xFF8B5CF6,
        features: [
          'Clean Architecture',
          'Multiple State Management',
          'Production Ready',
        ],
      ),
      const OnboardingPageModel(
        id: 'patterns',
        title: 'Multiple Patterns',
        subtitle: 'Learn by Example',
        description: 'Explore BLoC, Riverpod, Provider, and custom state management solutions all in one place.',
        imagePath: 'assets/images/onboarding/patterns.png',
        animationPath: 'assets/animations/onboarding/patterns_animation.json',
        primaryColorValue: 0xFF10B981,
        secondaryColorValue: 0xFF34D399,
        features: [
          'BLoC Pattern',
          'Riverpod',
          'Provider',
          'Custom Solutions',
        ],
      ),
      const OnboardingPageModel(
        id: 'production',
        title: 'Production Ready',
        subtitle: 'Built for Excellence',
        description: 'Complete with testing, CI/CD, error handling, and performance optimizations for real-world applications.',
        imagePath: 'assets/images/onboarding/production.png',
        animationPath: 'assets/animations/onboarding/production_animation.json',
        primaryColorValue: 0xFFF59E0B,
        secondaryColorValue: 0xFFFBBF24,
        features: [
          'Unit & Widget Tests',
          'CI/CD Pipeline',
          'Error Boundaries',
          'Performance Optimized',
        ],
      ),
    ];
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _keyValueStorage.put(
      key: _onboardingCompletedKey,
      value: 'true',
    );
    await _keyValueStorage.put(
      key: _firstTimeKey,
      value: 'false',
    );
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final completed = await _keyValueStorage.get(key: _onboardingCompletedKey);
    return completed == 'true';
  }
}