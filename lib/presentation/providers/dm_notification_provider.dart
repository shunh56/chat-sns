// lib/presentation/providers/dm_notification_provider.dart

import 'package:app/domain/entity/push_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// DM通知の状態
class DMNotificationState {
  final bool isVisible;
  final PushNotificationModel? notification;

  DMNotificationState({
    this.isVisible = false,
    this.notification,
  });

  DMNotificationState copyWith({
    bool? isVisible,
    PushNotificationModel? notification,
  }) {
    return DMNotificationState(
      isVisible: isVisible ?? this.isVisible,
      notification: notification ?? this.notification,
    );
  }
}

// DebugStateProviderを作成して状態変更を監視できるようにする
final dmNotificationDebugProvider = Provider<String>((ref) {
  final state = ref.watch(dmNotificationProvider);
  return 'Visible: ${state.isVisible}, Notification: ${state.notification != null}';
});

// DM通知ステート用のプロバイダ
final dmNotificationProvider =
    StateNotifierProvider<DMNotificationNotifier, DMNotificationState>(
  (ref) => DMNotificationNotifier(),
);

class DMNotificationNotifier extends StateNotifier<DMNotificationState> {
  DMNotificationNotifier() : super(DMNotificationState());

  // DM通知を表示
  void showNotification(PushNotificationModel notification) {
    debugPrint('DMNotificationNotifier: showNotification called');
    state = state.copyWith(
      isVisible: true,
      notification: notification,
    );

    // 30秒後に非表示に
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        hideNotification();
      }
    });
  }

  // DM通知を非表示
  void hideNotification() {
    debugPrint('DMNotificationNotifier: hideNotification called');
    state = state.copyWith(isVisible: false);
  }
}
