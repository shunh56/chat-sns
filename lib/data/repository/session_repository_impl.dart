import 'package:app/data/datasource/plugins/device_info.dart';
import 'package:app/data/datasource/session_datasource.dart';
import 'package:app/domain/entity/session.dart';
import 'package:app/domain/repository_interface/session_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseAuth _auth;
  final SessionDatasource _datasource;
  final DeviceInfoDatasource _deviceInfoDatasource;

  SessionRepositoryImpl(
    this._auth,
    this._datasource,
    this._deviceInfoDatasource,
  );

  @override
  Future<void> saveSession(Session session) async {
    _datasource.saveSession(session.toJson());
  }

  @override
  Future<Session> createSession() async {
    final String sessionId = const Uuid().v4();
    final String userId = _auth.currentUser!.uid;
    final Map<String, dynamic> deviceInfo =
        await _deviceInfoDatasource.getInfo();
    return Session(
      id: sessionId,
      userId: userId,
      startedAt: Timestamp.now(),
      deviceInfo: deviceInfo,
      actions: [],
      screenViews: [],
    );
  }
}
