import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
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
    DateTime now = DateTime.now();
    Reference ref = _storage
        .ref("photos")
        .child(_auth.currentUser!.uid)
        .child("icon_images")
        .child(now.millisecondsSinceEpoch.toString());
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    DebugPrint("ICONURL : $downloadUrl");
    return downloadUrl;
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
