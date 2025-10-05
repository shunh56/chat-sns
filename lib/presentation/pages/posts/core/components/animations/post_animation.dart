import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/presentation/providers/state/scroll_controller.dart';

/// 投稿カード用のアニメーション管理クラス
class PostAnimations {
  final AnimationController slideController;
  final AnimationController fadeController;
  final AnimationController scaleController;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  PostAnimations({
    required this.slideController,
    required this.fadeController,
    required this.scaleController,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });
}

/// 投稿カードのアニメーションを管理するHook
PostAnimations usePostAnimations({
  required int index,
  required String postId,
  required WidgetRef ref,
  Duration slideDuration = const Duration(milliseconds: 600),
  Duration fadeDuration = const Duration(milliseconds: 800),
  Duration scaleDuration = const Duration(milliseconds: 200),
}) {
  final slideController = useAnimationController(
    duration:
        Duration(milliseconds: slideDuration.inMilliseconds + index * 100),
  );

  final fadeController = useAnimationController(
    duration: Duration(milliseconds: fadeDuration.inMilliseconds + index * 50),
  );

  final scaleController = useAnimationController(
    duration: scaleDuration,
  );

  final slideAnimation = useMemoized(
    () => Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideController,
        curve: Curves.elasticOut,
      ),
    ),
    [slideController],
  );

  final fadeAnimation = useMemoized(
    () => Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: Curves.easeInOut,
      ),
    ),
    [fadeController],
  );

  final scaleAnimation = useMemoized(
    () => Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: scaleController,
        curve: Curves.easeInOut,
      ),
    ),
    [scaleController],
  );

  useEffect(() {
    final animatedPosts = ref.read(animatedPostsProvider.notifier);
    final hasBeenAnimated = animatedPosts.hasBeenAnimated(postId);

    if (hasBeenAnimated) {
      slideController.value = 1.0;
      fadeController.value = 1.0;
    } else {
      Future.delayed(Duration(milliseconds: index * 100), () {
        slideController.forward();
        fadeController.forward();
        animatedPosts.addAnimatedPost(postId);
      });
    }
    return null;
  }, [postId]);

  return PostAnimations(
    slideController: slideController,
    fadeController: fadeController,
    scaleController: scaleController,
    slideAnimation: slideAnimation,
    fadeAnimation: fadeAnimation,
    scaleAnimation: scaleAnimation,
  );
}

/// パーティクルエフェクト用のデータクラス
class ParticleData {
  final double x;
  final double y;
  final double targetX;
  final double targetY;
  final double size;
  final double delay;
  final String emoji;
  final bool isMainParticle;
  final double rotationSpeed;

  ParticleData({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.size,
    required this.delay,
    required this.emoji,
    required this.isMainParticle,
    required this.rotationSpeed,
  });
}

/// パーティクルエフェクトのペインター
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ParticleData> particles;

  ParticleEffectPainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final progress = (animation.value - particle.delay).clamp(0.0, 1.0);

      if (progress <= 0) continue;

      final easedProgress = particle.isMainParticle
          ? Curves.elasticOut.transform(progress)
          : Curves.easeOutCubic.transform(progress);

      final gravity = particle.isMainParticle ? 0.1 : 0.05;
      final x = size.width *
          (particle.x + (particle.targetX - particle.x) * easedProgress);
      final y = size.height *
          (particle.y +
              (particle.targetY - particle.y) * easedProgress +
              gravity * progress * progress);

      final opacity = particle.isMainParticle
          ? (1.0 - progress * 0.7).clamp(0.0, 1.0)
          : (1.0 - progress).clamp(0.0, 1.0);

      final currentSize = particle.size *
          (particle.isMainParticle
              ? 1.0 + progress * 0.3
              : 1.0 + progress * 0.8);

      final rotation = particle.rotationSpeed * progress * 2 * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (particle.isMainParticle && opacity > 0.3) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawCircle(Offset.zero, currentSize / 2, glowPaint);
      }

      final textStyle = TextStyle(
        fontSize: currentSize,
        shadows: particle.isMainParticle
            ? [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ]
            : null,
      );

      final textSpan = TextSpan(text: particle.emoji, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final textOffset = Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      );

      canvas.saveLayer(
        Rect.fromLTWH(
          textOffset.dx,
          textOffset.dy,
          textPainter.width,
          textPainter.height,
        ),
        Paint()..color = Colors.white.withOpacity(opacity),
      );

      textPainter.paint(canvas, textOffset);

      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// パーティクルエフェクトを生成するユーティリティ
class ParticleEffectGenerator {
  static List<ParticleData> generateReactionParticles(String selectedEmoji) {
    final particleList = <ParticleData>[];

    // メインの絵文字パーティクル
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * 2 * math.pi;
      particleList.add(
        ParticleData(
          x: 0.5,
          y: 0.5,
          targetX: 0.5 + math.cos(angle) * 0.3,
          targetY: 0.5 + math.sin(angle) * 0.3,
          size: 24.0,
          delay: i * 0.1,
          emoji: selectedEmoji,
          isMainParticle: true,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 4,
        ),
      );
    }

    // 装飾パーティクル
    for (int i = 0; i < 15; i++) {
      final angle = math.Random().nextDouble() * 2 * math.pi;
      final distance = 0.15 + math.Random().nextDouble() * 0.4;
      particleList.add(
        ParticleData(
          x: 0.5,
          y: 0.5,
          targetX: 0.5 + math.cos(angle) * distance,
          targetY: 0.5 + math.sin(angle) * distance,
          size: 8.0 + math.Random().nextDouble() * 6,
          delay: i * 0.05,
          emoji: ['✨', '💫', '⭐', '🌟'][i % 4],
          isMainParticle: false,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 6,
        ),
      );
    }

    return particleList;
  }
}

/// アニメーション付きタップハンドラー
mixin AnimatedTapHandler {
  void handleTapDown(
    AnimationController scaleController,
    TapDownDetails details,
  ) {
    scaleController.forward();
  }

  void handleTapUp(
    AnimationController scaleController,
    TapUpDetails details,
  ) {
    scaleController.reverse();
  }

  void handleTapCancel(AnimationController scaleController) {
    scaleController.reverse();
  }
}
