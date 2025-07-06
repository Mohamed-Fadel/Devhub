import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/infrastructure/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Register external dependencies
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<HttpClient>(() => DioClient(getIt<Dio>(), getIt<FlutterSecureStorage>()));
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
}
