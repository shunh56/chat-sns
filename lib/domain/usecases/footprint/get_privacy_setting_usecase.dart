/*import 'package:app/domain/entity/footprint.dart';
import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getPrivacySettingUsecaseProvider = Provider(
  (ref) => GetPrivacySettingUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class GetPrivacySettingUsecase {
  final FootprintRepository _repository;

  GetPrivacySettingUsecase(this._repository);

  // 足あとのプライバシー設定を取得
  Future<FootprintPrivacy> getFootprintPrivacySetting() {
    return _repository.getFootprintPrivacy();
  }
} */