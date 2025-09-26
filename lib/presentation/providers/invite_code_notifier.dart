// Package imports:

import 'package:app/domain/entity/invite_code.dart';
import 'package:app/domain/usecases/invite_code_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myInviteCodeNotifierProvider =
    StateNotifierProvider.autoDispose<MyInviteCodeNotifier, InviteCode>(
  (ref) => MyInviteCodeNotifier(
    ref,
    ref.watch(inviteCodeUsecaseProvider),
  )..initialize(),
);

class MyInviteCodeNotifier extends StateNotifier<InviteCode> {
  MyInviteCodeNotifier(this.ref, this.usecase) : super(InviteCode.init());
  final Ref ref;
  final InviteCodeUsecase usecase;

  Future<void> initialize() async {
    InviteCode inviteCode = await usecase.getMyCode();
    if (inviteCode.getStatus == InviteCodeStatus.notFound) {
      inviteCode = await usecase.generateInviteCode();
    }
    if (mounted) {
      state = inviteCode;
    }
  }
}
