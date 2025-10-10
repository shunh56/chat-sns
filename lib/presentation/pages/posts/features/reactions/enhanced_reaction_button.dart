// lib/presentation/pages/posts/components/reactions/enhanced_reaction_button.dart
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/posts/post_reaction.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/pages/posts/features/reactions/reactions/reaction_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;

class EnhancedReactionButton extends HookConsumerWidget {
  final Post post;
  final UserAccount user;
  final Function(String) onReaction;

  const EnhancedReactionButton({
    super.key,
    required this.post,
    required this.user,
    required this.onReaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).currentUser?.uid;
    if (currentUserId == null) return const SizedBox();

    final bounceControllers = <String, AnimationController>{};

    // 各リアクションタイプのアニメーションコントローラーを作成
    for (final reactionType in ReactionType.allTypes) {
      bounceControllers[reactionType] = useAnimationController(
        duration: const Duration(milliseconds: 300),
      );
    }

    void showParticleEffect(String selectedEmoji) {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) =>
            ParticleEffectOverlay(selectedEmoji: selectedEmoji),
      );
    }

    void handleReaction(String reactionType) {
      // より弾力のあるアニメーション
      bounceControllers[reactionType]?.forward().then((_) {
        bounceControllers[reactionType]?.reverse();
      });

      onReaction(reactionType);
      showParticleEffect(_getEmojiForReaction(reactionType));

      ref
          .read(allPostsNotifierProvider.notifier)
          .addReaction(user, post.id, reactionType);
    }

    void showReactionPickerDialog() {
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) => ReactionPicker(
          onReactionSelected: (reaction) {
            Navigator.of(context).pop();
            DebugPrint("reaction $reaction selected");
            handleReaction(reaction);
          },
        ),
      );
    }

    List<String> getDisplayReactions() {
      final displayReactions = <String>[];

      for (final entry in post.reactions.entries) {
        if (entry.value.count > 0) {
          displayReactions.add(entry.key);
        }
      }

      final userReactions = post.getUserReactionTypes(currentUserId);
      for (final reactionType in userReactions) {
        if (!displayReactions.contains(reactionType)) {
          displayReactions.add(reactionType);
        }
      }

      if (displayReactions.isEmpty) {
        displayReactions.add('love');
      }

      return displayReactions;
    }

    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // モダンなリアクションボタン群
          GestureDetector(
            onLongPress: showReactionPickerDialog,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: getDisplayReactions().map((reactionType) {
                final reactionCount = post.getReactionCount(reactionType);
                final hasUserReacted =
                    post.hasUserReacted(currentUserId, reactionType);
                final controller = bounceControllers[reactionType]!;

                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final scale = 1.0 + (controller.value * 0.2);

                    return Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: () => handleReaction(reactionType),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ThemeColor.stroke,
                            /*color: _getReactionColor(reactionType)
                                .withOpacity(0.15),
                           
                            border: Border.all(
                              color: _getReactionColor(reactionType)
                                  .withOpacity(0.3),
                              width: 1.5,
                            ), 
                            boxShadow: [
                              BoxShadow(
                                color: hasUserReacted
                                    ? _getReactionColor(reactionType)
                                        .withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: hasUserReacted ? 8 : 4,
                                offset: const Offset(0, 2),
                                spreadRadius: hasUserReacted ? 1 : 0,
                              ),
                            ],
                            */
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 絵文字にグロー効果
                              Container(
                                /* decoration: hasUserReacted
                                    ? BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                _getReactionColor(reactionType)
                                                    .withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      )
                                    : null, */
                                child: Text(
                                  _getEmojiForReaction(reactionType),
                                  style: TextStyle(
                                    fontSize: hasUserReacted ? 18 : 16,
                                    shadows: hasUserReacted
                                        ? [
                                            Shadow(
                                              color: _getReactionColor(
                                                      reactionType)
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                /*decoration: BoxDecoration(
                                  color: hasUserReacted
                                      ? _getReactionColor(reactionType)
                                          .withOpacity(0.2)
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ), */
                                child: Text(
                                  reactionCount.toString(),
                                  style: TextStyle(
                                    color: hasUserReacted
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          // より洗練されたヒントテキスト
          if (post.replyCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (post.replyCount > 0)
                    Text(
                      '${post.replyCount}件の返信',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getEmojiForReaction(String type) {
    switch (type) {
      case 'love':
        return '❤️';
      case 'fire':
        return '🔥';
      case 'wow':
        return '😍';
      case 'clap':
        return '👏';
      case 'laugh':
        return '😂';
      case 'sad':
        return '😢';
      default:
        return '❤️';
    }
  }

  Color _getReactionColor(String type) {
    switch (type) {
      case 'love':
        return const Color(0xFFE91E63);
      case 'fire':
        return const Color(0xFFFF6F00);
      case 'wow':
        return const Color(0xFFAD1457);
      case 'clap':
        return const Color(0xFFFFC107);
      case 'laugh':
        return const Color(0xFF2196F3);
      case 'sad':
        return const Color(0xFF5C6BC0);
      default:
        return Colors.grey;
    }
  }
}

class ParticleEffectOverlay extends HookConsumerWidget {
  final String selectedEmoji;

  const ParticleEffectOverlay({
    super.key,
    required this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    // ハプティック実行済みフラグを管理
    final hapticExecuted = useRef<Set<int>>({});

    final particles = useMemoized(() {
      final particleList = <FloatingParticleData>[];

      for (int i = 0; i < 8; i++) {
        final startX = 0.2 + (i / 7) * 0.6;
        final endX = startX + (math.Random().nextDouble() - 0.5) * 0.3;

        particleList.add(
          FloatingParticleData(
            id: i, // IDを追加
            startX: startX,
            endX: endX.clamp(0.1, 0.9),
            startY: 1.2,
            endY: -0.2,
            size: 36.0 + math.Random().nextDouble() * 36,
            delay: i * 0.1,
            emoji: selectedEmoji,
            horizontalDrift: (math.Random().nextDouble() - 0.5) * 0.15,
            rotationSpeed: (math.Random().nextDouble() - 0.5) * 2,
          ),
        );
      }

      return particleList;
    }, [selectedEmoji]);

    // アニメーションの監視とハプティック実行
    useEffect(() {
      void animationListener() {
        for (final particle in particles) {
          final particleProgress =
              (controller.value - particle.delay).clamp(0.0, 1.0);

          // パーティクルが開始したタイミング（初回のみ）
          if (particleProgress > 0 &&
              !hapticExecuted.value.contains(particle.id)) {
            hapticExecuted.value.add(particle.id);

            HapticFeedback.lightImpact();
          }
        }
      }

      controller.addListener(animationListener);
      return () => controller.removeListener(animationListener);
    }, [particles]);

    useEffect(() {
      // アニメーション開始時にリセット
      hapticExecuted.value.clear();

      controller.forward().then((_) {
        Navigator.of(context).pop();
      });
      return null;
    }, []);

    return IgnorePointer(
      child: CustomPaint(
        painter: FloatingParticlePainter(
          animation: controller,
          particles: particles,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// パーティクルデータにIDを追加
class FloatingParticleData {
  final int id; // 追加
  final double startX;
  final double endX;
  final double startY;
  final double endY;
  final double size;
  final double delay;
  final String emoji;
  final double horizontalDrift;
  final double rotationSpeed;

  FloatingParticleData({
    required this.id, // 追加
    required this.startX,
    required this.endX,
    required this.startY,
    required this.endY,
    required this.size,
    required this.delay,
    required this.emoji,
    required this.horizontalDrift,
    required this.rotationSpeed,
  });
}

// 上昇アニメーション用のペインター
class FloatingParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<FloatingParticleData> particles;

  FloatingParticlePainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final rawProgress = (animation.value - particle.delay).clamp(0.0, 1.0);
      if (rawProgress <= 0) continue;

      // より自然な上昇カーブ（最初は速く、後半は減速）
      final progress = Curves.easeOutQuart.transform(rawProgress);

      // Y座標の計算（下から上へ）
      final y = size.height *
          (particle.startY + (particle.endY - particle.startY) * progress);

      // X座標の計算（軽い揺らぎ付き）
      final baseX =
          particle.startX + (particle.endX - particle.startX) * progress;
      final driftOffset =
          math.sin(progress * math.pi * 3) * particle.horizontalDrift;
      final x = size.width * (baseX + driftOffset);

      // 透明度の計算（フェードイン→フェードアウト）
      late double opacity;
      if (progress < 0.15) {
        // 最初の15%でフェードイン
        opacity = progress / 0.15;
      } else if (progress > 0.8) {
        // 最後の20%でフェードアウト
        opacity = (1.0 - progress) / 0.2;
      } else {
        // 中間は完全に表示
        opacity = 1.0;
      }
      opacity = opacity.clamp(0.0, 1.0);

      // サイズの変化（最初少し小さく、中間で通常サイズ、最後やや大きく）
      late double scale;
      if (progress < 0.2) {
        scale = 0.7 + (progress / 0.2) * 0.3; // 0.7 → 1.0
      } else if (progress > 0.7) {
        scale = 1.0 + ((progress - 0.7) / 0.3) * 0.2; // 1.0 → 1.2
      } else {
        scale = 1.0;
      }

      final currentSize = particle.size * scale;

      // 回転角度
      final rotation = particle.rotationSpeed * progress * 2 * math.pi;

      // 絵文字を描画
      _drawFloatingEmoji(
        canvas,
        particle.emoji,
        Offset(x, y),
        currentSize,
        opacity,
        rotation,
      );
    }
  }

  void _drawFloatingEmoji(
    Canvas canvas,
    String emoji,
    Offset position,
    double size,
    double opacity,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    final textStyle = TextStyle(
      fontSize: size,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.15 * opacity),
          blurRadius: 2,
          offset: const Offset(0.5, 1),
        ),
        // 軽いグロー効果
        Shadow(
          color: Colors.white.withOpacity(0.1 * opacity),
          blurRadius: 6,
          offset: Offset.zero,
        ),
      ],
    );

    final textSpan = TextSpan(text: emoji, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // 中央揃えで描画
    final offset = Offset(
      -textPainter.width / 2,
      -textPainter.height / 2,
    );

    // 透明度を適用
    canvas.saveLayer(
      Rect.fromLTWH(
        offset.dx,
        offset.dy,
        textPainter.width,
        textPainter.height,
      ),
      Paint()..color = Colors.white.withOpacity(opacity),
    );

    textPainter.paint(canvas, offset);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// シンプル化されたパーティクルデータ
class SimpleParticleData {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final String emoji;

  SimpleParticleData({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.emoji,
  });
}

// シンプルで効果的なパーティクルペインター
class SimpleParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<SimpleParticleData> particles;

  SimpleParticlePainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final particle in particles) {
      final progress = (animation.value - particle.delay).clamp(0.0, 1.0);
      if (progress <= 0) continue;

      // より自然なイージング（弾むような動き）
      final easedProgress = Curves.elasticOut.transform(progress);

      // 位置計算（中心から放射状に）
      final currentDistance =
          particle.distance * easedProgress * size.width * 0.3;
      final x = centerX + math.cos(particle.angle) * currentDistance;
      final y = centerY + math.sin(particle.angle) * currentDistance;

      // フェードアウト効果（最後の30%で透明に）
      final opacity =
          progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);

      // サイズアニメーション（開始時に少し大きく）
      final scale = progress < 0.3
          ? 0.5 + (progress / 0.3) * 0.7 // 0.5 → 1.2
          : 1.2 - (progress - 0.3) / 0.7 * 0.2; // 1.2 → 1.0

      final currentSize = particle.size * scale;

      // 絵文字を描画
      _drawEmoji(
        canvas,
        particle.emoji,
        Offset(x, y),
        currentSize,
        opacity,
      );
    }
  }

  void _drawEmoji(
    Canvas canvas,
    String emoji,
    Offset position,
    double size,
    double opacity,
  ) {
    final textStyle = TextStyle(
      fontSize: size,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.2 * opacity),
          blurRadius: 3,
          offset: const Offset(1, 1),
        ),
      ],
    );

    final textSpan = TextSpan(text: emoji, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // 中央揃えで描画
    final offset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    // 透明度を適用
    canvas.saveLayer(
      Rect.fromLTWH(
        offset.dx,
        offset.dy,
        textPainter.width,
        textPainter.height,
      ),
      Paint()..color = Colors.white.withOpacity(opacity),
    );

    textPainter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 拡張されたパーティクルデータクラス
class EnhancedParticleData {
  final double x;
  final double y;
  final double targetX;
  final double targetY;
  final double size;
  final double delay;
  final String emoji;
  final bool isMainEmoji;
  final double rotationSpeed;

  EnhancedParticleData({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.size,
    required this.delay,
    required this.emoji,
    required this.isMainEmoji,
    required this.rotationSpeed,
  });
}

// より豪華なパーティクルペインター
class EnhancedParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<EnhancedParticleData> particles;

  EnhancedParticlePainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final progress = (animation.value - particle.delay).clamp(0.0, 1.0);

      if (progress <= 0) continue;

      // より複雑なイージング
      final easedProgress = particle.isMainEmoji
          ? Curves.elasticOut.transform(progress)
          : Curves.easeOutCubic.transform(progress);

      // 位置計算（重力効果を追加）
      final gravity = particle.isMainEmoji ? 0.1 : 0.05;
      final x = size.width *
          (particle.x + (particle.targetX - particle.x) * easedProgress);
      final y = size.height *
          (particle.y +
              (particle.targetY - particle.y) * easedProgress +
              gravity * progress * progress);

      // 透明度の変化（メイン絵文字は長く表示）
      final opacity = particle.isMainEmoji
          ? (1.0 - progress * 0.7).clamp(0.0, 1.0)
          : (1.0 - progress).clamp(0.0, 1.0);

      // サイズの変化
      final currentSize = particle.size *
          (particle.isMainEmoji ? 1.0 + progress * 0.3 : 1.0 + progress * 0.8);

      // 回転角度
      final rotation = particle.rotationSpeed * progress * 2 * math.pi;

      // 絵文字の描画
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // グロー効果（メイン絵文字のみ）
      if (particle.isMainEmoji && opacity > 0.3) {
        final glowPaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawCircle(
          Offset.zero,
          currentSize / 2,
          glowPaint,
        );
      }

      // テキストスタイル
      final textStyle = TextStyle(
        fontSize: currentSize,
        shadows: particle.isMainEmoji
            ? [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ]
            : null,
      );

      final textSpan = TextSpan(
        text: particle.emoji,
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // 絵文字の描画（中央揃え）
      final textOffset = Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      );

      // 透明度を適用
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
