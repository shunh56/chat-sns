/*import 'package:app/domain/usecases/footprint/update_notify_setting_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 通知設定のキャッシュ
final footprintNotificationProvider = StateNotifierProvider<NotificationSettingNotifier, AsyncValue<bool>>(
  (ref) => NotificationSettingNotifier(
    ref.watch(updateNotifySettingUsecaseProvider),
  ),
);

class NotificationSettingNotifier extends StateNotifier<AsyncValue<bool>> {
  final UpdateNotifySettingUsecase _updateNotifySettingUsecase;
  
  NotificationSettingNotifier(this._updateNotifySettingUsecase) 
      : super(const AsyncValue.data(true)) {  // デフォルトで通知オン
    // 設定を読み込む処理を追加すると良い
  }
  
  Future<void> updateNotificationSetting(bool enabled) async {
    try {
      // 楽観的UI更新
      state = AsyncValue.data(enabled);
      
      // バックエンドに保存
      await _updateNotifySettingUsecase.setFootprintNotifications(enabled);
    } catch (e, stackTrace) {
      // エラー時は元の状態に戻す
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
} */
