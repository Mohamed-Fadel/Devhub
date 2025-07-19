import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/core/network/error/exceptions.dart';
import 'package:dio/dio.dart';

class DioClient implements HttpClient {
  final Dio _dio;

  DioClient(this._dio);

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return DioApiResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return DioApiResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ApiResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return DioApiResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ApiResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return DioApiResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ApiResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return DioApiResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(message: 'Connection timeout');
        case DioExceptionType.connectionError:
          return const NetworkException(message: 'No internet connection');
        case DioExceptionType.badResponse:
          return _handleResponseError(error);
        case DioExceptionType.cancel:
          return const NetworkException(message: 'Request cancelled');
        default:
          return NetworkException(message: error.message ?? 'Unknown error');
      }
    }
    return NetworkException(message: error.toString());
  }

  Exception _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data['message'] ?? 'Server error';

    return switch (statusCode) {
      401 => AuthenticationException(message: message),
      403 => AuthorizationException(message: message),
      int code when code >= 400 && code < 500 => ValidationException(
        message: message,
      ),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }
}

class DioApiResponse implements ApiResponse {
  final Response _response;

  DioApiResponse(this._response);

  @override
  int? get statusCode => _response.statusCode;

  @override
  dynamic get data => _response.data;

  @override
  Map<String, dynamic>? get headers => _response.headers.map;
}
