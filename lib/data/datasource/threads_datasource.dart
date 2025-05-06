import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final threadsDatasourceProvider = Provider(
  (ref) => ThreadsDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class ThreadsDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  ThreadsDatasource(this._auth, this._firestore);

  final collectionName = "threads";

  //CREATE
  followThread(String id) {
    final timestamp = Timestamp.now();
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followingThreads")
        .doc(id)
        .set({
      "id": id,
      "createdAt": timestamp,
    });
    _firestore
        .collection(collectionName)
        .doc(id)
        .collection("followers")
        .doc(_auth.currentUser!.uid)
        .set({
      "userId": _auth.currentUser!.uid,
      "createdAt": timestamp,
    });
  }

  //READ
  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllThreads() async {
    return await _firestore.collection(collectionName).get();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      fetchFollowingThreads() async {
    final query = await _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followingThreads")
        .get();
    List<String> followingThreadIds = query.docs.map((doc) => doc.id).toList();
    List<Future<DocumentSnapshot<Map<String, dynamic>>>> futures = [];
    for (String id in followingThreadIds) {
      futures.add(getSingleThread(id));
    }
    await Future.wait(futures);
    List<DocumentSnapshot<Map<String, dynamic>>> docs = [];
    for (var item in futures) {
      final doc = (await item);
      docs.add(doc);
    }
    return docs;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSingleThread(
      String id) async {
    return await _firestore.collection(collectionName).doc(id).get();
  }

  //UPDATE
  //DELETE
  unfollowThread(String id) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection("followingThreads")
        .doc(id)
        .delete();
    _firestore
        .collection(collectionName)
        .doc(id)
        .collection("followers")
        .doc(_auth.currentUser!.uid)
        .delete();
  }
}
