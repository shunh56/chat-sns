import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerNotifierProvider = Provider(
  (ref) => ImagePickerNotifier(),
);

class ImagePickerNotifier {
  final imagePicker = ImagePicker();
  Future<XFile?> getImageFromGallery() async {
    try {
      //get Image from gallery
      final file = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      return file;
    } catch (error) {
      return null;
    }
  }

  Future<XFile?> getImageFromCamera() async {
    try {
      //get Image from gallery
      return await imagePicker.pickImage(
        imageQuality: 100,
        source: ImageSource.camera,
      );
    } catch (error) {
      return null;
    }
  }
}
