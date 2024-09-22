import 'package:app/datasource/direct_message_datasource.dart';
import 'package:app/datasource/direct_message_overview_datasource.dart';
import 'package:app/domain/entity/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmRepositoryProvider = Provider(
  (ref) => DirectMessageRepository(
    ref,
    ref.watch(dmDatasourceProvider),
    ref.watch(dmOverviewDatasourceProvider),
  ),
);

class DirectMessageRepository {
  final Ref _ref;
  final DirectMessageDatasource _dmDatasource;
  final DirectMessageOverviewDatasource _overviewDatasource;
  DirectMessageRepository(
      this._ref, this._dmDatasource, this._overviewDatasource);

  Future<List<CoreMessage>> getMessages(String id) async {
    final query = await _dmDatasource.fetchMessages(id);
    return query.docs.map((e) {
      final type = e.data()['type'];

      if (type == "currentStatus_reply") {
        return CurrentStatusMessage.fromJson(e.data());
      } else {
        return Message.fromJson(e.data());
      }
    }).toList();
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

  sendMessage(String text, String otherUserId) {
    _dmDatasource.sendMessage(text, otherUserId);
  }

  sendCurrentStatusReply(String text, String userId, String postId) {
    _dmDatasource.sendCurrentStatusReply(text, userId, postId);
  }
}
