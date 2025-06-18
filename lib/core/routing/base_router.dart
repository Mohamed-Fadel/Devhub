import 'package:auto_route/auto_route.dart';

abstract class BaseRouter {
  List<AutoRoute> get routes;
  String get baseRoute;
}
