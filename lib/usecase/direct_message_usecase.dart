import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/repository/direct_message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmUsecaseProvider = Provider(
  (ref) => DirectMessageUsecase(
    ref.watch(dmRepositoryProvider),
  ),
);

class DirectMessageUsecase {
  final DirectMessageRepository _repository;
  DirectMessageUsecase(this._repository);

  Future<String> sendMessage(
    String text,
    UserAccount otherUser,
  ) {
    return _repository.sendMessage(text, otherUser.userId);
  }

  sendCurrentStatusReply(
      String text, UserAccount otherUser, CurrentStatusPost post) {
    _repository.sendCurrentStatusReply(text, otherUser.userId, post.id);
  }
}
