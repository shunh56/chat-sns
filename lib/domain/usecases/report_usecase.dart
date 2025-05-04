import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/state/report_form.dart';
import 'package:app/data/repository/report_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final reportUsecaseProvider = Provider(
  (ref) => ReportUsecase(
    ref.watch(authProvider),
    ref.watch(reportRepositoryProvider),
  ),
);

class ReportUsecase {
  final FirebaseAuth _auth;
  final ReportRepository _repository;

  ReportUsecase(
    this._auth,
    this._repository,
  );

  reportUser(ReportForm form) {
    return _repository.reportUser(form.toJson());
  }

  reportBug({
    required String reason,
    required String description,
  }) {
    final json = {
      "id": const Uuid().v4(),
      "createdAt": Timestamp.now(),
      "reason": reason,
      "description": description,
      "userId": _auth.currentUser!.uid,
    };
    return _repository.reportBug(json);
  }

  reportForm({
    required String type,
    required String description,
  }) {
    final json = {
      "id": const Uuid().v4(),
      "createdAt": Timestamp.now(),
      "type": type,
      "description": description,
      "userId": _auth.currentUser!.uid,
    };
    return _repository.reportForm(json);
  }
}
