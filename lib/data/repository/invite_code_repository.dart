import 'package:app/data/datasource/invite_code_datasource.dart';
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

  Future<InviteCode> generateInviteCode() async {
    final res = await _datasource.generateInviteCode();
    return InviteCode.fromJson(res);
  }

  Future<InviteCode> getMyCode() async {
    final res = await _datasource.getMyCode();
    if (res == null || !res.exists) {
      return InviteCode.notFount();
    }
    return InviteCode.fromJson(res.data()!);
  }

  Future<InviteCode> getInviteCode(String code) async {
    final res = await _datasource.fetchInviteCode(code);
    if (!res.exists) {
      return InviteCode.notFount();
    }
    return InviteCode.fromJson(res.data()!);
  }

  Future<InviteCode> getUsedInviteCode() async {
    final res = await _datasource.getUsedInviteCode();
    if (res == null || !res.exists) {
      return InviteCode.notFount();
    }
    return InviteCode.fromJson(res.data()!);
  }

  Future<void> useCode(String code) async {
    return await _datasource.useCode(code);
  }
}
