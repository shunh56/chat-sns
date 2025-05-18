// Project imports:

import 'package:app/data/datasource/block_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockRepositoryProvider = Provider(
  (ref) => BlockRepository(
    ref.watch(blockDatasourceProvider),
  ),
);

class BlockRepository {
  final BlockDatasource _blockDatasource;

  BlockRepository(
    this._blockDatasource,
  );

  Future<List<String>> getBlocks() async {
    final res = await _blockDatasource.getBlocks();
    return res.docs.map((e) => e.id).toList();
  }

  Stream<List<String>> streamBlockeds() {
    final stream = _blockDatasource.streamBlockeds();
    return stream.map((event) {
      return event.docs.map((e) => e.id).toList();
    });
  }

  Future<void> blockUser(String userId) async {
    _blockDatasource.blockUser(userId);
    //TODO
    /* _friendsDatasource.deleteFriend(userId);
    _friendsDatasource.deleteRequest(userId);
    _friendsDatasource.deleteRequested(userId); */
    return;
  }

  Future<void> unblockUser(String userId) async {
    return await _blockDatasource.unblockUser(userId);
  }
}
