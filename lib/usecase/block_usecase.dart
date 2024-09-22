// Project imports:
import 'package:app/domain/entity/user.dart';
import 'package:app/repository/block_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final blockUsecaseProvider = Provider<BlockUsecase>(
  (ref) => BlockUsecase(
    ref.watch(blockRepositoryProvider),
  ),
);

class BlockUsecase {
  final BlockRepository _repository;
  BlockUsecase(this._repository);

  Future<List<String>> getBlocks() {
    return _repository.getBlocks();
  }

  Stream<List<String>> streamBlockeds() {
    return _repository.streamBlockeds();
  }

  Future<void> blockUser(UserAccount user) {
    return _repository.blockUser(user.userId);
  }

  Future<void> unblockUser(UserAccount user) {
    return _repository.unblockUser(user.userId);
  }
}
