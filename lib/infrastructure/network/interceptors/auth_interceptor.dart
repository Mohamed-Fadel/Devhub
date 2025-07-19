import 'package:devhub/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken != null) {
        // Implement token refresh logic here
        // For now, we'll just clear the tokens
        await _secureStorage.delete(key: AppConstants.accessTokenKey);
        await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      }
    }
    handler.next(err);
  }
}
