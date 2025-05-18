// 基本的なセッション関連の例外クラス
class SessionException implements Exception {
  final String message;

  SessionException(this.message);

  @override
  String toString() => 'SessionException: $message';
}

// より具体的な例外クラス
class NoActiveSessionException extends SessionException {
  NoActiveSessionException(super.message);
}

class SessionNotFoundException extends SessionException {
  SessionNotFoundException(super.message);
}

class ServerException extends SessionException {
  ServerException(super.message);
}
