/*import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getOtherUserPrivacyUsecaseProvider = Provider(
  (ref) => GetOtherUserPrivacyUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class GetOtherUserPrivacyUsecase {
  final FootprintRepository _repository;

  GetOtherUserPrivacyUsecase(this._repository);

  // 特定のユーザーの足あとプライバシー設定を取得
  Future<FootprintPrivacy> getUserFootprintPrivacy(String userId) {
    return _repository.getFootprintPrivacy(userId: userId);
  }
} */