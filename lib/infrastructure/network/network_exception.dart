import 'package:dio/dio.dart';

enum NetworkExceptionType {
  connectionTimeout,
  sendTimeout,
  receiveTimeout,
  badCertificate,
  badResponse,
  cancel,
  connectionError,
  unknown,
}

class NetworkException implements Exception {
  final NetworkExceptionType type;
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? headers;
  final dynamic data;
  final StackTrace? stackTrace;

  const NetworkException({
    required this.type,
    required this.message,
    required this.data,
    this.statusCode,
    this.headers,
    this.code,
    this.stackTrace,
  });

  factory NetworkException.fromDioException(DioException dioException) {
    NetworkExceptionType type;
    String message;
    int? statusCode;
    Map<String, dynamic>? headers;
    dynamic data;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        type = NetworkExceptionType.connectionTimeout;
        message = 'Connection timeout occurred';
        break;
      case DioExceptionType.sendTimeout:
        type = NetworkExceptionType.sendTimeout;
        message = 'Send timeout occurred';
        break;
      case DioExceptionType.receiveTimeout:
        type = NetworkExceptionType.receiveTimeout;
        message = 'Receive timeout occurred';
        break;
      case DioExceptionType.badCertificate:
        type = NetworkExceptionType.badCertificate;
        message = 'Bad certificate encountered';
        break;
      case DioExceptionType.badResponse:
        type = NetworkExceptionType.badResponse;
        statusCode = dioException.response?.statusCode;
        headers = dioException.response?.headers.map;
        data = dioException.response?.data;
        message = _getMessageFromStatusCode(statusCode) ??
            dioException.response?.statusMessage ??
            'Bad response received';
        break;
      case DioExceptionType.cancel:
        type = NetworkExceptionType.cancel;
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        type = NetworkExceptionType.connectionError;
        message = 'Connection error occurred';
        break;
      case DioExceptionType.unknown:
        type = NetworkExceptionType.unknown;
        message = dioException.message ?? 'An unknown error occurred';
        break;
    }

    // Extract additional error details from response if available
    if (dioException.response?.data != null) {
      final responseData = dioException.response!.data;
      if (responseData is Map<String, dynamic>) {
        // Common API error response patterns
        message = responseData['message'] ??
            responseData['error'] ??
            responseData['error_description'] ??
            message;
      }
    }

    return NetworkException(
      message: message,
      type: type,
      statusCode: statusCode,
      headers: headers,
      code: dioException.response?.statusCode?.toString(),
      data: data,
      stackTrace: dioException.stackTrace,
    );
  }

  static String? _getMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 408:
        return 'Request timeout';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable entity';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      case 504:
        return 'Gateway timeout';
      default:
        return null;
    }
  }

  @override
  String toString() => 'NetworkException: $message (Type: ${type.name}, StatusCode: $statusCode)';
}