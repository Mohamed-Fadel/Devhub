import 'dart:async';

import 'package:devhub/infrastructure/network/interceptors/log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'log_interceptor_test.mocks.dart';

@GenerateMocks([
  RequestInterceptorHandler,
  ResponseInterceptorHandler,
  ErrorInterceptorHandler,
  RequestOptions,
  Response,
  DioException,
])

void main() {
  late LoggingInterceptor loggingInterceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockResponseInterceptorHandler mockResponseHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUp(() {
    loggingInterceptor = LoggingInterceptor();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockResponseHandler = MockResponseInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
  });

  group('LoggingInterceptor', () {
    group('onRequest', () {
      test('should log GET request and call handler.next', () {
        // Arrange
        final options = RequestOptions(
          path: '/api/users',
          method: 'GET',
        );

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onRequest(options, mockRequestHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'REQUEST[GET] => PATH: /api/users');
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should log POST request with different path', () {
        // Arrange
        final options = RequestOptions(
          path: '/api/auth/login',
          method: 'POST',
        );

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onRequest(options, mockRequestHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'REQUEST[POST] => PATH: /api/auth/login');
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should handle all HTTP methods', () {
        // Test all common HTTP methods
        final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];

        for (final method in methods) {
          // Arrange
          final options = RequestOptions(
            path: '/api/test',
            method: method,
          );

          // Capture print output
          final printOutput = <String>[];
          final spec = ZoneSpecification(
            print: (_, __, ___, String message) {
              printOutput.add(message);
            },
          );

          // Act
          Zone.current.fork(specification: spec).run(() {
            loggingInterceptor.onRequest(options, mockRequestHandler);
          });

          // Assert
          expect(printOutput.length, 1);
          expect(printOutput[0], 'REQUEST[$method] => PATH: /api/test');
          verify(mockRequestHandler.next(options)).called(1);

          // Reset mock for next iteration
          reset(mockRequestHandler);
        }
      });

      test('should handle empty path', () {
        // Arrange
        final options = RequestOptions(
          path: '',
          method: 'GET',
        );

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onRequest(options, mockRequestHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'REQUEST[GET] => PATH: ');
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should handle paths with query parameters', () {
        // Arrange
        final options = RequestOptions(
          path: '/api/users?page=1&limit=10',
          method: 'GET',
        );

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onRequest(options, mockRequestHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'REQUEST[GET] => PATH: /api/users?page=1&limit=10');
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should handle special characters in path', () {
        // Arrange
        final options = RequestOptions(
          path: '/api/users/@john/profile#info',
          method: 'GET',
        );

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onRequest(options, mockRequestHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'REQUEST[GET] => PATH: /api/users/@john/profile#info');
        verify(mockRequestHandler.next(options)).called(1);
      });
    });

    group('onResponse', () {
      test('should log successful response with status 200', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
        when(mockRequestOptions.path).thenReturn('/api/users');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onResponse(mockResponse, mockResponseHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'RESPONSE[200] => PATH: /api/users');
        verify(mockResponseHandler.next(mockResponse)).called(1);
      });

      test('should handle various HTTP status codes', () {
        // Test various status codes
        final statusCodes = [200, 201, 204, 301, 302, 400, 401, 403, 404, 500, 502, 503];

        for (final statusCode in statusCodes) {
          // Arrange
          final mockRequestOptions = MockRequestOptions();
          final mockResponse = MockResponse();

          when(mockResponse.statusCode).thenReturn(statusCode);
          when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
          when(mockRequestOptions.path).thenReturn('/api/test');

          // Capture print output
          final printOutput = <String>[];
          final spec = ZoneSpecification(
            print: (_, __, ___, String message) {
              printOutput.add(message);
            },
          );

          // Act
          Zone.current.fork(specification: spec).run(() {
            loggingInterceptor.onResponse(mockResponse, mockResponseHandler);
          });

          // Assert
          expect(printOutput.length, 1);
          expect(printOutput[0], 'RESPONSE[$statusCode] => PATH: /api/test');
          verify(mockResponseHandler.next(mockResponse)).called(1);

          // Reset mock for next iteration
          reset(mockResponseHandler);
        }
      });

      test('should handle null status code', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();

        when(mockResponse.statusCode).thenReturn(null);
        when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
        when(mockRequestOptions.path).thenReturn('/api/users');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onResponse(mockResponse, mockResponseHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'RESPONSE[null] => PATH: /api/users');
        verify(mockResponseHandler.next(mockResponse)).called(1);
      });

      test('should handle empty path in response', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
        when(mockRequestOptions.path).thenReturn('');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onResponse(mockResponse, mockResponseHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'RESPONSE[200] => PATH: ');
        verify(mockResponseHandler.next(mockResponse)).called(1);
      });
    });

    group('onError', () {
      test('should log error with status code', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();
        final mockDioException = MockDioException();

        when(mockDioException.response).thenReturn(mockResponse);
        when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
        when(mockResponse.statusCode).thenReturn(404);
        when(mockRequestOptions.path).thenReturn('/api/users/123');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'ERROR[404] => PATH: /api/users/123');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle error with null response', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockDioException = MockDioException();

        when(mockDioException.response).thenReturn(null);
        when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
        when(mockRequestOptions.path).thenReturn('/api/timeout');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'ERROR[null] => PATH: /api/timeout');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle various error status codes', () {
        // Test various error status codes
        final errorCodes = [400, 401, 403, 404, 409, 422, 500, 502, 503];

        for (final errorCode in errorCodes) {
          // Arrange
          final mockRequestOptions = MockRequestOptions();
          final mockResponse = MockResponse();
          final mockDioException = MockDioException();

          when(mockDioException.response).thenReturn(mockResponse);
          when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
          when(mockResponse.statusCode).thenReturn(errorCode);
          when(mockRequestOptions.path).thenReturn('/api/error');

          // Capture print output
          final printOutput = <String>[];
          final spec = ZoneSpecification(
            print: (_, __, ___, String message) {
              printOutput.add(message);
            },
          );

          // Act
          Zone.current.fork(specification: spec).run(() {
            loggingInterceptor.onError(mockDioException, mockErrorHandler);
          });

          // Assert
          expect(printOutput.length, 1);
          expect(printOutput[0], 'ERROR[$errorCode] => PATH: /api/error');
          verify(mockErrorHandler.next(mockDioException)).called(1);

          // Reset mock for next iteration
          reset(mockErrorHandler);
        }
      });

      test('should handle error with empty path', () {
        // Arrange
        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();
        final mockDioException = MockDioException();

        when(mockDioException.response).thenReturn(mockResponse);
        when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
        when(mockResponse.statusCode).thenReturn(500);
        when(mockRequestOptions.path).thenReturn('');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          loggingInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'ERROR[500] => PATH: ');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });
    });

    group('constructor', () {
      test('should create instance successfully', () {
        // Act
        final interceptor = LoggingInterceptor();

        // Assert
        expect(interceptor, isNotNull);
        expect(interceptor, isA<LoggingInterceptor>());
        expect(interceptor, isA<Interceptor>());
      });
    });

    group('integration scenarios', () {
      test('should handle complete request-response cycle', () {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/api/users',
          method: 'POST',
        );

        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();

        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.requestOptions).thenReturn(mockRequestOptions);
        when(mockRequestOptions.path).thenReturn('/api/users');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          // Simulate request
          loggingInterceptor.onRequest(requestOptions, mockRequestHandler);
          // Simulate response
          loggingInterceptor.onResponse(mockResponse, mockResponseHandler);
        });

        // Assert
        expect(printOutput.length, 2);
        expect(printOutput[0], 'REQUEST[POST] => PATH: /api/users');
        expect(printOutput[1], 'RESPONSE[201] => PATH: /api/users');
        verify(mockRequestHandler.next(requestOptions)).called(1);
        verify(mockResponseHandler.next(mockResponse)).called(1);
      });

      test('should handle complete request-error cycle', () {
        // Arrange
        final requestOptions = RequestOptions(
          path: '/api/users/999',
          method: 'DELETE',
        );

        final mockRequestOptions = MockRequestOptions();
        final mockResponse = MockResponse();
        final mockDioException = MockDioException();

        when(mockDioException.response).thenReturn(mockResponse);
        when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
        when(mockResponse.statusCode).thenReturn(404);
        when(mockRequestOptions.path).thenReturn('/api/users/999');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          // Simulate request
          loggingInterceptor.onRequest(requestOptions, mockRequestHandler);
          // Simulate error
          loggingInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 2);
        expect(printOutput[0], 'REQUEST[DELETE] => PATH: /api/users/999');
        expect(printOutput[1], 'ERROR[404] => PATH: /api/users/999');
        verify(mockRequestHandler.next(requestOptions)).called(1);
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });
    });
  });
}