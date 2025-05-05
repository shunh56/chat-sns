// Project imports:
import 'package:app/data/repository/mute_repository.dart';
import 'package:app/domain/entity/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final muteUsecaseProvider = Provider<MuteUsecase>(
  (ref) => MuteUsecase(
    ref.watch(muteRepositoryProvider),
  ),
);

class MuteUsecase {
  final MuteRepository _repository;
  MuteUsecase(this._repository);

  Future<List<String>> getMutes() {
    return _repository.getMutes();
  }

  Future<void> muteUser(UserAccount user) {
    return _repository.muteUser(user.userId);
  }

  Future<void> unMuteUser(UserAccount user) {
    return _repository.unMuteUser(user.userId);
  }
}
