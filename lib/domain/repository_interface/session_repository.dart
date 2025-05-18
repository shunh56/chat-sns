import 'package:app/domain/entity/session.dart';

abstract class SessionRepository {
  Future<void> saveSession(Session session);
  Future<Session> createSession();
}
