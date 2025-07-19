import 'package:devhub/core/services/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ImagePickerService)
class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _imagePicker;

  const ImagePickerServiceImpl(this._imagePicker);

  @override
  Future<String?> pickImageFromGallery() async {
    // Implement the logic to pick an image from the gallery
    // This is a placeholder implementation
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        return null; // User cancelled the picker
      }
      return pickedFile.path;
    } on Exception catch (_, e) {
      // Handle any errors that might occur during image picking
      print('Error picking image: $e');
      return null; // Return null if an error occurs
    }
  }
}
