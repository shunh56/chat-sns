import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/main.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

final imageUploadUsecaseProvider = Provider(
  (ref) => ImageUploadUsecase(
    ref.watch(storageProvider),
    ref.watch(authProvider),
    //  ref.watch(imageRepositoryProvider),
  ),
);

class ImageUploadUsecase {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  //final ImageRepository _repository;
  ImageUploadUsecase(
    this._storage,
    this._auth,
    // this._repository,
  );

  Future<String> uploadIconImage(File imageFile) async {
    try {
      DebugPrint("Starting upload with flavor: $flavor"); // flavorの確認
      DebugPrint(
          "Storage instance: ${_storage.app.options.storageBucket}"); // Storage bucketの確認

      DateTime now = DateTime.now();
      final ref = _storage
          .ref("photos")
          .child(_auth.currentUser!.uid)
          .child("icon_images")
          .child(now.millisecondsSinceEpoch.toString());

      DebugPrint("Upload reference path: ${ref.fullPath}");
      final uploadTask = ref.putFile(imageFile);
      // 進捗状況の監視を追加
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        DebugPrint(
            'Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      }, onError: (error) {
        DebugPrint('Upload error during progress: $error');
      });

      final snap = await uploadTask;
      DebugPrint("Upload completed, getting download URL");

      final downloadUrl = await snap.ref.getDownloadURL();
      DebugPrint("Download URL obtained: $downloadUrl");

      return downloadUrl;
    } catch (e, stack) {
      DebugPrint("Upload failed with error: $e");
      DebugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  Future<String> _uploadIPostImage(File imageFile, String id, int index) async {
    Reference ref = _storage
        .ref("photos")
        .child(_auth.currentUser!.uid)
        .child("posts")
        .child("${id}_$index");
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();

    return downloadUrl;
  }

  double _getAspectRatio(File file) {
    final originalImage = img.decodeImage((file).readAsBytesSync());
    int? width = originalImage?.width;
    int? height = originalImage?.height;
    return (height! / width!) * 100.roundToDouble() / 100;
  }

  List<double> getAspectRatios(List<File> files) {
    List<double> aspectRatios = [];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      aspectRatios.add(_getAspectRatio(file));
    }
    return aspectRatios;
  }

  Future<List<String>> uploadPostImage(String id, List<File> files) async {
    List<Future<String>> imageUrlFutures = [];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      imageUrlFutures.add(_uploadIPostImage(file, id, i));
    }
    await Future.wait(imageUrlFutures);
    List<String> urls = [];
    for (int i = 0; i < imageUrlFutures.length; i++) {
      final url = await imageUrlFutures[i];
      urls.add(url);
    }
    return urls;
  }
}
