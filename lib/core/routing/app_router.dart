import 'package:auto_route/auto_route.dart';
import 'package:devhub/features/auth/presentation/routing/auth_router.dart';
import 'package:injectable/injectable.dart';

@AutoRouterConfig()
@injectable
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    ...AuthRouter().routes
  ];
}