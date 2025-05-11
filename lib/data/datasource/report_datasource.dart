import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportDatasourceProvider = Provider(
  (ref) => ReportDatasource(
    ref.watch(firestoreProvider),
  ),
);

class ReportDatasource {
  final FirebaseFirestore _firestore;

  ReportDatasource(this._firestore);

  reportUser(Map<String, dynamic> json) {
    return _firestore.collection("report_users").doc(json["id"]).set(json);
  }

  reportBug(Map<String, dynamic> json) {
    return _firestore.collection("report_bugs").doc(json["id"]).set(json);
  }

  reportForm(Map<String, dynamic> json) {
    return _firestore.collection("report_form").doc(json["id"]).set(json);
  }
}
