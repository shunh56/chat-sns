import 'dart:io';

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageUploaderNotifierProvider = Provider(
  (ref) => ImageUploaderNotifier(
    ref.watch(storageProvider),
    ref.watch(authProvider),
  ),
);

class ImageUploaderNotifier {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  ImageUploaderNotifier(
    this._storage,
    this._auth,
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
    return downloadUrl;
  }

  Future<List<String>> uploadPostImage(String id, List<File> files) async {
    List<UploadTask> tasks = [];

    for (var i = 0; i < files.length; i++) {
      Reference ref = _storage
          .ref("photos")
          .child(_auth.currentUser!.uid)
          .child("posts")
          .child("${id}_$i");
      UploadTask uploadTask = ref.putFile(files[i]);
      tasks.add(uploadTask);
    }
    await Future.wait(tasks);
    List<Future<String>> urls = [];

    for (int i = 0; i < tasks.length; i++) {
      final snap = await tasks[i];
      urls.add(snap.ref.getDownloadURL());
    }

    await Future.wait(urls);
    List<String> result = [];
    for (int i = 0; i < tasks.length; i++) {
      result.add(await urls[i]);
    }
    return result;
  }
}
