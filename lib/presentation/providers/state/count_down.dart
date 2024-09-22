import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpodのプロバイダー
final countdownProvider =
    StateNotifierProvider.autoDispose<CountdownNotifier, Duration>(
  (ref) => CountdownNotifier(),
);

class CountdownNotifier extends StateNotifier<Duration> {
  CountdownNotifier() : super(const Duration(minutes: 20));

  Timer? _timer;

  // カウントダウンを開始するメソッド
  void startCountdown(DateTime targetTime) {
    final time = state;
    DebugPrint("time : $time");
    if (time == const Duration(minutes: 20)) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final remainingTime = targetTime.difference(now);
        if (mounted) {
          if (remainingTime.isNegative) {
            _timer?.cancel();
          }
          state = remainingTime;
        }
      });
    }
  }
}
