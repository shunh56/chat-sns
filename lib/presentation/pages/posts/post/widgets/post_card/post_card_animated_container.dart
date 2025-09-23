import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/presentation/pages/posts/post/components/animations/post_animation.dart';

/// アニメーション付きの投稿カードコンテナ
class PostCardAnimatedContainer extends HookConsumerWidget {
  const PostCardAnimatedContainer({
    super.key,
    required this.animations,
    required this.child,
  });

  final PostAnimations animations;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [
          animations.slideAnimation,
          animations.fadeAnimation,
          animations.scaleAnimation,
        ],
      ),
      builder: (context, _) {
        return SlideTransition(
          position: animations.slideAnimation,
          child: FadeTransition(
            opacity: animations.fadeAnimation,
            child: Transform.scale(
              scale: animations.scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 削除アニメーション付きコンテナ
class PostCardDeletingAnimation extends StatelessWidget {
  const PostCardDeletingAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 1.0, end: 0.0),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        if (value <= 0.1) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            heightFactor: value,
            child: Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
