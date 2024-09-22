import 'package:app/datasource/invite_code_datasource.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inviteCodeRepositoryProvider = Provider(
  (ref) => InviteCodeRepository(
    ref.watch(inviteCodeDatasourceProvider),
  ),
);

class InviteCodeRepository {
  final InviteCodeDatasource _datasource;
  InviteCodeRepository(this._datasource);

  //CREATE
  generateInviteCode() async {
    final res = await _datasource.generateInviteCode();
    return InviteCode.fromJson(res);
  }

  //READ
  //自分のコードを探してなかったら作成できる
  Future<InviteCode> getMyCode() async {
    final res = await _datasource.getMyCode();
    if (res == null || !res.exists) {
      return InviteCode.notFount();
    } else {
      return InviteCode.fromJson(res.data()!);
    }
  }

  //コードを調べる
  Future<InviteCode> getInviteCode(String code) async {
    final res = await _datasource.fetchInviteCode(code);
    if (!res.exists) {
      return InviteCode.notFount();
    } else {
      return InviteCode.fromJson(res.data()!);
    }
  }
  //UPDATE

  useCode(String code) {
    return _datasource.useCode(code);
  }
  //DELETE
}
