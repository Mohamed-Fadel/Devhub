import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/services/key_value_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final KeyValueStorage _keyValueStorage;

  AuthInterceptor(this._keyValueStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _keyValueStorage.get(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await _keyValueStorage.get(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken != null) {
        // Implement token refresh logic here
        // For now, we'll just clear the tokens
        await _keyValueStorage.delete(key: AppConstants.accessTokenKey);
        await _keyValueStorage.delete(key: AppConstants.refreshTokenKey);
      }
    }
    handler.next(err);
  }
}
