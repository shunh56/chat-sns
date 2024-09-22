import 'package:app/datasource/direct_message_datasource.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsDatasourceProvider = Provider(
  (ref) => FriendsDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
    ref.watch(dmDatasourceProvider),
  ),
);

class FriendsDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final DirectMessageDatasource _messageDatasource;

  FriendsDatasource(
    this._auth,
    this._firestore,
    this._messageDatasource,
  );
  final collectionName = "friends";
  final requestsCollection = "friendRequests";
  final requestedsCollection = "friendRequesteds";

  //CREATE

  sendFriendRequest(String userId) async {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(requestsCollection)
        .doc(userId)
        .set({
      "userId": userId,
      "createdAt": Timestamp.now(),
    });
    _firestore
        .collection("users")
        .doc(userId)
        .collection(requestedsCollection)
        .doc(_auth.currentUser!.uid)
        .set({
      "userId": _auth.currentUser!.uid,
      "createdAt": Timestamp.now(),
    });
  }

  void admitFriendRequested(String userId) {
    _addFriend(userId);
    deleteRequest(userId);
    deleteRequested(userId);
  }

  void _addFriend(String userId) {
    if (userId == _auth.currentUser!.uid) {
      debugPrint("invitecode user and user is SAME!");
      throw Exception("Cannot add yourself as friend!");
    }
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .doc(userId)
        .set({
      "userId": userId,
      "createdAt": Timestamp.now(),
    });
    _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .set({
      "userId": _auth.currentUser!.uid,
      "createdAt": Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot<Map<String, dynamic>>> streamFriendRequesteds() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(requestedsCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFriendRequests() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(requestsCollection)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFriends() {
    return _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFriends(
      String userId) async {
    return await _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .get();
  }

  //UPDATE

  //DELETE
  void deleteRequest(String userId) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(requestsCollection)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(requestedsCollection)
        .doc(_auth.currentUser!.uid)
        .delete();
  }

  void deleteRequested(String userId) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(requestedsCollection)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(requestsCollection)
        .doc(_auth.currentUser!.uid)
        .delete();
  }

  void deleteFriend(String userId) {
    _firestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .collection(collectionName)
        .doc(userId)
        .delete();
    _firestore
        .collection("users")
        .doc(userId)
        .collection(collectionName)
        .doc(_auth.currentUser!.uid)
        .delete();
  }
}
