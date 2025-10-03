import 'dart:math';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/main_page/components/overlays/heart_animation_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//pink to orange
List<Color> color01 = [
  Colors.pink.shade200,
  Colors.pink.shade300,
  Colors.pink.shade400,
  Colors.orange.shade600,
  Colors.orange.shade700,
  Colors.orange.shade800,
];

//pink to light blue
List<Color> color02 = [
  Colors.pink.shade200,
  Colors.pink.shade300,
  Colors.pink.shade400,
  Colors.cyan.shade200,
  Colors.cyan.shade300,
  Colors.cyan.shade400,
];

final heartAnimationNotifierProvider = Provider(
  (ref) => HeartAnimationNotifier(ref),
);

class HeartAnimationNotifier {
  final Ref ref;

  HeartAnimationNotifier(
    this.ref,
  );

  void showHeart(BuildContext context, double x, double y, double diff) async {
    final themeSize = ref.watch(themeSizeProvider(context));
    final visibleNotifier = ref.read(visibleProvider.notifier);
    final angleNotifier = ref.read(angleProvider.notifier);
    final sizeNotifier = ref.read(sizeProvider.notifier);
    final xPosNotifier = ref.read(xPosProvider.notifier);
    final yPosNotifier = ref.read(yPosProvider.notifier);
    ref.read(color01Provider.notifier).state =
        color01[Random().nextInt(color01.length)];
    ref.read(color02Provider.notifier).state =
        color02[Random().nextInt(color02.length)];

    // 既に表示中の場合は何もしない
    if (ref.read(visibleProvider)) {
      return;
    }

    // 初期位置とサイズを設定
    xPosNotifier.state = x - 36;
    yPosNotifier.state = y - themeSize.appbarHeight;
    sizeNotifier.state = 72.0;
    await Future.delayed(const Duration(milliseconds: 30));
    visibleNotifier.state = true;

    // ハートを振る
    for (int i = 0; i < 3; i++) {
      angleNotifier.state = (i % 2 == 0) ? 1 / 12 : -1 / 12;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    angleNotifier.state = 0;

    // 少し待機
    await Future.delayed(const Duration(milliseconds: 400));

    // 指定の場所に移動
    xPosNotifier.state = themeSize.screenWidth / 2 - 12;
    yPosNotifier.state = -36;

    // サイズを徐々に小さくする
    while (ref.read(sizeProvider) > 20.0) {
      sizeNotifier.state = ref.read(sizeProvider) * 0.95;
      await Future.delayed(const Duration(milliseconds: 20));
    }

    // アニメーション終了後、少し待機してからハートを消す
    await Future.delayed(const Duration(milliseconds: 100));
    visibleNotifier.state = false;

    // 次のアニメーションのために状態をリセット
    await Future.delayed(const Duration(milliseconds: 30));
  }
}
