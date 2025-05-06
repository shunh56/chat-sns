/*import 'package:app/domain/entity/footprint.dart';
import 'package:app/domain/usecases/footprint/get_privacy_setting_usecase.dart';
import 'package:app/domain/usecases/footprint/update_privacy_setting_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// プライバシー設定のキャッシュ
final footprintPrivacyProvider = StateNotifierProvider<PrivacySettingNotifier, AsyncValue<FootprintPrivacy>>(
  (ref) => PrivacySettingNotifier(
    ref.watch(getPrivacySettingUsecaseProvider),
    ref.watch(updatePrivacySettingUsecaseProvider),
  ),
);

class PrivacySettingNotifier extends StateNotifier<AsyncValue<FootprintPrivacy>> {
  final GetPrivacySettingUsecase _getPrivacySettingUsecase;
  final UpdatePrivacySettingUsecase _updatePrivacySettingUsecase;
  
  PrivacySettingNotifier(this._getPrivacySettingUsecase, this._updatePrivacySettingUsecase) 
      : super(const AsyncValue.loading()) {
    loadPrivacySetting();
  }
  
  Future<void> loadPrivacySetting() async {
    try {
      state = const AsyncValue.loading();
      final privacy = await _getPrivacySettingUsecase.getFootprintPrivacySetting();
      state = AsyncValue.data(privacy);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> updatePrivacy(FootprintPrivacy privacy) async {
    try {
      // 楽観的UI更新（即座にUIに反映）
      final previousState = state;
      state = AsyncValue.data(privacy);
      
      // バックエンドに保存
      await _updatePrivacySettingUsecase.updateFootprintPrivacy(privacy);
    } catch (e, stackTrace) {
      // エラー時は元の状態に戻す
      state = AsyncValue.error(e, stackTrace);
      
      // エラーを再スロー
      rethrow;
    }
  }
} */