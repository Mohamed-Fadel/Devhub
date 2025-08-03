import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/core/data/key_value_store/key_value_storage.dart';
import 'package:devhub/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

@GenerateMocks([
  KeyValueStorage,
  RequestInterceptorHandler,
  ErrorInterceptorHandler,
  DioException,
  Response,
])
import 'auth_interceptor_test.mocks.dart';

void main() {
  late AuthInterceptor authInterceptor;
  late MockKeyValueStorage mockKeyValueStorage;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUp(() {
    mockKeyValueStorage = MockKeyValueStorage();
    authInterceptor = AuthInterceptor(mockKeyValueStorage);
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
  });

  group('AuthInterceptor', () {
    group('onRequest', () {
      test('should add Authorization header when token exists', () async {
        // Arrange
        const testToken = 'test_access_token';
        final options = RequestOptions(path: '/test');

        when(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .thenAnswer((_) async => testToken);

        // Act
        await authInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        expect(options.headers['Authorization'], 'Bearer $testToken');
        verify(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .called(1);
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should not add Authorization header when token is null', () async {
        // Arrange
        final options = RequestOptions(path: '/test');

        when(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .thenAnswer((_) async => null);

        // Act
        await authInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        expect(options.headers['Authorization'], isNull);
        verify(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .called(1);
        verify(mockRequestHandler.next(options)).called(1);
      });

      test('should handle existing headers', () async {
        // Arrange
        const testToken = 'test_access_token';
        final options = RequestOptions(
          path: '/test',
          headers: {'Content-Type': 'application/json'},
        );

        when(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .thenAnswer((_) async => testToken);

        // Act
        await authInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        expect(options.headers['Authorization'], 'Bearer $testToken');
        expect(options.headers['Content-Type'], 'application/json');
        verify(mockKeyValueStorage.get(key: AppConstants.accessTokenKey))
            .called(1);
        verify(mockRequestHandler.next(options)).called(1);
      });
    });

    group('onError', () {
      test('should delete tokens when error is 401 and refresh token exists',
              () async {
            // Arrange
            const refreshToken = 'test_refresh_token';
            final mockResponse = MockResponse();
            final dioError = MockDioException();

            when(dioError.response).thenReturn(mockResponse);
            when(mockResponse.statusCode).thenReturn(401);
            when(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey))
                .thenAnswer((_) async => refreshToken);
            when(mockKeyValueStorage.delete(key: anyNamed('key')))
                .thenAnswer((_) async => {});

            // Act
            await authInterceptor.onError(dioError, mockErrorHandler);

            // Assert
            verify(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey))
                .called(1);
            verify(mockKeyValueStorage.delete(key: AppConstants.accessTokenKey))
                .called(1);
            verify(mockKeyValueStorage.delete(key: AppConstants.refreshTokenKey))
                .called(1);
            verify(mockErrorHandler.next(dioError)).called(1);
          });

      test('should not delete tokens when error is 401 but refresh token is null',
              () async {
            // Arrange
            final mockResponse = MockResponse();
            final dioError = MockDioException();

            when(dioError.response).thenReturn(mockResponse);
            when(mockResponse.statusCode).thenReturn(401);
            when(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey))
                .thenAnswer((_) async => null);

            // Act
            await authInterceptor.onError(dioError, mockErrorHandler);

            // Assert
            verify(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey))
                .called(1);
            verifyNever(mockKeyValueStorage.delete(key: AppConstants.accessTokenKey));
            verifyNever(mockKeyValueStorage.delete(key: AppConstants.refreshTokenKey));
            verify(mockErrorHandler.next(dioError)).called(1);
          });

      test('should not handle error when status code is not 401', () async {
        // Arrange
        final mockResponse = MockResponse();
        final dioError = MockDioException();

        when(dioError.response).thenReturn(mockResponse);
        when(mockResponse.statusCode).thenReturn(404);

        // Act
        await authInterceptor.onError(dioError, mockErrorHandler);

        // Assert
        verifyNever(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey));
        verifyNever(mockKeyValueStorage.delete(key: anyNamed('key')));
        verify(mockErrorHandler.next(dioError)).called(1);
      });

      test('should handle error when response is null', () async {
        // Arrange
        final dioError = MockDioException();
        when(dioError.response).thenReturn(null);

        // Act
        await authInterceptor.onError(dioError, mockErrorHandler);

        // Assert
        verifyNever(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey));
        verifyNever(mockKeyValueStorage.delete(key: anyNamed('key')));
        verify(mockErrorHandler.next(dioError)).called(1);
      });

      test('should handle different error status codes', () async {
        // Test multiple non-401 status codes
        final statusCodes = [400, 403, 404, 500, 503];

        for (final statusCode in statusCodes) {
          // Arrange
          final mockResponse = MockResponse();
          final dioError = MockDioException();

          when(dioError.response).thenReturn(mockResponse);
          when(mockResponse.statusCode).thenReturn(statusCode);

          // Act
          await authInterceptor.onError(dioError, mockErrorHandler);

          // Assert
          verifyNever(mockKeyValueStorage.get(key: AppConstants.refreshTokenKey));
          verifyNever(mockKeyValueStorage.delete(key: anyNamed('key')));
          verify(mockErrorHandler.next(dioError)).called(1);

          // Reset mock invocations for next iteration
          reset(mockKeyValueStorage);
          reset(mockErrorHandler);
        }
      });
    });
  });
}