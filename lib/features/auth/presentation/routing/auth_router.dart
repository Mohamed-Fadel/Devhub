import 'package:auto_route/auto_route.dart';

import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/routing/base_router.dart';
import 'package:devhub/core/routing/route_paths.dart';

class AuthRouter implements BaseRouter {
  @override
  String get baseRoute => RoutePaths.auth;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SignInRoute.page,
      path: RoutePaths.signIn,
      initial: true, // Default auth route
    ),
    // AutoRoute(page: SignUpRoute.page, path: RoutePaths.signUp),
    // AutoRoute(page: ForgotPasswordRoute.page, path: RoutePaths.forgotPassword),
  ];
}
