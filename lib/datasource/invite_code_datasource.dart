import 'dart:math';

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
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

  //CREATE
  Future<Map<String, dynamic>> generateInviteCode() async {
    while (true) {
      String code = _generateCode();
      final doc = await fetchInviteCode(code);
      if (!doc.exists) {
        final map = {
          "id": code,
          "createdAt": Timestamp.now(),
          "userId": _auth.currentUser!.uid,
          "slot": [],
          "logs": [],
          "maxCount": 5,
        };
        _firestore.collection(collectionName).doc(code).set(map);
        return map;
      }
      continue;
    }
  }
  //READ

  //自分のコードを探してなかったら作成できる
  Future<DocumentSnapshot<Map<String, dynamic>>?> getMyCode() async {
    final query = await _firestore
        .collection(collectionName)
        .where("userId", isEqualTo: _auth.currentUser!.uid)
        .get();
    if (query.docs.isEmpty) {
      return null;
    } else {
      return query.docs.first;
    }
  }

  //コードを調べる
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchInviteCode(
      String code) async {
    return await _firestore.collection(collectionName).doc(code).get();
  }
  //UPDATE

  useCode(String code) {
    return _firestore.collection(collectionName).doc(code).update({
      "slot": FieldValue.arrayUnion(
        [_auth.currentUser!.uid],
      ),
      "logs": FieldValue.arrayUnion([
        {
          "type": "use",
          "createdAt": Timestamp.now(),
          "userId": _auth.currentUser!.uid,
        }
      ]),
    });
  }
  //DELETE

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
