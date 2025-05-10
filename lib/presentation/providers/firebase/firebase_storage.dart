// Package imports:
import 'package:app/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//final storageProvider = Provider((ref) => FirebaseStorage.instance);
final storageProvider = Provider((ref) {
  return FirebaseStorage.instance;
  return FirebaseStorage.instanceFor(
    bucket: flavor == "dev"
        ? "gs://chat-sns-project.appspot.com"
        : "gs://blank-project-prod.firebasestorage.app",
  );
});
