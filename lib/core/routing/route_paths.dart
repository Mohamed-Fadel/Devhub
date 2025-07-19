// Central place for all route paths to avoid conflicts

typedef RoutePathe = String;

class RoutePaths {
  // Root paths
  static const String splash = '/';
  static const String auth = '/auth';
  static const String app = '/app';

  // Onboarding paths
  static const String onboarding = '/app/onboarding';

  // Auth paths
  static const String signIn = '/app/sign-in';
  static const String signUp = '/app/sign-up';
  static const String forgotPassword = '/app/forgot-password';

  // Dashboard paths
  static const String dashboard = '/app/dashboard';

  // Profile paths
  static const String profile = '/app/profile';
  static const String editProfile = '/app/profile/edit';

  // Projects paths
  static const String projects = '/projects';
  static const String projectDetail = '/:projectId';

  // Social paths
  static const String social = '/social';
  static const String chat = '/chat/:chatId';

  // Analytics paths
  static const String analytics = '/analytics';

  // Settings paths
  static const String settings = '/settings';
}

extension RoutePathX on String {
  /// Returns the last segment of the route path.
  String get lastSegment => split('/').last;
}