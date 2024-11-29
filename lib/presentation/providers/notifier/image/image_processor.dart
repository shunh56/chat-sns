import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/providers/notifier/image/image_compressor_notifier.dart';
import 'package:app/presentation/providers/notifier/image/image_cropper_notifier.dart';
import 'package:app/presentation/providers/notifier/image/image_picker_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final imageProcessorNotifierProvider = StateProvider(
  (ref) => ImageProcessorNotifier(
    ref: ref,
  ),
);

class ImageProcessorNotifier {
  ImageProcessorNotifier({
    required this.ref,
  });
  final Ref ref;

  Future<File?> getIconImage() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}/icon_image_${1080}x${1080}.jpg';
    DebugPrint("path : $path");
    final pickedFile =
        await ref.read(imagePickerNotifierProvider).getImageFromGallery();
    if (pickedFile == null) return null;
    final croppedImage = await ref
        .read(imageCropperNotifierProvider)
        .cropSquareImage(File(pickedFile.path));
    if (croppedImage == null) return null;
    final compressedImage =
        await ref.read(imageCompressorNotifierProvider).compressIconImage(
              croppedImage,
              path,
            );
    return compressedImage;
  }

  Future<File?> getPostImage() async {
    Timestamp now = Timestamp.now();
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}/$now.jpg';
    final pickedFile =
        await ref.read(imagePickerNotifierProvider).getImageFromGallery();
    if (pickedFile == null) return null;

    final compressedImage =
        await ref.read(imageCompressorNotifierProvider).compressPostImage(
              File(pickedFile.path),
              path,
            );
    return compressedImage;
  }

  Future<File?> getPostImageFromCamera() async {
    Timestamp now = Timestamp.now();
    var directory = await getApplicationDocumentsDirectory();
    var path = '${directory.path}/$now.jpg';
    final pickedFile =
        await ref.read(imagePickerNotifierProvider).getImageFromCamera();
    if (pickedFile == null) return null;

    final compressedImage =
        await ref.read(imageCompressorNotifierProvider).compressPostImage(
              File(pickedFile.path),
              path,
            );
    return compressedImage;
  }
}
