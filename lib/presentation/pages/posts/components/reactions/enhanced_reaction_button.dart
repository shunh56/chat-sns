// lib/presentation/pages/posts/components/reactions/enhanced_reaction_button.dart
import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/posts/post_reaction.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/posts/components/reactions/reaction_picker.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            color: _getReactionColor(reactionType)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
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
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 絵文字にグロー効果
                              Container(
                                decoration: hasUserReacted
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
                                    : null,
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

                              if (reactionCount > 0) const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: hasUserReacted
                                      ? _getReactionColor(reactionType)
                                          .withOpacity(0.2)
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  reactionCount.toString(),
                                  style: TextStyle(
                                    color: hasUserReacted
                                        ? _getReactionColor(reactionType)
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
          if (getDisplayReactions().length == 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '長押しで他のリアクション',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
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
      duration: const Duration(milliseconds: 1200),
    );

    // より多様なパーティクル（選択された絵文字と装飾）
    final particles = useMemoized(() {
      final particleList = <EnhancedParticleData>[];

      // メイン絵文字パーティクル（大きめ）
      for (int i = 0; i < 5; i++) {
        final angle = (i / 5) * 2 * math.pi;
        particleList.add(
          EnhancedParticleData(
            x: 0.5,
            y: 0.5,
            targetX: 0.5 + math.cos(angle) * 0.3,
            targetY: 0.5 + math.sin(angle) * 0.3,
            size: 24.0,
            delay: i * 0.1,
            emoji: selectedEmoji,
            isMainEmoji: true,
            rotationSpeed: (math.Random().nextDouble() - 0.5) * 4,
          ),
        );
      }

      // 装飾パーティクル（小さめのスパークル）
      for (int i = 0; i < 15; i++) {
        final angle = math.Random().nextDouble() * 2 * math.pi;
        final distance = 0.15 + math.Random().nextDouble() * 0.4;
        particleList.add(
          EnhancedParticleData(
            x: 0.5,
            y: 0.5,
            targetX: 0.5 + math.cos(angle) * distance,
            targetY: 0.5 + math.sin(angle) * distance,
            size: 8.0 + math.Random().nextDouble() * 6,
            delay: i * 0.05,
            emoji: ['✨', '💫', '⭐', '🌟'][i % 4],
            isMainEmoji: false,
            rotationSpeed: (math.Random().nextDouble() - 0.5) * 6,
          ),
        );
      }

      return particleList;
    }, [selectedEmoji]);

    useEffect(() {
      controller.forward().then((_) {
        Navigator.of(context).pop();
      });
      return null;
    }, []);

    return Container(
      color: Colors.transparent,
      child: CustomPaint(
        painter: EnhancedParticlePainter(
          animation: controller,
          particles: particles,
        ),
        size: Size.infinite,
      ),
    );
  }
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
