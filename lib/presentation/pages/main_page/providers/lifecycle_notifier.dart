import 'package:app/presentation/services/token_refresh_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../../../providers/shared/app/session_provider.dart';
import '../../../providers/shared/users/my_user_account_notifier.dart';

/// アプリライフサイクル管理プロバイダー
final lifecycleNotifierProvider =
    StateNotifierProvider<LifecycleNotifier, LifecycleState>((ref) {
  return LifecycleNotifier(ref);
});

/// ライフサイクル状態
class LifecycleState {
  final AppLifecycleState currentState;
  final bool isTrackingPermissionRequested;
  final bool isInitialized;

  const LifecycleState({
    this.currentState = AppLifecycleState.resumed,
    this.isTrackingPermissionRequested = false,
    this.isInitialized = false,
  });

  LifecycleState copyWith({
    AppLifecycleState? currentState,
    bool? isTrackingPermissionRequested,
    bool? isInitialized,
  }) {
    return LifecycleState(
      currentState: currentState ?? this.currentState,
      isTrackingPermissionRequested:
          isTrackingPermissionRequested ?? this.isTrackingPermissionRequested,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// アプリライフサイクル管理クラス
class LifecycleNotifier extends StateNotifier<LifecycleState> {
  final Ref _ref;

  LifecycleNotifier(this._ref) : super(const LifecycleState());

  /// 初期化処理 (アプリ起動時のみ1回)
  Future<void> initialize() async {
    if (state.isInitialized) return;

    // ★ デバイス登録 (初回のみ)
    await _ref.read(myAccountNotifierProvider.notifier).registerDeviceIfNeeded();

    // ★ トークンリフレッシュリスナーを開始
    _ref.read(tokenRefreshServiceProvider).initialize();

    // ユーザーをオンライン状態に
    await _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);

    // トラッキング許可の初期化
    await _initializeTracking();

    state = state.copyWith(isInitialized: true);
  }

  /// トラッキング許可の初期化
  Future<void> _initializeTracking() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined &&
          !state.isTrackingPermissionRequested) {
        // 少し待ってからトラッキング許可をリクエスト
        await Future.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();

        state = state.copyWith(isTrackingPermissionRequested: true);
      }
    } catch (e) {
      // トラッキング許可の取得に失敗した場合は無視
    }
  }

  /// アプリライフサイクル状態変更時の処理
  void onLifecycleStateChanged(AppLifecycleState lifecycleState) {
    state = state.copyWith(currentState: lifecycleState);

    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _handleAppPaused();
        break;
      default:
        break;
    }
  }

  /// アプリがフォアグラウンドに戻った時の処理
  void _handleAppResumed() {
    // ★ 変更: デバイス登録はせず、オンライン状態のみ更新
    _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);

    // セッションを開始
    _ref.read(sessionStateProvider.notifier).startSession();
  }

  /// アプリがバックグラウンドに移った時の処理
  void _handleAppPaused() {
    // ★ オフライン状態に
    _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(false);

    // セッションを終了
    _ref.read(sessionStateProvider.notifier).endSession();
  }

  /// 廃棄処理
  @override
  void dispose() {
    // 必要に応じてリソースのクリーンアップを実行
    super.dispose();
  }
}
