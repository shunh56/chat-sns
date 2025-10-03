import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final visibleProvider = StateProvider((ref) => false);
final angleProvider = StateProvider((ref) => 0.0);
final sizeProvider = StateProvider((ref) => 50.0);
final xPosProvider = StateProvider((ref) => 0.0);
final yPosProvider = StateProvider((ref) => 0.0);
final color01Provider = StateProvider<Color>((ref) => Colors.pink);
final color02Provider = StateProvider<Color>((ref) => Colors.pink);

class HeartAnimationArea extends ConsumerWidget {
  const HeartAnimationArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(visibleProvider);
    final angle = ref.watch(angleProvider);
    final size = ref.watch(sizeProvider);
    final color_01 = ref.watch(color01Provider);
    final color_02 = ref.watch(color02Provider);
    //
    return AnimatedPositioned(
      duration: visible ? const Duration(milliseconds: 400) : Duration.zero,
      curve: Curves.easeInOutQuint,
      left: ref.watch(xPosProvider),
      top: ref.watch(yPosProvider),
      child: AnimatedOpacity(
        duration: visible ? const Duration(milliseconds: 400) : Duration.zero,
        opacity: visible ? 1.0 : 0.0,
        child: AnimatedRotation(
          turns: angle,
          curve: Curves.easeOut,
          duration: visible ? const Duration(milliseconds: 200) : Duration.zero,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color_01,
                  color_02,
                ],
              ).createShader(bounds);
            },
            child: Icon(
              size: size,
              Icons.favorite,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
