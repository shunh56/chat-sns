import 'package:app/domain/entity/footprint.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final visitProfileUsecaseProvider = Provider(
  (ref) => VisitProfileUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class VisitProfileUsecase {
  final FootprintRepository _repository;

  VisitProfileUsecase(this._repository);

  // ユーザーのプロフィールを訪問する際に足あとを残す
  Future<void> leaveFootprint(UserAccount user) async {
    // プライバシー設定に基づいて記録するかを判断
    /* final myPrivacy = await _repository.getFootprintPrivacy();
    final theirPrivacy = await _repository.getFootprintPrivacy(userId: user.userId);
    
    // どちらかが無効にしている場合は記録しない
    if (myPrivacy == FootprintPrivacy.disabled || theirPrivacy == FootprintPrivacy.disabled) {
      return;
    } */

    return _repository.addFootprint(user.userId);
  }
}
