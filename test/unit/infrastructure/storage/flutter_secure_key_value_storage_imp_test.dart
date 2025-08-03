import 'package:devhub/core/services/key_value_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:devhub/infrastructure/storage/flutter_secure_key_value_storage_impl.dart';

import 'flutter_secure_key_value_storage_imp_test.mocks.dart';

@GenerateMocks([
  FlutterSecureStorage,
])
void main() {
  late FlutterSecureKeyValueStorageImpl storage;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    storage = FlutterSecureKeyValueStorageImpl(mockSecureStorage);
  });

  group('FlutterSecureKeyValueStorageImp', () {
    group('get', () {
      test('should return value when key exists', () async {
        // Arrange
        const key = 'user_token';
        const expectedValue = 'Bearer abc123xyz';

        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => expectedValue);

        // Act
        final result = await storage.get(key: key);

        // Assert
        expect(result, expectedValue);
        verify(mockSecureStorage.read(key: key)).called(1);
        verifyNoMoreInteractions(mockSecureStorage);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const key = 'non_existent_key';

        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => null);

        // Act
        final result = await storage.get(key: key);

        // Assert
        expect(result, null);
        verify(mockSecureStorage.read(key: key)).called(1);
        verifyNoMoreInteractions(mockSecureStorage);
      });

      test('should handle empty string value', () async {
        // Arrange
        const key = 'empty_value';
        const expectedValue = '';

        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => expectedValue);

        // Act
        final result = await storage.get(key: key);

        // Assert
        expect(result, expectedValue);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should handle special characters in key', () async {
        // Arrange
        const key = 'user@email.com_token';
        const expectedValue = 'some_value';

        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => expectedValue);

        // Act
        final result = await storage.get(key: key);

        // Assert
        expect(result, expectedValue);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should handle very long values', () async {
        // Arrange
        const key = 'long_value_key';
        final expectedValue = 'A' * 10000; // Very long string

        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => expectedValue);

        // Act
        final result = await storage.get(key: key);

        // Assert
        expect(result, expectedValue);
        verify(mockSecureStorage.read(key: key)).called(1);
      });

      test('should propagate exceptions from secure storage', () async {
        // Arrange
        const key = 'error_key';
        final exception = Exception('Storage error');

        when(mockSecureStorage.read(key: key))
            .thenThrow(exception);

        // Act & Assert
        expect(
              () => storage.get(key: key),
          throwsA(equals(exception)),
        );
        verify(mockSecureStorage.read(key: key)).called(1);
      });
    });

    group('put', () {
      test('should write value when value is not null', () async {
        // Arrange
        const key = 'user_preference';
        const value = 'dark_mode';

        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
        verifyNever(mockSecureStorage.delete(key: anyNamed('key')));
        verifyNoMoreInteractions(mockSecureStorage);
      });

      test('should delete key when value is null', () async {
        // Arrange
        const key = 'user_token';
        const String? value = null;

        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.delete(key: key)).called(1);
        verifyNever(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
        verifyNoMoreInteractions(mockSecureStorage);
      });

      test('should handle empty string value', () async {
        // Arrange
        const key = 'empty_pref';
        const value = '';

        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
        verifyNever(mockSecureStorage.delete(key: anyNamed('key')));
      });

      test('should handle special characters in value', () async {
        // Arrange
        const key = 'special_chars';
        const value = '!@#\$%^&*()_+-={}[]|\\:";\'<>?,./';

        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should handle JSON string values', () async {
        // Arrange
        const key = 'user_data';
        const value = '{"id":123,"name":"John Doe","email":"john@example.com"}';

        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should handle very long keys', () async {
        // Arrange
        final key = 'very_long_key_' + 'x' * 200;
        const value = 'some_value';

        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should propagate exceptions from secure storage on write', () async {
        // Arrange
        const key = 'error_key';
        const value = 'error_value';
        final exception = Exception('Write error');

        when(mockSecureStorage.write(key: key, value: value))
            .thenThrow(exception);

        // Act & Assert
        expect(
              () => storage.put(key: key, value: value),
          throwsA(equals(exception)),
        );
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
      });

      test('should propagate exceptions from secure storage on delete', () async {
        // Arrange
        const key = 'error_key';
        const String? value = null;
        final exception = Exception('Delete error');

        when(mockSecureStorage.delete(key: key))
            .thenThrow(exception);

        // Act & Assert
        expect(
              () => storage.put(key: key, value: value),
          throwsA(equals(exception)),
        );
        verify(mockSecureStorage.delete(key: key)).called(1);
      });
    });

    group('delete', () {
      test('should delete key successfully', () async {
        // Arrange
        const key = 'user_session';

        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.delete(key: key);

        // Assert
        verify(mockSecureStorage.delete(key: key)).called(1);
        verifyNoMoreInteractions(mockSecureStorage);
      });

      test('should handle deleting non-existent key', () async {
        // Arrange
        const key = 'non_existent_key';

        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.delete(key: key);

        // Assert
        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should handle special characters in key during delete', () async {
        // Arrange
        const key = 'user@domain.com:session';

        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.delete(key: key);

        // Assert
        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should propagate exceptions from secure storage', () async {
        // Arrange
        const key = 'error_key';
        final exception = Exception('Delete error');

        when(mockSecureStorage.delete(key: key))
            .thenThrow(exception);

        // Act & Assert
        expect(
              () => storage.delete(key: key),
          throwsA(equals(exception)),
        );
        verify(mockSecureStorage.delete(key: key)).called(1);
      });
    });

    group('constructor', () {
      test('should create instance with provided FlutterSecureStorage', () {
        // Arrange
        final secureStorage = MockFlutterSecureStorage();

        // Act
        final kvStorage = FlutterSecureKeyValueStorageImpl(secureStorage);

        // Assert
        expect(kvStorage, isNotNull);
        expect(kvStorage, isA<FlutterSecureKeyValueStorageImpl>());
        expect(kvStorage, isA<KeyValueStorage>());
      });
    });

    group('integration scenarios', () {
      test('should handle complete lifecycle: put, get, delete', () async {
        // Arrange
        const key = 'auth_token';
        const value = 'Bearer xyz789';

        // Setup put
        when(mockSecureStorage.write(key: key, value: value))
            .thenAnswer((_) async {});

        // Setup get
        when(mockSecureStorage.read(key: key))
            .thenAnswer((_) async => value);

        // Setup delete
        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value);
        final retrievedValue = await storage.get(key: key);
        await storage.delete(key: key);

        // Assert
        expect(retrievedValue, value);
        verify(mockSecureStorage.write(key: key, value: value)).called(1);
        verify(mockSecureStorage.read(key: key)).called(1);
        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should handle update scenario: put twice with different values', () async {
        // Arrange
        const key = 'user_preference';
        const value1 = 'light_mode';
        const value2 = 'dark_mode';

        when(mockSecureStorage.write(key: key, value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: value1);
        await storage.put(key: key, value: value2);

        // Assert
        verify(mockSecureStorage.write(key: key, value: value1)).called(1);
        verify(mockSecureStorage.write(key: key, value: value2)).called(1);
      });

      test('should handle put with null to delete existing key', () async {
        // Arrange
        const key = 'temp_data';
        const initialValue = 'some_temp_data';

        // First put a value
        when(mockSecureStorage.write(key: key, value: initialValue))
            .thenAnswer((_) async {});

        // Then delete by putting null
        when(mockSecureStorage.delete(key: key))
            .thenAnswer((_) async {});

        // Act
        await storage.put(key: key, value: initialValue);
        await storage.put(key: key, value: null);

        // Assert
        verify(mockSecureStorage.write(key: key, value: initialValue)).called(1);
        verify(mockSecureStorage.delete(key: key)).called(1);
      });

      test('should handle multiple keys independently', () async {
        // Arrange
        const key1 = 'user_id';
        const value1 = '12345';
        const key2 = 'session_token';
        const value2 = 'abc-def-ghi';

        when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
        when(mockSecureStorage.read(key: key1))
            .thenAnswer((_) async => value1);
        when(mockSecureStorage.read(key: key2))
            .thenAnswer((_) async => value2);

        // Act
        await storage.put(key: key1, value: value1);
        await storage.put(key: key2, value: value2);
        final result1 = await storage.get(key: key1);
        final result2 = await storage.get(key: key2);

        // Assert
        expect(result1, value1);
        expect(result2, value2);
        verify(mockSecureStorage.write(key: key1, value: value1)).called(1);
        verify(mockSecureStorage.write(key: key2, value: value2)).called(1);
        verify(mockSecureStorage.read(key: key1)).called(1);
        verify(mockSecureStorage.read(key: key2)).called(1);
      });
    });
  });
}