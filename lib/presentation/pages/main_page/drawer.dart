import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;

class MainPageDrawer extends HookConsumerWidget {
  const MainPageDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dmAsyncValue = ref.watch(dmOverviewListNotifierProvider);

    return Drawer(
      width: 92,
      clipBehavior: Clip.none,
      backgroundColor: ThemeColor.accent,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            dmAsyncValue.when(
              data: (list) {
                if (list.isEmpty) {
                  return const SizedBox();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final overview = list[index];

                    return UserWidget(
                      userId: overview.userId,
                      builder: (user) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: ThemeColor.accent,
                          highlightColor: ThemeColor.white.withOpacity(0.1),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  ref
                                      .read(navigationRouterProvider(context))
                                      .goToChat(user);
                                },
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: UserIcon(
                                        user: user,
                                        r: 30,
                                      ),
                                    ),
                                    if (overview.isNotSeen)
                                      const Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: PulseAnimationWidget(
                                          child: CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (e, s) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

// 揺れるアニメーションウィジェット（HookConsumerWidget版）
class ShakeAnimationWidget extends HookConsumerWidget {
  const ShakeAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.shakeIntensity = 0.02,
  });

  final Widget child;
  final Duration duration;
  final double shakeIntensity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // useAnimationControllerでアニメーションコントローラーを作成
    final controller = useAnimationController(
      duration: duration,
    );

    // 回転アニメーション
    final rotationAnimation = useAnimation(
      Tween<double>(
        begin: -shakeIntensity,
        end: shakeIntensity,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    );

    // スケールアニメーション
    final scaleAnimation = useAnimation(
      Tween<double>(
        begin: 0.98,
        end: 1.02,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    );

    // アニメーションの開始
    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, []);

    return Transform.rotate(
      angle: rotationAnimation,
      child: Transform.scale(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}

// パルスアニメーションウィジェット（HookConsumerWidget版）
class PulseAnimationWidget extends HookConsumerWidget {
  const PulseAnimationWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: duration,
    );

    final opacityAnimation = useAnimation(
      Tween<double>(
        begin: minOpacity,
        end: maxOpacity,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
    );

    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, []);

    return Opacity(
      opacity: opacityAnimation,
      child: Transform.scale(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}

// より自然な揺れアニメーション（HookConsumerWidget版）
class NaturalShakeWidget extends HookConsumerWidget {
  const NaturalShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.rotationIntensity = 0.03,
    this.scaleIntensity = 0.01,
  });

  final Widget child;
  final Duration duration;
  final double rotationIntensity;
  final double scaleIntensity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: duration,
    );

    final animation = useAnimation(
      Tween<double>(
        begin: 0,
        end: 2 * math.pi,
      ).animate(controller),
    );

    useEffect(() {
      controller.repeat();
      return null;
    }, []);

    // サイン波を使った自然な動き
    final rotation = math.sin(animation) * rotationIntensity;
    final scale = 1.0 + math.sin(animation * 1.5) * scaleIntensity;

    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}

// カスタムアニメーションプロバイダー（より高度な制御用）
final shakeAnimationProvider = Provider.family<double, String>((ref, key) {
  // Riverpodベースのアニメーション状態管理
  return 0.0;
});

// アニメーション状態を管理するNotifier
class AnimationStateNotifier extends StateNotifier<Map<String, bool>> {
  AnimationStateNotifier() : super({});

  void setAnimating(String key, bool isAnimating) {
    state = {...state, key: isAnimating};
  }

  bool isAnimating(String key) {
    return state[key] ?? false;
  }
}

final animationStateProvider =
    StateNotifierProvider<AnimationStateNotifier, Map<String, bool>>(
  (ref) => AnimationStateNotifier(),
);

// より複雑なアニメーション制御が可能なウィジェット
class AdvancedShakeWidget extends HookConsumerWidget {
  const AdvancedShakeWidget({
    super.key,
    required this.child,
    required this.animationKey,
    this.duration = const Duration(milliseconds: 1500),
  });

  final Widget child;
  final String animationKey;
  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(duration: duration);
    final animationState = ref.watch(animationStateProvider);
    final isAnimating = animationState[animationKey] ?? false;

    final rotationAnimation = useAnimation(
      Tween<double>(begin: -0.02, end: 0.02).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    useEffect(() {
      if (isAnimating) {
        controller.repeat(reverse: true);
      } else {
        controller.stop();
        controller.reset();
      }
      return null;
    }, [isAnimating]);

    return Transform.rotate(
      angle: rotationAnimation,
      child: Transform.scale(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}

// 使用例：より細かい制御が必要な場合
class ControlledAnimationExample extends HookConsumerWidget {
  const ControlledAnimationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // アニメーションを手動で開始/停止
        final notifier = ref.read(animationStateProvider.notifier);
        final isCurrentlyAnimating =
            ref.read(animationStateProvider)['example'] ?? false;
        notifier.setAnimating('example', !isCurrentlyAnimating);
      },
      child: AdvancedShakeWidget(
        animationKey: 'example',
        child: Container(
          width: 50,
          height: 50,
          color: Colors.blue,
        ),
      ),
    );
  }
}
