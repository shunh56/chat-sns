import 'package:app/data/datasource/direct_message_datasource.dart';
import 'package:app/domain/entity/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmRepositoryProvider = Provider(
  (ref) => DirectMessageRepository(
    ref.watch(dmDatasourceProvider),
  ),
);

class DirectMessageRepository {
  final DirectMessageDatasource _dmDatasource;

  DirectMessageRepository(
    this._dmDatasource,
  );

  Future<List<CoreMessage>> getMessages(
    String id, {
    Timestamp? lastTimestamp,
  }) async {
    final query = await _dmDatasource.fetchMessages(
      id,
      lastTimestamp: lastTimestamp,
    );
    if (query.docs.isNotEmpty) {
      return query.docs.map((e) {
        final type = e.data()['type'];
        if (type == "currentStatus_reply") {
          return CurrentStatusMessage.fromJson(e.data());
        } else {
          return Message.fromJson(e.data());
        }
      }).toList();
    } else {
      return [];
    }
  }

  Stream<List<CoreMessage>> streamMessages(String id) {
    final stream = _dmDatasource.streamMessages(id);
    return stream.map(
      (event) => event.docs.map((e) {
        final type = e.data()['type'];
        if (type == "currentStatus_reply") {
          return CurrentStatusMessage.fromJson(e.data());
        } else {
          return Message.fromJson(e.data());
        }
      }).toList(),
    );
  }

  Future<String> sendMessage(String text, String otherUserId) {
    return _dmDatasource.sendMessage(text, otherUserId);
  }

  sendCurrentStatusReply(String text, String userId, String postId) {
    _dmDatasource.sendCurrentStatusReply(text, userId, postId);
  }
}
