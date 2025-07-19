import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error or send to crash reporting service
    print('DioError: ${err.message}');
    handler.next(err);
  }
}