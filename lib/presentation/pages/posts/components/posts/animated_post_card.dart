// lib/presentation/components/posts/animated_post_card.dart
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/posts/components/media/interactive_media_viewer.dart';
import 'package:app/presentation/pages/posts/components/reactions/enhanced_reaction_button.dart';
import 'package:app/presentation/pages/posts/components/vibe/vibe_indicator.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui';

final postVisibilityProvider =
    StateProvider.family<bool, String>((ref, postId) => false);

class AnimatedPostCard extends HookConsumerWidget {
  final Post post;
  final UserAccount user;
  final int index;

  const AnimatedPostCard({
    super.key,
    required this.post,
    required this.user,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slideController = useAnimationController(
      duration: Duration(milliseconds: 600 + index * 100),
    );

    final fadeController = useAnimationController(
      duration: Duration(milliseconds: 800 + index * 50),
    );

    final scaleController = useAnimationController(
      duration: const Duration(milliseconds: 200),
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
      Future.delayed(Duration(milliseconds: index * 100), () {
        slideController.forward();
        fadeController.forward();
        ref.read(postVisibilityProvider(post.id).notifier).state = true;
      });
      return null;
    }, []);

    return AnimatedBuilder(
      animation:
          Listenable.merge([slideAnimation, fadeAnimation, scaleAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: GestureDetector(
                onTap: () => ref
                    .read(navigationRouterProvider(context))
                    .goToPost(post, user),
                onTapDown: (_) => scaleController.forward(),
                onTapUp: (_) => scaleController.reverse(),
                onTapCancel: () => scaleController.reverse(),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.background,
                    /*gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getVibeColor(user).withOpacity(0.1),
                        Colors.transparent,
                        _getVibeColor(user).withOpacity(0.05),
                      ],
                    ), */
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getVibeColor(user).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getVibeColor(user).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(user, post),
                            _buildContent(post),
                            _buildMedia(post),
                            _buildActionBar(post),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserAccount user, Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getVibeColor(user),
                  _getVibeColor(user).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getVibeColor(user).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: CachedImage.userIcon(user.imageUrl, user.name, 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                post.createdAt.xxAgo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (false)
            VibeIndicator(
              mood: _getVibeText(user, post), // postも渡す
              color: _getVibeColor(user), // 色も渡す
            ),
        ],
      ),
    );
  }

  Widget _buildContent(Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          if (post.text != null) ...[
            const SizedBox(height: 6),
            Text(
              post.text!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia(Post post) {
    if (post.mediaUrls.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InteractiveMediaViewer(
        mediaUrls: post.mediaUrls,
        aspectRatios: post.aspectRatios,
        onDoubleTap: (offset) {
          // Handle double tap reaction
        },
      ),
    );
  }

  Widget _buildActionBar(Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: EnhancedReactionButton(
        user: user,
        post: post,
        onReaction: (reaction) {},
      ),
    );
  }

  // lib/presentation/components/posts/animated_post_card.dart の修正部分

  Color _getVibeColor(UserAccount user) {
    // ダークテーマに適した落ち着いたカラーパレット
    final darkColors = [
      // Deep Purple - Creative
      const Color(0xFF6B46C1), // Purple 600
      // Warm Orange - Energetic
      const Color(0xFFEA580C), // Orange 600
      // Cool Blue - Chill
      const Color(0xFF0284C7), // Sky 600
      // Nature Green - Happy
      const Color(0xFF059669), // Emerald 600
      // Deep Pink - Inspired
      const Color(0xFFDB2777), // Pink 600
      // Indigo - Focused
      const Color(0xFF4F46E5), // Indigo 600
      // Teal - Calm
      const Color(0xFF0D9488), // Teal 600
      // Amber - Excited
      const Color(0xFFD97706), // Amber 600
    ];

    return darkColors[user.name.hashCode % darkColors.length];
  }

  String _getVibeText(UserAccount user, Post post) {
    // 投稿内容から気分を推測する
    final vibeText = _analyzePostVibe(post);
    if (vibeText != null) {
      return vibeText;
    }

    // フォールバック：ユーザーベースのデフォルト気分
    final defaultVibes = [
      'Creative',
      'Energetic',
      'Chill',
      'Happy',
      'Inspired',
      'Focused',
      'Calm',
      'Excited',
    ];

    return defaultVibes[user.name.hashCode % defaultVibes.length];
  }

  String? _analyzePostVibe(Post post) {
    final content = '${post.title} ${post.text ?? ''}'.toLowerCase();

    // 感情キーワードマッピング
    final vibeKeywords = {
      'Creative': [
        'art',
        'design',
        'create',
        'draw',
        'paint',
        'music',
        'write',
        'photo',
        'アート',
        '作品',
        '創作',
        '描い',
        '作っ',
        '音楽',
        '写真',
        'デザイン'
      ],
      'Energetic': [
        'workout',
        'run',
        'energy',
        'power',
        'strong',
        'active',
        'sport',
        '筋トレ',
        '運動',
        'ワークアウト',
        '走っ',
        'スポーツ',
        '元気',
        'パワー'
      ],
      'Happy': [
        'happy',
        'joy',
        'smile',
        'laugh',
        'fun',
        'good',
        'great',
        'awesome',
        '嬉しい',
        '楽しい',
        '幸せ',
        '最高',
        'ハッピー',
        '笑',
        '喜び'
      ],
      'Chill': [
        'relax',
        'calm',
        'peaceful',
        'quiet',
        'rest',
        'coffee',
        'tea',
        'sunset',
        'リラックス',
        'のんびり',
        '落ち着',
        '静か',
        '休憩',
        'コーヒー',
        '夕日'
      ],
      'Inspired': [
        'inspire',
        'motivate',
        'dream',
        'goal',
        'achieve',
        'success',
        'future',
        'インスピレーション',
        '夢',
        '目標',
        '達成',
        '成功',
        '未来',
        'やる気'
      ],
      'Focused': [
        'work',
        'study',
        'focus',
        'concentrate',
        'learn',
        'code',
        'project',
        '仕事',
        '勉強',
        '集中',
        '学習',
        'プロジェクト',
        'コード',
        '作業'
      ],
      'Excited': [
        'excited',
        'amazing',
        'wow',
        'incredible',
        'fantastic',
        'love',
        'わくわく',
        'すごい',
        '興奮',
        '素晴らしい',
        '大好き',
        '最高'
      ],
    };

    // ハッシュタグからの判定
    for (final hashtag in post.hashtags) {
      final tag = hashtag.toLowerCase();
      for (final entry in vibeKeywords.entries) {
        if (entry.value.any((keyword) => tag.contains(keyword))) {
          return entry.key;
        }
      }
    }

    // 投稿内容からの判定
    for (final entry in vibeKeywords.entries) {
      if (entry.value.any((keyword) => content.contains(keyword))) {
        return entry.key;
      }
    }

    // 投稿時間から推測（朝=Energetic, 夜=Chill など）
    final hour = post.createdAt.toDate().hour;
    if (hour >= 6 && hour < 10) {
      return 'Energetic'; // 朝
    } else if (hour >= 10 && hour < 14) {
      return 'Focused'; // 午前中
    } else if (hour >= 14 && hour < 18) {
      return 'Happy'; // 午後
    } else if (hour >= 18 && hour < 22) {
      return 'Chill'; // 夕方
    } else {
      return 'Calm'; // 夜・深夜
    }
  }
}
