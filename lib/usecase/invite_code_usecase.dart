import 'package:app/repository/invite_code_repository.dart';
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

  //CREATE
  Future<InviteCode> generateInviteCode() async {
    return await _repository.generateInviteCode();
  }

  //READ
  //自分のコードを探してなかったら作成できる
  Future<InviteCode> getMyCode() async {
    return await _repository.getMyCode();
  }

  //コードを調べる
  Future<InviteCode> getInviteCode(String code) async {
    return await _repository.getInviteCode(code);
  }
  //UPDATE

  useCode(String code) {
    return _repository.useCode(code);
  }
  //DELETE
}
