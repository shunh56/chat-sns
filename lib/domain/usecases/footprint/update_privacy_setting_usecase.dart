/*import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updatePrivacySettingUsecaseProvider = Provider(
  (ref) => UpdatePrivacySettingUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class UpdatePrivacySettingUsecase {
  final FootprintRepository _repository;

  UpdatePrivacySettingUsecase(this._repository);

  // 足あとのプライバシー設定を更新
  Future<void> updateFootprintPrivacy(FootprintPrivacy privacy) {
    return _repository.updateFootprintPrivacy(privacy);
  }
} */
