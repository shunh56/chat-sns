import 'package:app/domain/entity/user.dart';
import 'package:app/data/repository/direct_message_repository.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dmUsecaseProvider = Provider(
  (ref) => DirectMessageUsecase(
    ref,
    ref.watch(dmRepositoryProvider),
  ),
);

class DirectMessageUsecase {
  final Ref _ref;
  final DirectMessageRepository _repository;
  DirectMessageUsecase(this._ref, this._repository);

  Future<String> sendMessage(
    String text,
    UserAccount user,
  ) {
    _ref.read(pushNotificationUsecaseProvider).sendDm(user, text);
    return _repository.sendMessage(text, user.userId);
  }
}
