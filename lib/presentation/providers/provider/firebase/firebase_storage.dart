// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageProvider = Provider((ref) => FirebaseStorage.instance);
