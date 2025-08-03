import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/services/key_value_storage.dart';
import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/infrastructure/network/dio_client.dart';
import 'package:devhub/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:devhub/infrastructure/network/interceptors/error_interceptor.dart';
import 'package:devhub/infrastructure/network/interceptors/log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @Named('host')
  @lazySingleton
  Dio dioHost(KeyValueStorage keyValueStorage) {
    return Dio()
      ..options.baseUrl = '${AppConstants.baseUrl}/${AppConstants.apiVersion}'
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.addAll([
        AuthInterceptor(keyValueStorage),
        ErrorInterceptor(),
        LoggingInterceptor(),
      ]);
  }

  @Named('github')
  @factoryMethod
  Dio dioGithub() {
    return Dio()
      ..options.baseUrl = AppConstants.githubBaseUrl
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3+json',
      };
  }

  @Named('githubHttpClient')
  @factoryMethod
  HttpClient githubHttpClient(@Named('github') Dio dio) => DioClient(dio);

  @Named('hostHttpClient')
  @lazySingleton
  HttpClient hostHttpClient(@Named('host') Dio dio) => DioClient(dio);

  @lazySingleton
  Connectivity connectivity() => Connectivity();
}
