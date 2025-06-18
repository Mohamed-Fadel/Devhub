// Central place for all route paths to avoid conflicts
class RoutePaths {
  // Root paths
  static const String splash = '/';
  static const String auth = '/auth';
  static const String app = '/app';

  // Auth paths
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  // Dashboard paths
  static const String dashboard = '/dashboard';

  // Profile paths
  static const String profile = '/profile';
  static const String editProfile = '/edit';

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