import 'package:app/data/datasource/chat_request_datasource.dart';
import 'package:app/domain/entity/chat_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRequestRepositoryProvider = Provider(
  (ref) => ChatRequestRepository(
    ref.watch(chatRequestDatasourceProvider),
  ),
);

class ChatRequestRepository {
  final ChatRequestDatasource _datasource;

  ChatRequestRepository(this._datasource);

  /// 受信したチャットリクエスト一覧をストリーム
  Stream<List<ChatRequest>> streamReceivedRequests() {
    return _datasource.streamReceivedRequests().map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// 送信したチャットリクエスト一覧をストリーム
  Stream<List<ChatRequest>> streamSentRequests() {
    return _datasource.streamSentRequests().map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRequest.fromJson(doc.data()))
              .toList(),
        );
  }

  /// 特定のユーザーとの間に既存のpendingリクエストがあるかチェック
  Future<ChatRequest?> checkExistingRequest(String otherUserId) {
    return _datasource.checkExistingRequest(otherUserId);
  }

  /// チャットリクエストを送信
  Future<void> sendRequest({
    required String toUserId,
    String? message,
  }) {
    return _datasource.sendRequest(
      toUserId: toUserId,
      message: message,
    );
  }

  /// チャットリクエストを承認
  Future<void> acceptRequest(String requestId) {
    return _datasource.acceptRequest(requestId);
  }

  /// チャットリクエストを却下
  Future<void> rejectRequest(String requestId) {
    return _datasource.rejectRequest(requestId);
  }

  /// チャットリクエストを取得
  Future<ChatRequest?> getRequest(String requestId) {
    return _datasource.getRequest(requestId);
  }

  /// リクエストをキャンセル
  Future<void> cancelRequest(String requestId) {
    return _datasource.cancelRequest(requestId);
  }
}
