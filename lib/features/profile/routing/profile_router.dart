import 'package:auto_route/auto_route.dart';
import 'package:devhub/core/routing/app_router.gr.dart';
import 'package:devhub/core/routing/base_router.dart';
import 'package:devhub/core/routing/route_paths.dart';

class ProfileRouter implements BaseRouter {
  @override
  String get baseRoute => RoutePaths.app;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: ProfileRoute.page,
      path: RoutePaths.profile.lastSegment,
    ),
    AutoRoute(
      page: EditProfileRoute.page,
      path: RoutePaths.editProfile.lastSegment,
    ),
  ];
}