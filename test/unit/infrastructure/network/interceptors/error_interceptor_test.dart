import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:devhub/infrastructure/network/interceptors/error_interceptor.dart';

@GenerateMocks([
  ErrorInterceptorHandler,
  DioException,
  RequestOptions,
  Response,
])
import 'error_interceptor_test.mocks.dart';

void main() {
  late ErrorInterceptor errorInterceptor;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUp(() {
    errorInterceptor = ErrorInterceptor();
    mockErrorHandler = MockErrorInterceptorHandler();
  });

  group('ErrorInterceptor', () {
    group('onError', () {
      test('should log error message and call handler.next', () {
        // Arrange
        final mockDioException = MockDioException();
        const errorMessage = 'Network connection failed';

        when(mockDioException.message).thenReturn(errorMessage);

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: $errorMessage');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle null error message', () {
        // Arrange
        final mockDioException = MockDioException();
        when(mockDioException.message).thenReturn(null);

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: null');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle empty error message', () {
        // Arrange
        final mockDioException = MockDioException();
        when(mockDioException.message).thenReturn('');

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: ');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle different types of DioException', () {
        // Test various DioException types
        final testCases = [
          {
            'type': DioExceptionType.connectionTimeout,
            'message': 'Connection timeout'
          },
          {
            'type': DioExceptionType.sendTimeout,
            'message': 'Send timeout'
          },
          {
            'type': DioExceptionType.receiveTimeout,
            'message': 'Receive timeout'
          },
          {
            'type': DioExceptionType.badResponse,
            'message': 'Bad response'
          },
          {
            'type': DioExceptionType.cancel,
            'message': 'Request cancelled'
          },
          {
            'type': DioExceptionType.unknown,
            'message': 'Unknown error'
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final mockDioException = MockDioException();
          when(mockDioException.type).thenReturn(testCase['type'] as DioExceptionType);
          when(mockDioException.message).thenReturn(testCase['message'] as String);

          // Capture print output
          final printOutput = <String>[];
          final spec = ZoneSpecification(
            print: (_, __, ___, String message) {
              printOutput.add(message);
            },
          );

          // Act
          Zone.current.fork(specification: spec).run(() {
            errorInterceptor.onError(mockDioException, mockErrorHandler);
          });

          // Assert
          expect(printOutput.length, 1);
          expect(printOutput[0], 'DioError: ${testCase['message']}');
          verify(mockErrorHandler.next(mockDioException)).called(1);

          // Reset mocks for next iteration
          reset(mockErrorHandler);
        }
      });

      test('should handle DioException with response data', () {
        // Arrange
        final mockDioException = MockDioException();
        final mockResponse = MockResponse();
        final mockRequestOptions = MockRequestOptions();

        when(mockDioException.message).thenReturn('Server error');
        when(mockDioException.response).thenReturn(mockResponse);
        when(mockDioException.requestOptions).thenReturn(mockRequestOptions);
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.data).thenReturn({'error': 'Internal server error'});
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
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: Server error');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle very long error messages', () {
        // Arrange
        final mockDioException = MockDioException();
        final longMessage = 'A' * 1000; // Very long message

        when(mockDioException.message).thenReturn(longMessage);

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: $longMessage');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should handle special characters in error message', () {
        // Arrange
        final mockDioException = MockDioException();
        const specialMessage = 'Error: \n\t"Special" chars & symbols <>\$€';

        when(mockDioException.message).thenReturn(specialMessage);

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          errorInterceptor.onError(mockDioException, mockErrorHandler);
        });

        // Assert
        expect(printOutput.length, 1);
        expect(printOutput[0], 'DioError: $specialMessage');
        verify(mockErrorHandler.next(mockDioException)).called(1);
      });

      test('should be callable multiple times', () {
        // Arrange
        final errors = [
          {'exception': MockDioException(), 'message': 'Error 1'},
          {'exception': MockDioException(), 'message': 'Error 2'},
          {'exception': MockDioException(), 'message': 'Error 3'},
        ];

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        Zone.current.fork(specification: spec).run(() {
          for (final error in errors) {
            final mockException = error['exception'] as MockDioException;
            when(mockException.message).thenReturn(error['message'] as String);
            errorInterceptor.onError(mockException, mockErrorHandler);
          }
        });

        // Assert
        expect(printOutput.length, 3);
        expect(printOutput[0], 'DioError: Error 1');
        expect(printOutput[1], 'DioError: Error 2');
        expect(printOutput[2], 'DioError: Error 3');
        verify(mockErrorHandler.next(any)).called(3);
      });
    });

    group('constructor', () {
      test('should create instance successfully', () {
        // Act
        final interceptor = ErrorInterceptor();

        // Assert
        expect(interceptor, isNotNull);
        expect(interceptor, isA<ErrorInterceptor>());
        expect(interceptor, isA<Interceptor>());
      });
    });
  });
}