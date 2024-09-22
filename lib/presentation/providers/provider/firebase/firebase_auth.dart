// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = Provider((ref) => FirebaseAuth.instance);

final authChangeProvider = StreamProvider((ref) {
  final firebaseAuth = ref.watch(authProvider);
  return firebaseAuth.userChanges();
});
