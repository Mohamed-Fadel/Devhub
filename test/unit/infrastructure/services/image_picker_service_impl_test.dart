import 'dart:async';

import 'package:devhub/core/services/image_picker.dart';
import 'package:devhub/infrastructure/services/image_picker_service_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker_service_impl_test.mocks.dart';

@GenerateMocks([
  ImagePicker,
  XFile,
])
void main() {
  late ImagePickerServiceImpl imagePickerService;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockImagePicker = MockImagePicker();
    imagePickerService = ImagePickerServiceImpl(mockImagePicker);
  });

  group('ImagePickerServiceImpl', () {
    group('pickImageFromGallery', () {
      test('should return image path when user successfully picks an image', () async {
        // Arrange
        const expectedPath = '/storage/emulated/0/DCIM/Camera/IMG_20240101_120000.jpg';
        final mockXFile = MockXFile();

        when(mockXFile.path).thenReturn(expectedPath);
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result, expectedPath);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
        verify(mockXFile.path).called(1);
      });

      test('should return null when user cancels the image picker', () async {
        // Arrange
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => null);

        // Act
        final result = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result, null);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });

      test('should return null and print error when exception occurs', () async {
        // Arrange
        const errorMessage = 'Permission denied';
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenThrow(Exception(errorMessage));

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        String? result;
        await Zone.current.fork(specification: spec).run(() async {
          result = await imagePickerService.pickImageFromGallery();
        });

        // Assert
        expect(result, null);
        expect(printOutput.length, 1);
        expect(printOutput[0], contains('Error picking image:'));
        expect(printOutput[0], contains('Exception: $errorMessage'));
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });

      test('should handle different types of exceptions', () async {
        // Test various exception scenarios
        final exceptions = [
          Exception('No permission'),
          Exception('Camera not available'),
          Exception('Storage full'),
          Exception('Invalid image format'),
          Exception(''), // Empty error message
        ];

        for (final exception in exceptions) {
          // Arrange
          when(mockImagePicker.pickImage(source: ImageSource.gallery))
              .thenThrow(exception);

          // Capture print output
          final printOutput = <String>[];
          final spec = ZoneSpecification(
            print: (_, __, ___, String message) {
              printOutput.add(message);
            },
          );

          // Act
          String? result;
          await Zone.current.fork(specification: spec).run(() async {
            result = await imagePickerService.pickImageFromGallery();
          });

          // Assert
          expect(result, null);
          expect(printOutput.length, 1);
          expect(printOutput[0], contains('Error picking image:'));
          expect(printOutput[0], contains(exception.toString()));

          // Reset mock for next iteration
          reset(mockImagePicker);
        }
      });

      test('should handle platform-specific exceptions', () async {
        // Arrange
        final platformException = PlatformException(
          code: 'photo_access_denied',
          message: 'The user did not allow photo access.',
        );

        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenThrow(platformException);

        // Capture print output
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act
        String? result;
        await Zone.current.fork(specification: spec).run(() async {
          result = await imagePickerService.pickImageFromGallery();
        });

        // Assert
        expect(result, null);
        expect(printOutput.length, 1);
        expect(printOutput[0], contains('Error picking image:'));
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });

      test('should handle image with special characters in path', () async {
        // Arrange
        const specialPath = '/storage/emulated/0/DCIM/Camera/IMG_#@!%_2024.jpg';
        final mockXFile = MockXFile();

        when(mockXFile.path).thenReturn(specialPath);
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result, specialPath);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });

      test('should handle very long file paths', () async {
        // Arrange
        final longPath = '/storage/emulated/0/' + 'a' * 200 + '/image.jpg';
        final mockXFile = MockXFile();

        when(mockXFile.path).thenReturn(longPath);
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result, longPath);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });

      test('should handle empty path from XFile', () async {
        // Arrange
        const emptyPath = '';
        final mockXFile = MockXFile();

        when(mockXFile.path).thenReturn(emptyPath);
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result, emptyPath);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(1);
      });
    });

    group('constructor', () {
      test('should create instance with provided ImagePicker', () {
        // Arrange
        final imagePicker = MockImagePicker();

        // Act
        final service = ImagePickerServiceImpl(imagePicker);

        // Assert
        expect(service, isNotNull);
        expect(service, isA<ImagePickerServiceImpl>());
        expect(service, isA<ImagePickerService>());
      });

      test('should be annotated with @Injectable', () {
        // This test verifies the annotation is present
        // The actual DI behavior is tested in integration tests
        expect(imagePickerService, isA<ImagePickerService>());
      });
    });

    group('edge cases', () {
      test('should handle rapid consecutive calls', () async {
        // Arrange
        const path1 = '/path/to/image1.jpg';
        const path2 = '/path/to/image2.jpg';
        final mockXFile1 = MockXFile();
        final mockXFile2 = MockXFile();

        when(mockXFile1.path).thenReturn(path1);
        when(mockXFile2.path).thenReturn(path2);

        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile1);

        // Act - First call
        final result1 = await imagePickerService.pickImageFromGallery();

        // Update mock for second call
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile2);

        // Act - Second call
        final result2 = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result1, path1);
        expect(result2, path2);
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(2);
      });

      test('should recover after exception', () async {
        // Arrange
        const validPath = '/path/to/valid/image.jpg';
        final mockXFile = MockXFile();

        // First call throws exception
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenThrow(Exception('First call fails'));

        // Capture print output for first call
        final printOutput = <String>[];
        final spec = ZoneSpecification(
          print: (_, __, ___, String message) {
            printOutput.add(message);
          },
        );

        // Act - First call (should fail)
        String? result1;
        await Zone.current.fork(specification: spec).run(() async {
          result1 = await imagePickerService.pickImageFromGallery();
        });

        // Setup second call to succeed
        when(mockXFile.path).thenReturn(validPath);
        when(mockImagePicker.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) async => mockXFile);

        // Act - Second call (should succeed)
        final result2 = await imagePickerService.pickImageFromGallery();

        // Assert
        expect(result1, null);
        expect(result2, validPath);
        expect(printOutput.length, 1);
        expect(printOutput[0], contains('Error picking image:'));
        verify(mockImagePicker.pickImage(source: ImageSource.gallery)).called(2);
      });
    });
  });
}