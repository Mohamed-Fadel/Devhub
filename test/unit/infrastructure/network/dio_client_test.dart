import 'package:devhub/core/network/api_client.dart';
import 'package:devhub/infrastructure/network/dio_client.dart';
import 'package:devhub/infrastructure/network/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'dio_client_test.mocks.dart';

@GenerateMocks([
  Dio,
  Response,
  Headers,
  NetworkException,
])
void main() {
  late DioClient dioClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dioClient = DioClient(mockDio);
  });

  group('DioClient', () {
    group('GET requests', () {
      test('should successfully make GET request without parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'users': []});
        when(mockDio.get(
          path,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.get(path);

        // Assert
        expect(result, isA<DioApiResponse>());
        expect(result.statusCode, 200);
        expect(result.data, {'users': []});
        verify(mockDio.get(
          path,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make GET request with query parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';
        final queryParams = {'page': 1, 'limit': 10};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'users': [], 'page': 1});
        when(mockDio.get(
          path,
          queryParameters: queryParams,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.get(path, queryParameters: queryParams);

        // Assert
        expect(result.statusCode, 200);
        expect(result.data, {'users': [], 'page': 1});
        verify(mockDio.get(
          path,
          queryParameters: queryParams,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make GET request with headers', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';
        final headers = {'Authorization': 'Bearer token123'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'users': []});
        when(mockDio.get(
          path,
          queryParameters: null,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.get(path, headers: headers);

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.get(
          path,
          queryParameters: null,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should successfully make GET request with all parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';
        final queryParams = {'role': 'admin', 'active': true};
        final headers = {'Authorization': 'Bearer token', 'Accept': 'application/json'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'users': []});
        when(mockDio.get(
          path,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.get(
          path,
          queryParameters: queryParams,
          headers: headers,
        );

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.get(
          path,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should throw NetworkException on DioException', () async {
        // Arrange
        const path = '/api/users';
        final dioException = DioException(
          requestOptions: RequestOptions(path: path),
          message: 'Network error',
          type: DioExceptionType.connectionTimeout,
        );

        when(mockDio.get(
          path,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
              () => dioClient.get(path),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('POST requests', () {
      test('should successfully make POST request without data', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';

        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.data).thenReturn({'id': 1, 'created': true});
        when(mockDio.post(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.post(path);

        // Assert
        expect(result.statusCode, 201);
        expect(result.data, {'id': 1, 'created': true});
        verify(mockDio.post(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make POST request with data', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';
        final data = {'name': 'John Doe', 'email': 'john@example.com'};

        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.data).thenReturn({'id': 1, 'name': 'John Doe'});
        when(mockDio.post(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.post(path, data: data);

        // Assert
        expect(result.statusCode, 201);
        verify(mockDio.post(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make POST request with all parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users';
        final data = {'name': 'John Doe'};
        final queryParams = {'notify': true};
        final headers = {'Content-Type': 'application/json'};

        when(mockResponse.statusCode).thenReturn(201);
        when(mockResponse.data).thenReturn({'id': 1});
        when(mockDio.post(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.post(
          path,
          data: data,
          queryParameters: queryParams,
          headers: headers,
        );

        // Assert
        expect(result.statusCode, 201);
        verify(mockDio.post(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should throw NetworkException on DioException', () async {
        // Arrange
        const path = '/api/users';
        final dioException = DioException(
          requestOptions: RequestOptions(path: path),
          message: 'Bad request',
          type: DioExceptionType.badResponse,
        );

        when(mockDio.post(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
              () => dioClient.post(path),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('PUT requests', () {
      test('should successfully make PUT request', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';
        final data = {'name': 'Jane Doe'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'id': 1, 'name': 'Jane Doe'});
        when(mockDio.put(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.put(path, data: data);

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.put(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make PUT request with all parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';
        final data = {'name': 'Jane Doe', 'role': 'admin'};
        final queryParams = {'validate': true};
        final headers = {'Authorization': 'Bearer token'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'updated': true});
        when(mockDio.put(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.put(
          path,
          data: data,
          queryParameters: queryParams,
          headers: headers,
        );

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.put(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should throw NetworkException on DioException', () async {
        // Arrange
        const path = '/api/users/1';
        final dioException = DioException(
          requestOptions: RequestOptions(path: path),
          response: Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 404,
          ),
        );

        when(mockDio.put(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
              () => dioClient.put(path),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('PATCH requests', () {
      test('should successfully make PATCH request', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';
        final data = {'status': 'active'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'id': 1, 'status': 'active'});
        when(mockDio.patch(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.patch(path, data: data);

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.patch(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make PATCH request with all parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';
        final data = {'status': 'inactive'};
        final queryParams = {'reason': 'vacation'};
        final headers = {'X-Request-ID': '12345'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'patched': true});
        when(mockDio.patch(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.patch(
          path,
          data: data,
          queryParameters: queryParams,
          headers: headers,
        );

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.patch(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should throw NetworkException on DioException', () async {
        // Arrange
        const path = '/api/users/1';
        final dioException = DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.cancel,
        );

        when(mockDio.patch(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
              () => dioClient.patch(path),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('DELETE requests', () {
      test('should successfully make DELETE request without data', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';

        when(mockResponse.statusCode).thenReturn(204);
        when(mockResponse.data).thenReturn(null);
        when(mockDio.delete(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.delete(path);

        // Assert
        expect(result.statusCode, 204);
        expect(result.data, null);
        verify(mockDio.delete(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make DELETE request with data', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/bulk';
        final data = {'ids': [1, 2, 3]};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'deleted': 3});
        when(mockDio.delete(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.delete(path, data: data);

        // Assert
        expect(result.statusCode, 200);
        expect(result.data, {'deleted': 3});
        verify(mockDio.delete(
          path,
          data: data,
          queryParameters: null,
          options: anyNamed('options'),
        )).called(1);
      });

      test('should successfully make DELETE request with all parameters', () async {
        // Arrange
        final mockResponse = MockResponse();
        const path = '/api/users/1';
        final data = {'reason': 'account closure'};
        final queryParams = {'soft_delete': true};
        final headers = {'Authorization': 'Bearer admin-token'};

        when(mockResponse.statusCode).thenReturn(200);
        when(mockResponse.data).thenReturn({'deleted': true});
        when(mockDio.delete(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dioClient.delete(
          path,
          data: data,
          queryParameters: queryParams,
          headers: headers,
        );

        // Assert
        expect(result.statusCode, 200);
        verify(mockDio.delete(
          path,
          data: data,
          queryParameters: queryParams,
          options: argThat(
            isA<Options>().having((o) => o.headers, 'headers', headers),
            named: 'options',
          ),
        )).called(1);
      });

      test('should throw NetworkException on DioException', () async {
        // Arrange
        const path = '/api/users/1';
        final dioException = DioException(
          requestOptions: RequestOptions(path: path),
          type: DioExceptionType.sendTimeout,
        );

        when(mockDio.delete(
          path,
          data: null,
          queryParameters: null,
          options: anyNamed('options'),
        )).thenThrow(dioException);

        // Act & Assert
        expect(
              () => dioClient.delete(path),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('constructor', () {
      test('should create instance with provided Dio', () {
        // Arrange
        final dio = MockDio();

        // Act
        final client = DioClient(dio);

        // Assert
        expect(client, isNotNull);
        expect(client, isA<DioClient>());
        expect(client, isA<HttpClient>());
      });
    });
  });

  group('DioApiResponse', () {
    test('should correctly expose response properties', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();
      final headersMap = {
        'content-type': ['application/json'],
        'x-request-id': ['12345'],
      };

      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn({'key': 'value'});
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn(headersMap);

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse.statusCode, 200);
      expect(apiResponse.data, {'key': 'value'});
      expect(apiResponse.headers, headersMap);
    });

    test('should handle null statusCode', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();

      when(mockResponse.statusCode).thenReturn(null);
      when(mockResponse.data).thenReturn(null);
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn({});

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse.statusCode, null);
      expect(apiResponse.data, null);
      expect(apiResponse.headers, {});
    });

    test('should handle complex data types', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();
      final complexData = {
        'users': [
          {'id': 1, 'name': 'John'},
          {'id': 2, 'name': 'Jane'},
        ],
        'meta': {
          'total': 2,
          'page': 1,
        },
      };

      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(complexData);
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn({});

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse.data, complexData);
    });

    test('should handle string data', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();

      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn('Plain text response');
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn({});

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse.data, 'Plain text response');
    });

    test('should handle list data', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();
      final listData = [1, 2, 3, 4, 5];

      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn(listData);
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn({});

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse.data, listData);
    });

    test('should implement ApiResponse interface', () {
      // Arrange
      final mockResponse = MockResponse();
      final mockHeaders = MockHeaders();

      when(mockResponse.statusCode).thenReturn(200);
      when(mockResponse.data).thenReturn({});
      when(mockResponse.headers).thenReturn(mockHeaders);
      when(mockHeaders.map).thenReturn({});

      // Act
      final apiResponse = DioApiResponse(mockResponse);

      // Assert
      expect(apiResponse, isA<ApiResponse>());
    });
  });
}