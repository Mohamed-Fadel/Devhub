import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devhub/infrastructure/network/network_info_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_impl_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('NetworkInfoImpl', () {
    group('isConnected', () {
      test('returns true when has wifi connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has mobile connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.mobile]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has ethernet connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.ethernet]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has vpn connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.vpn]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has bluetooth connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has other connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.other]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns false when has no connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isFalse);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns true when has multiple connectivity types', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ]);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('returns false when result is empty list', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => []);

        // Act
        final result = await networkInfo.isConnected;

        // Assert
        expect(result, isTrue); // Empty list != [ConnectivityResult.none]
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('handles checkConnectivity throwing exception', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenThrow(Exception('Connection check failed'));

        // Act & Assert
        expect(
              () async => await networkInfo.isConnected,
          throwsException,
        );
        verify(mockConnectivity.checkConnectivity()).called(1);
      });
    });

    group('onConnectivityChanged', () {
      test('emits true when connectivity changes to wifi', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true]),
        );
      });

      test('emits false when connectivity changes to none', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.none],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([false]),
        );
      });

      test('emits correct sequence for multiple connectivity changes', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.none],
          [ConnectivityResult.mobile],
          [ConnectivityResult.none],
          [ConnectivityResult.ethernet],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true, false, true, false, true]),
        );
      });

      test('emits true for all non-none connectivity types', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.mobile],
          [ConnectivityResult.ethernet],
          [ConnectivityResult.vpn],
          [ConnectivityResult.bluetooth],
          [ConnectivityResult.other],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true, true, true, true, true, true]),
        );
      });

      test('emits true when multiple connectivity types are available', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi, ConnectivityResult.mobile],
          [ConnectivityResult.ethernet, ConnectivityResult.vpn],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true, true]),
        );
      });

      test('emits true when empty list is received', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true]), // Empty list != [ConnectivityResult.none]
        );
      });

      test('handles stream errors', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.error(
          Exception('Stream error'),
        );
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsError(isException),
        );
      });

      test('can be listened to multiple times', () async {
        // Arrange
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.none],
        ]).asBroadcastStream();
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true, false]),
        );
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder([true, false]),
        );
      });

      test('properly transforms the stream using map operator', () async {
        // Arrange
        final originalStream = Stream<List<ConnectivityResult>>.fromIterable([
          [ConnectivityResult.wifi],
          [ConnectivityResult.none],
          [ConnectivityResult.mobile],
        ]);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => originalStream);

        // Act
        final transformedStream = networkInfo.onConnectivityChanged;

        // Assert
        expect(transformedStream, isA<Stream<bool>>());
        await expectLater(
          transformedStream.toList(),
          completion([true, false, true]),
        );
      });
    });

    group('edge cases', () {
      test('handles rapid connectivity changes', () async {
        // Arrange
        final rapidChanges = List.generate(
          10,
              (index) => index % 2 == 0
              ? [ConnectivityResult.wifi]
              : [ConnectivityResult.none],
        );
        final connectivityStream = Stream<List<ConnectivityResult>>.fromIterable(rapidChanges);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream);

        // Act & Assert
        final expectedResults = List.generate(10, (index) => index % 2 == 0);
        expect(
          networkInfo.onConnectivityChanged,
          emitsInOrder(expectedResults),
        );
      });

      test('multiple calls to isConnected work correctly', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        // Act
        final result1 = await networkInfo.isConnected;
        final result2 = await networkInfo.isConnected;
        final result3 = await networkInfo.isConnected;

        // Assert
        expect(result1, isTrue);
        expect(result2, isTrue);
        expect(result3, isTrue);
        verify(mockConnectivity.checkConnectivity()).called(3);
      });
    });
  });
}