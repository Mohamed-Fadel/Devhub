import 'package:auto_route/auto_route.dart';

import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/routing/base_router.dart';
import 'package:devhub/core/routing/route_paths.dart';

class AuthRouter implements BaseRouter {
  @override
  String get baseRoute => RoutePaths.app;

  @override
  List<AutoRoute> get routes =>
      [
        AutoRoute(
            page: SignInRoute.page,
            path: RoutePaths.signIn.lastSegment
        ),
        AutoRoute(page: SignUpRoute.page, path: RoutePaths.signUp.lastSegment),
        // AutoRoute(page: ForgotPasswordRoute.page, path: RoutePaths.forgotPassword),
      ];
}
