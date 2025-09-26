import 'dart:math';

import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inviteCodeDatasourceProvider = Provider(
  (ref) => InviteCodeDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class InviteCodeDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  InviteCodeDatasource(this._auth, this._firestore);

  final collectionName = "invite_code";

  Future<Map<String, dynamic>> generateInviteCode() async {
    while (true) {
      String code = _generateCode();
      final doc = await fetchInviteCode(code);
      if (!doc.exists) {
        final map = {
          "id": code,
          "createdAt": Timestamp.now(),
          "userId": _auth.currentUser!.uid,
          "logs": [],
        };
        await _firestore.collection(collectionName).doc(code).set(map);
        return map;
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getMyCode() async {
    final query = await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: _auth.currentUser!.uid)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUsedInviteCode() async {
    final query = await _firestore
        .collection(collectionName)
        .where("logs", arrayContains: {
      "userId": _auth.currentUser!.uid,
    }).get();

    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchInviteCode(
      String code) async {
    return await _firestore.collection(collectionName).doc(code).get();
  }

  Future<void> useCode(String code) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not signed in");

    final codeDoc = await fetchInviteCode(code);
    if (!codeDoc.exists) throw Exception("Invalid invite code");

    if (codeDoc.data()?["userId"] == currentUser.uid) {
      throw Exception("Cannot use your own invite code");
    }

    final logs = List<Map<String, dynamic>>.from(codeDoc.data()?["logs"] ?? []);
    if (logs.any((log) => log["userId"] == currentUser.uid)) {
      throw Exception("Already used this code");
    }

    // ユーザードキュメントに使用した招待コードを記録
    await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .update({"usedInviteCode": code});

    return _firestore.collection(collectionName).doc(code).update({
      "logs": FieldValue.arrayUnion([
        {
          "createdAt": Timestamp.now(),
          "userId": currentUser.uid,
        }
      ]),
    });
  }

  String _generateCode() {
    const String upperCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    final Random random = Random();
    String randomUpperCase = '';
    String randomDigits = '';

    for (int i = 0; i < 6; i++) {
      randomUpperCase +=
          upperCaseLetters[random.nextInt(upperCaseLetters.length)];
    }
    for (int i = 0; i < 2; i++) {
      randomDigits += digits[random.nextInt(digits.length)];
    }

    return randomUpperCase + randomDigits;
  }
}
