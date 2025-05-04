import 'package:app/data/repository/invite_code_repository.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inviteCodeUsecaseProvider = Provider(
  (ref) => InviteCodeUsecase(
    ref.watch(inviteCodeRepositoryProvider),
  ),
);

class InviteCodeUsecase {
  final InviteCodeRepository _repository;
  InviteCodeUsecase(this._repository);

  Future<InviteCode> generateInviteCode() async {
    return await _repository.generateInviteCode();
  }

  Future<InviteCode> getMyCode() async {
    return await _repository.getMyCode();
  }

  Future<InviteCode> getInviteCode(String code) async {
    return await _repository.getInviteCode(code);
  }

  Future<InviteCode> getUsedInviteCode() async {
    return await _repository.getUsedInviteCode();
  }

  Future<void> useCode(String code) async {
    return await _repository.useCode(code);
  }
}
