import 'package:devhub/infrastructure/network/network_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_exception_test.mocks.dart';

@GenerateMocks([DioException, Response, Headers])
void main() {
  group('NetworkException', () {
    group('Constructor', () {
      test('creates instance with all parameters', () {
        final stackTrace = StackTrace.current;
        final headers = {'content-type': 'application/json'};
        final data = {'error': 'test error'};

        final exception = NetworkException(
          type: NetworkExceptionType.unknown,
          message: 'Test message',
          data: data,
          statusCode: 404,
          headers: headers,
          code: '404',
          stackTrace: stackTrace,
        );

        expect(exception.type, NetworkExceptionType.unknown);
        expect(exception.message, 'Test message');
        expect(exception.data, data);
        expect(exception.statusCode, 404);
        expect(exception.headers, headers);
        expect(exception.code, '404');
        expect(exception.stackTrace, stackTrace);
      });

      test('creates instance with required parameters only', () {
        final data = {'error': 'test error'};

        final exception = NetworkException(
          type: NetworkExceptionType.connectionTimeout,
          message: 'Timeout',
          data: data,
        );

        expect(exception.type, NetworkExceptionType.connectionTimeout);
        expect(exception.message, 'Timeout');
        expect(exception.data, data);
        expect(exception.statusCode, isNull);
        expect(exception.headers, isNull);
        expect(exception.code, isNull);
        expect(exception.stackTrace, isNull);
      });
    });

    group('fromDioException factory', () {
      late MockDioException mockDioException;
      late MockResponse mockResponse;
      late MockHeaders mockHeaders;

      setUp(() {
        mockDioException = MockDioException();
        mockResponse = MockResponse();
        mockHeaders = MockHeaders();
      });

      test('handles connectionTimeout', () {
        when(mockDioException.type).thenReturn(DioExceptionType.connectionTimeout);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.connectionTimeout);
        expect(exception.message, 'Connection timeout occurred');
        expect(exception.statusCode, isNull);
        expect(exception.headers, isNull);
        expect(exception.data, isNull);
      });

      test('handles sendTimeout', () {
        when(mockDioException.type).thenReturn(DioExceptionType.sendTimeout);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.sendTimeout);
        expect(exception.message, 'Send timeout occurred');
      });

      test('handles receiveTimeout', () {
        when(mockDioException.type).thenReturn(DioExceptionType.receiveTimeout);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.receiveTimeout);
        expect(exception.message, 'Receive timeout occurred');
      });

      test('handles badCertificate', () {
        when(mockDioException.type).thenReturn(DioExceptionType.badCertificate);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.badCertificate);
        expect(exception.message, 'Bad certificate encountered');
      });

      test('handles cancel', () {
        when(mockDioException.type).thenReturn(DioExceptionType.cancel);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.cancel);
        expect(exception.message, 'Request was cancelled');
      });

      test('handles connectionError', () {
        when(mockDioException.type).thenReturn(DioExceptionType.connectionError);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.connectionError);
        expect(exception.message, 'Connection error occurred');
      });

      test('handles unknown error with message', () {
        when(mockDioException.type).thenReturn(DioExceptionType.unknown);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn('Custom error message');
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.unknown);
        expect(exception.message, 'Custom error message');
      });

      test('handles unknown error without message', () {
        when(mockDioException.type).thenReturn(DioExceptionType.unknown);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn(null);
        when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.unknown);
        expect(exception.message, 'An unknown error occurred');
      });

      group('handles badResponse with various status codes', () {
        setUp(() {
          when(mockDioException.type).thenReturn(DioExceptionType.badResponse);
          when(mockHeaders.map).thenReturn({'content-type': ['application/json']});
          when(mockResponse.headers).thenReturn(mockHeaders);
          when(mockDioException.response).thenReturn(mockResponse);
          when(mockDioException.stackTrace).thenReturn(StackTrace.empty);
        });

        test('400 - Bad request', () {
          when(mockResponse.statusCode).thenReturn(400);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.type, NetworkExceptionType.badResponse);
          expect(exception.message, 'Bad request');
          expect(exception.statusCode, 400);
          expect(exception.code, '400');
        });

        test('401 - Unauthorized', () {
          when(mockResponse.statusCode).thenReturn(401);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Unauthorized');
          expect(exception.statusCode, 401);
        });

        test('403 - Forbidden', () {
          when(mockResponse.statusCode).thenReturn(403);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Forbidden');
          expect(exception.statusCode, 403);
        });

        test('404 - Not found', () {
          when(mockResponse.statusCode).thenReturn(404);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Not found');
          expect(exception.statusCode, 404);
        });

        test('408 - Request timeout', () {
          when(mockResponse.statusCode).thenReturn(408);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Request timeout');
          expect(exception.statusCode, 408);
        });

        test('409 - Conflict', () {
          when(mockResponse.statusCode).thenReturn(409);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Conflict');
          expect(exception.statusCode, 409);
        });

        test('422 - Unprocessable entity', () {
          when(mockResponse.statusCode).thenReturn(422);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Unprocessable entity');
          expect(exception.statusCode, 422);
        });

        test('429 - Too many requests', () {
          when(mockResponse.statusCode).thenReturn(429);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Too many requests');
          expect(exception.statusCode, 429);
        });

        test('500 - Internal server error', () {
          when(mockResponse.statusCode).thenReturn(500);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Internal server error');
          expect(exception.statusCode, 500);
        });

        test('502 - Bad gateway', () {
          when(mockResponse.statusCode).thenReturn(502);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Bad gateway');
          expect(exception.statusCode, 502);
        });

        test('503 - Service unavailable', () {
          when(mockResponse.statusCode).thenReturn(503);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Service unavailable');
          expect(exception.statusCode, 503);
        });

        test('504 - Gateway timeout', () {
          when(mockResponse.statusCode).thenReturn(504);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Gateway timeout');
          expect(exception.statusCode, 504);
        });

        test('unknown status code with statusMessage', () {
          when(mockResponse.statusCode).thenReturn(418); // I'm a teapot
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn("I'm a teapot");

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, "I'm a teapot");
          expect(exception.statusCode, 418);
        });

        test('unknown status code without statusMessage', () {
          when(mockResponse.statusCode).thenReturn(418);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Bad response received');
          expect(exception.statusCode, 418);
        });

        test('null status code', () {
          when(mockResponse.statusCode).thenReturn(null);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Bad response received');
          expect(exception.statusCode, isNull);
          expect(exception.code, isNull);
        });
      });

      group('extracts error message from response data', () {
        setUp(() {
          when(mockDioException.type).thenReturn(DioExceptionType.badResponse);
          when(mockHeaders.map).thenReturn({'content-type': ['application/json']});
          when(mockResponse.headers).thenReturn(mockHeaders);
          when(mockResponse.statusCode).thenReturn(400);
          when(mockResponse.statusMessage).thenReturn(null);
          when(mockDioException.response).thenReturn(mockResponse);
          when(mockDioException.stackTrace).thenReturn(StackTrace.empty);
        });

        test('extracts message from "message" field', () {
          when(mockResponse.data).thenReturn({'message': 'Custom error message'});

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Custom error message');
        });

        test('extracts message from "error" field', () {
          when(mockResponse.data).thenReturn({'error': 'Error from API'});

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Error from API');
        });

        test('extracts message from "error_description" field', () {
          when(mockResponse.data).thenReturn({'error_description': 'Detailed error'});

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Detailed error');
        });

        test('prioritizes "message" over other fields', () {
          when(mockResponse.data).thenReturn({
            'message': 'Priority message',
            'error': 'Should not use this',
            'error_description': 'Should not use this either'
          });

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Priority message');
        });

        test('handles non-Map response data', () {
          when(mockResponse.data).thenReturn('String response data');

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Bad request');
          expect(exception.data, 'String response data');
        });

        test('handles response data as List', () {
          when(mockResponse.data).thenReturn(['error1', 'error2']);

          final exception = NetworkException.fromDioException(mockDioException);

          expect(exception.message, 'Bad request');
          expect(exception.data, ['error1', 'error2']);
        });
      });

      test('includes stackTrace when available', () {
        final stackTrace = StackTrace.current;
        when(mockDioException.type).thenReturn(DioExceptionType.unknown);
        when(mockDioException.response).thenReturn(null);
        when(mockDioException.message).thenReturn('Error');
        when(mockDioException.stackTrace).thenReturn(stackTrace);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.stackTrace, stackTrace);
      });

      test('handles response with all fields populated', () {
        final stackTrace = StackTrace.current;
        final responseData = {'custom': 'data'};

        when(mockDioException.type).thenReturn(DioExceptionType.badResponse);
        when(mockHeaders.map).thenReturn({'content-type': ['application/json']});
        when(mockResponse.headers).thenReturn(mockHeaders);
        when(mockResponse.statusCode).thenReturn(500);
        when(mockResponse.data).thenReturn(responseData);
        when(mockResponse.statusMessage).thenReturn('Server Error');
        when(mockDioException.response).thenReturn(mockResponse);
        when(mockDioException.stackTrace).thenReturn(stackTrace);

        final exception = NetworkException.fromDioException(mockDioException);

        expect(exception.type, NetworkExceptionType.badResponse);
        expect(exception.message, 'Internal server error');
        expect(exception.statusCode, 500);
        expect(exception.code, '500');
        expect(exception.headers, {'content-type': ['application/json']});
        expect(exception.data, responseData);
        expect(exception.stackTrace, stackTrace);
      });
    });

    group('toString', () {
      test('formats output with all fields', () {
        final exception = NetworkException(
          type: NetworkExceptionType.badResponse,
          message: 'Not found',
          data: null,
          statusCode: 404,
        );

        expect(
          exception.toString(),
          'NetworkException: Not found (Type: badResponse, StatusCode: 404)',
        );
      });

      test('formats output without statusCode', () {
        final exception = NetworkException(
          type: NetworkExceptionType.connectionTimeout,
          message: 'Timeout occurred',
          data: null,
        );

        expect(
          exception.toString(),
          'NetworkException: Timeout occurred (Type: connectionTimeout, StatusCode: null)',
        );
      });
    });

    group('_getMessageFromStatusCode', () {
      test('is called for all supported status codes', () {
        // This test ensures the private method is covered through the factory
        final testCases = [
          400, 401, 403, 404, 408, 409, 422, 429,
          500, 502, 503, 504, 418 // unknown code
        ];

        for (final statusCode in testCases) {
          final mockDioException = MockDioException();
          final mockResponse = MockResponse();
          final mockHeaders = MockHeaders();

          when(mockDioException.type).thenReturn(DioExceptionType.badResponse);
          when(mockHeaders.map).thenReturn({});
          when(mockResponse.headers).thenReturn(mockHeaders);
          when(mockResponse.statusCode).thenReturn(statusCode);
          when(mockResponse.data).thenReturn(null);
          when(mockResponse.statusMessage).thenReturn(null);
          when(mockDioException.response).thenReturn(mockResponse);
          when(mockDioException.stackTrace).thenReturn(StackTrace.empty);

          NetworkException.fromDioException(mockDioException);
        }
      });
    });
  });
}