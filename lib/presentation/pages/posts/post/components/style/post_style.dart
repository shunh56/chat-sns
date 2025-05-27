// lib/presentation/pages/posts/post/components/styling/post_styling.dart
import 'package:flutter/material.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/posts/post.dart';

/// ユーザーのバイブカラーを管理するクラス
class VibeColorManager {
  // ダークテーマに適した落ち着いたカラーパレット
  static const List<Color> _vibeColors = [
    Color(0xFF6B46C1), // Deep Purple - Creative
    Color(0xFFEA580C), // Warm Orange - Energetic
    Color(0xFF0284C7), // Cool Blue - Chill
    Color(0xFF059669), // Nature Green - Happy
    Color(0xFFDB2777), // Deep Pink - Inspired
    Color(0xFF4F46E5), // Indigo - Focused
    Color(0xFF0D9488), // Teal - Calm
    Color(0xFFD97706), // Amber - Excited
  ];

  /// ユーザーに基づいてバイブカラーを取得
  static Color getVibeColor(UserAccount user) {
    return _vibeColors[user.name.hashCode % _vibeColors.length];
  }

  /// リアクションタイプに基づいてカラーを取得
  static Color getReactionColor(String reactionType) {
    switch (reactionType) {
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

/// バイブテキストを管理するクラス
class VibeTextAnalyzer {
  static const Map<String, List<String>> _vibeKeywords = {
    'Creative': [
      'art', 'design', 'create', 'draw', 'paint', 'music', 'write', 'photo',
      'アート', '作品', '創作', '描い', '作っ', '音楽', '写真', 'デザイン'
    ],
    'Energetic': [
      'workout', 'run', 'energy', 'power', 'strong', 'active', 'sport',
      '筋トレ', '運動', 'ワークアウト', '走っ', 'スポーツ', '元気', 'パワー'
    ],
    'Happy': [
      'happy', 'joy', 'smile', 'laugh', 'fun', 'good', 'great', 'awesome',
      '嬉しい', '楽しい', '幸せ', '最高', 'ハッピー', '笑', '喜び'
    ],
    'Chill': [
      'relax', 'calm', 'peaceful', 'quiet', 'rest', 'coffee', 'tea', 'sunset',
      'リラックス', 'のんびり', '落ち着', '静か', '休憩', 'コーヒー', '夕日'
    ],
    'Inspired': [
      'inspire', 'motivate', 'dream', 'goal', 'achieve', 'success', 'future',
      'インスピレーション', '夢', '目標', '達成', '成功', '未来', 'やる気'
    ],
    'Focused': [
      'work', 'study', 'focus', 'concentrate', 'learn', 'code', 'project',
      '仕事', '勉強', '集中', '学習', 'プロジェクト', 'コード', '作業'
    ],
    'Excited': [
      'excited', 'amazing', 'wow', 'incredible', 'fantastic', 'love',
      'わくわく', 'すごい', '興奮', '素晴らしい', '大好き', '最高'
    ],
  };

  /// 投稿内容からバイブテキストを分析
  static String analyzePostVibe(UserAccount user, Post post) {
    final content = '${post.title} ${post.text ?? ''}'.toLowerCase();

    // ハッシュタグからの判定
    for (final hashtag in post.hashtags) {
      final tag = hashtag.toLowerCase();
      for (final entry in _vibeKeywords.entries) {
        if (entry.value.any((keyword) => tag.contains(keyword))) {
          return entry.key;
        }
      }
    }

    // 投稿内容からの判定
    for (final entry in _vibeKeywords.entries) {
      if (entry.value.any((keyword) => content.contains(keyword))) {
        return entry.key;
      }
    }

    // 投稿時間から推測
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

  /// デフォルトのバイブテキストを取得
  static String getDefaultVibeText(UserAccount user) {
    const defaultVibes = [
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
}

/// 投稿カードのスタイリングを管理するクラス
class PostCardStyling {
  /// 投稿カードの基本装飾を取得
  static BoxDecoration getCardDecoration(Color vibeColor) {
    return BoxDecoration(
      color: const Color(0xFF1A1A1A), // ThemeColor.background
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: vibeColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: vibeColor.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// ユーザーアイコンの装飾を取得
  static BoxDecoration getUserIconDecoration(Color vibeColor) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          vibeColor,
          vibeColor.withOpacity(0.7),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: vibeColor.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    );
  }

  /// リアクションボタンの装飾を取得
  static BoxDecoration getReactionButtonDecoration(
    Color reactionColor,
    bool hasUserReacted,
  ) {
    return BoxDecoration(
      color: reactionColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: reactionColor.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: hasUserReacted
              ? reactionColor.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          blurRadius: hasUserReacted ? 8 : 4,
          offset: const Offset(0, 2),
          spreadRadius: hasUserReacted ? 1 : 0,
        ),
      ],
    );
  }
}

/// エモジとアイコンを管理するクラス
class PostEmojiManager {
  /// リアクションタイプに対応する絵文字を取得
  static String getReactionEmoji(String reactionType) {
    switch (reactionType) {
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

  /// バイブタイプに対応するアイコンと絵文字を取得
  static Map<String, String> getVibeIconAndEmoji(String vibeType) {
    switch (vibeType.toLowerCase()) {
      case 'happy':
        return {'icon': '😊', 'text': 'Happy'};
      case 'creative':
        return {'icon': '✨', 'text': 'Creative'};
      case 'energetic':
        return {'icon': '🔥', 'text': 'Energetic'};
      case 'chill':
        return {'icon': '🌙', 'text': 'Chill'};
      case 'inspired':
        return {'icon': '💫', 'text': 'Inspired'};
      case 'focused':
        return {'icon': '🎯', 'text': 'Focused'};
      case 'calm':
        return {'icon': '🧘', 'text': 'Calm'};
      case 'excited':
        return {'icon': '🚀', 'text': 'Excited'};
      default:
        return {'icon': '💫', 'text': 'Inspired'};
    }
  }

  /// 装飾用の小さなパーティクル絵文字リスト
  static const List<String> decorativeEmojis = ['✨', '💫', '⭐', '🌟'];
}

/// フィルター名を管理するクラス
class MediaFilterManager {
  static String getFilterName(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return 'Warm';
      case 2:
        return 'Cool';
      case 3:
        return 'Ocean';
      default:
        return 'Original';
    }
  }

  static List<ColorFilter> getFilters() {
    return [
      const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      ColorFilter.mode(Colors.orange.withOpacity(0.3), BlendMode.multiply),
      ColorFilter.mode(Colors.purple.withOpacity(0.3), BlendMode.multiply),
      ColorFilter.mode(Colors.blue.withOpacity(0.3), BlendMode.multiply),
    ];
  }
}

/// テキストスタイルのユーティリティ
class PostTextStyles {
  static TextStyle getHeaderText({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.white,
    );
  }

  static TextStyle getContentText({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.white,
      height: height,
    );
  }

  static TextStyle getTimestampText({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.white.withOpacity(0.7),
    );
  }

  static TextStyle getReactionText({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}