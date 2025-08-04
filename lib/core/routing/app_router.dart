import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/routing/route_paths.dart';
import 'package:devhub/features/auth/routing/auth_router.dart';
import 'package:devhub/features/dashboard/presentation/routing/dashboard_router.dart';
import 'package:devhub/features/onboarding/routing/onboarding_router.dart';
import 'package:devhub/features/profile/routing/profile_router.dart';
import 'package:injectable/injectable.dart';

@AutoRouterConfig()
@injectable
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      path: RoutePaths.splash,
      initial: true,
    ),
    AutoRoute(
      page: MainContainerRoute.page,
      path: RoutePaths.app,
      children: [
        ...OnboardingRouter().routes,
        ...AuthRouter().routes,
        ...DashboardRouter().routes,
        ...ProfileRouter().routes
      ]
    ),
  ];
}