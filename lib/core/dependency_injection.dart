import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hive/hive.dart';

import 'dependency_injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Initialize Hive boxes
  await Hive.openBox('app_settings');
  await Hive.openBox('user_data');
  await Hive.openBox('cache');

  getIt.init();
}
