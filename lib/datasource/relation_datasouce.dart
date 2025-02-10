import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final relationDatasourceProvider = Provider(
  (ref) => RelationDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class RelationDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RelationDatasource(this._auth, this._firestore);
  final collectionName = "relations";

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamRelation() {
    return _firestore
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .snapshots();
  }

  /*addFriend(String userId) async {
    final batch = _firestore.batch();
    final myUserRef =
        _firestore.collection(userCollectionName).doc(_auth.currentUser!.uid);
    final userUserRef =
        _firestore.collection(userCollectionName).doc(_auth.currentUser!.uid);
    batch.update(myUserRef, {
      'friendIds': FieldValue.arrayUnion([userId]),
    });
    batch.update(userUserRef, {
      'friendIds': FieldValue.arrayUnion([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('フレンド追加に失敗しました。');
    }
  }

  deleteFriend(String userId) async {
    final batch = _firestore.batch();
    final myUserRef =
        _firestore.collection(userCollectionName).doc(_auth.currentUser!.uid);
    final userUserRef =
        _firestore.collection(userCollectionName).doc(_auth.currentUser!.uid);
    batch.update(myUserRef, {
      'friendIds': FieldValue.arrayRemove([userId]),
    });
    batch.update(userUserRef, {
      'friendIds': FieldValue.arrayRemove([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('フレンド削除に失敗しました。');
    }
  }
 */
  //
  sendRequest(String userId) async {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);

    batch.update(myRef, {
      'requests': FieldValue.arrayUnion([userId]),
    });
    batch.update(userRef, {
      'requesteds': FieldValue.arrayUnion([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('リクエスト送信に失敗しました。');
    }
  }

  admitRequested(String userId) async {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);

    batch.update(myRef, {
      'requesteds': FieldValue.arrayRemove([userId]),
    });
    batch.update(userRef, {
      'requests': FieldValue.arrayRemove([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('リクエスト承認に失敗しました。Ï');
    }
  }

  deleteRequest(String userId) async {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);

    batch.update(myRef, {
      'requests': FieldValue.arrayRemove([userId]),
    });
    batch.update(userRef, {
      'requesteds': FieldValue.arrayRemove([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('リクエストの取り消しに失敗しました。');
    }
  }

  deleteRequested(String userId) async {
    final batch = _firestore.batch();
    final myRef =
        _firestore.collection(collectionName).doc(_auth.currentUser!.uid);
    final userRef = _firestore.collection(collectionName).doc(userId);
    batch.update(myRef, {
      'requesteds': FieldValue.arrayRemove([userId]),
    });
    batch.update(userRef, {
      'requests': FieldValue.arrayRemove([_auth.currentUser!.uid]),
    });
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('リクエストのキャンセルに失敗しました。');
    }
  }

}
