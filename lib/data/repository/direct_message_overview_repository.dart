import 'package:app/data/datasource/direct_message_overview_datasource.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmOverviewRepositoryProvider = Provider(
  (ref) => DirectMessageOverviewRepository(
    ref,
    ref.watch(dmOverviewDatasourceProvider),
  ),
);

class DirectMessageOverviewRepository {
  final Ref _ref;
  final DirectMessageOverviewDatasource _datasource;
  DirectMessageOverviewRepository(this._ref, this._datasource);

  Stream<List<DMOverview>> streamDMOverviews() {
    final snapshots = _datasource.streamDMOverviews();
    return snapshots.map((e) =>
        e.docs.map((doc) => DMOverview.fromJson(doc.data(), _ref)).toList());
  }

  closeChat(String userId) {
    return _datasource.closeChat(userId);
  }

  leaveChat(String userId) {
    return _datasource.leaveChat(userId);
  }

  Future<void> joinChat(String userId) {
    return _datasource.joinChat(userId);
  }
}
