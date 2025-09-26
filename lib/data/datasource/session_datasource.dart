import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionDatasourceProvider = Provider(
  (ref) => SessionDatasource(
    ref.watch(firestoreProvider),
  ),
);

class SessionDatasource {
  final FirebaseFirestore _firestore;

  final String collectionName = "analytics-sessions";

  SessionDatasource(
    this._firestore,
  );

  saveSession(Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).doc(data['id']).set(data);
  }
}
