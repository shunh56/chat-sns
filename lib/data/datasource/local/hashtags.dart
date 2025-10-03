// タグデータをジャンル別に定義
const List<Map<String, String>> hashTags = [
  // エンターテイメント
  {"id": "music", "text": "音楽"},
  {"id": "karaoke", "text": "カラオケ"},
  {"id": "movie", "text": "映画"},
  {"id": "theater", "text": "劇場"},
  {"id": "vacation", "text": "旅行"},
  {"id": "commedy", "text": "お笑い"},

  //音楽
  {"id": "kpop", "text": "K-pop"},
  {"id": "jpop", "text": "J-pop"},
  {"id": "abroad-music", "text": "洋楽"},
  {"id": "edm", "text": "EDM"},
  {"id": "band", "text": "バンド"},
  {"id": "dj", "text": "DJ"},

  // アート・文化
  {"id": "art", "text": "アート"},
  {"id": "museum", "text": "美術館"},
  {"id": "photography", "text": "写真"},
  {"id": "writing", "text": "ライティング"},
  {"id": "history", "text": "歴史"},

  //所属
  {"id": "high-school-student", "text": "高校生"},
  {"id": "jk", "text": "JK"},
  {"id": "fjk", "text": "FJK"},
  {"id": "sjk", "text": "SJK"},
  {"id": "ljk", "text": "LJK"},
  {"id": "university-student", "text": "大学生"},
  {"id": "adult", "text": "社会人"},
  {"id": "talent", "text": "タレント"},
  {"id": "comendian", "text": "芸人"},
  {"id": "youtuber", "text": "YouTuber"},

  // アニメ・漫画
  {"id": "anime", "text": "アニメ"},
  {"id": "manga", "text": "マンガ"},
  {"id": "comics", "text": "コミック"},

  // 読書・ゲーム
  {"id": "reading", "text": "読書"},
  {"id": "gaming", "text": "ゲーム"},
  {"id": "board_games", "text": "ボドゲ"},
  {"id": "puzzles", "text": "パズル"},

  // アウトドア活動
  {"id": "travel", "text": "旅行"},
  {"id": "hiking", "text": "ハイキング"},
  {"id": "camping", "text": "キャンプ"},
  {"id": "fishing", "text": "釣り"},
  {"id": "gardening", "text": "ガーデニング"},
  {"id": "snowboarding", "text": "スノボ"},

  // スポーツ・フィットネス
  {"id": "skateboarding", "text": "スケボ"},
  {"id": "dancing", "text": "ダンス"},
  {"id": "yoga", "text": "ヨガ"},
  {"id": "cycling", "text": "サイクリング"},
  {"id": "running", "text": "ランニング"},
  {"id": "swimming", "text": "水泳"},
  {"id": "surfing", "text": "サーフィン"},

  // 食べ物・飲み物
  {"id": "food", "text": "料理"},
  {"id": "cafe", "text": "カフェ巡り"},
  {"id": "izakaya", "text": "居酒屋"},
  {"id": "coffee", "text": "コーヒー"},
  {"id": "ramen", "text": "ラーメン"},
  {"id": "yakiniku", "text": "焼肉"},
  {"id": "tea", "text": "お茶"},
  {"id": "beer", "text": "ビール"},
  {"id": "wine", "text": "ワイン"},

  // ファッション・クラフト
  {"id": "fashion", "text": "ファッション"},
  {"id": "crafting", "text": "クラフト"},

  // テクノロジー
  {"id": "tech", "text": "テクノロジー"},
  {"id": "coding", "text": "プログラミング"},
  {"id": "science", "text": "科学"},

  // ペット・動物
  {"id": "pets", "text": "ペット"},
  {"id": "dogs", "text": "犬"},
  {"id": "cats", "text": "猫"},

  // ソーシャル・その他
  {"id": "music_festival", "text": "音楽フェス"},
  {"id": "nightclub", "text": "クラブ"},
  {"id": "volunteering", "text": "ボランティア"},
  {"id": "meditation", "text": "瞑想"},
  {"id": "astrology", "text": "占星術"},

  // ソーシャルメディア・プラットフォーム
  {"id": "netflix", "text": "Netflix"},
  {"id": "youtube", "text": "YouTube"},
  {"id": "tiktok", "text": "TikTok"},
  {"id": "twitch", "text": "Twitch"},
  {"id": "spotify", "text": "Spotify"},
  {"id": "soundcloud", "text": "SoundCloud"},
];

// カテゴリのリストと名前のマッピング
final List<String> hashtagCategoryList = [
  'entertainment',
  'music',
  'art_culture',
  'belonging',
  'anime_manga',
  'reading_gaming',
  'outdoor',
  'sports_fitness',
  'food_drink',
  'fashion_craft',
  'technology',
  'pets',
  'social_others',
  'social_media',
];

final Map<String, String> hashtagCategoryMap = {
  'entertainment': 'エンターテイメント',
  'music': '音楽',
  'art_culture': 'アート・文化',
  'belonging': '所属',
  'anime_manga': 'アニメ・漫画',
  'reading_gaming': '読書・ゲーム',
  'outdoor': 'アウトドア活動',
  'sports_fitness': 'スポーツ・フィットネス',
  'food_drink': '食べ物・飲み物',
  'fashion_craft': 'ファッション・クラフト',
  'technology': 'テクノロジー',
  'pets': 'ペット・動物',
  'social_others': 'ソーシャル・その他',
  'social_media': 'ソーシャルメディア',
};

// textからidを取得する関数
String? getIdFromText(String text) {
  final tag = hashTags.firstWhere(
    (tag) => tag['text'] == text,
    orElse: () => {},
  );
  return tag['id'];
}

// idからtextを取得する関数
String? getTextFromId(String id) {
  final tag = hashTags.firstWhere(
    (tag) => tag['id'] == id,
    orElse: () => {},
  );
  return tag['text'] ?? "";
}

// ジャンル別にタグを取得する関数
List<Map<String, String>> getTagsByGenre(String genre) {
  // 更新されたインデックスマッピング
  Map<String, List<int>> genreIndices = {
    'entertainment': List<int>.generate(6, (i) => i), // 0-5
    'music': List<int>.generate(6, (i) => i + 6), // 6-11
    'art_culture': List<int>.generate(5, (i) => i + 12), // 12-16
    'belonging': List<int>.generate(10, (i) => i + 17), // 17-26
    'anime_manga': List<int>.generate(3, (i) => i + 27), // 27-29
    'reading_gaming': List<int>.generate(4, (i) => i + 30), // 30-33
    'outdoor': List<int>.generate(6, (i) => i + 34), // 34-39
    'sports_fitness': List<int>.generate(7, (i) => i + 40), // 40-46
    'food_drink': List<int>.generate(9, (i) => i + 47), // 47-55
    'fashion_craft': List<int>.generate(2, (i) => i + 56), // 56-57
    'technology': List<int>.generate(3, (i) => i + 58), // 58-60
    'pets': List<int>.generate(3, (i) => i + 61), // 61-63
    'social_others': List<int>.generate(5, (i) => i + 64), // 64-68
    'social_media': List<int>.generate(6, (i) => i + 69), // 69-74
  };

  if (!genreIndices.containsKey(genre)) {
    return [];
  }

  return genreIndices[genre]!
      .map((index) {
        if (index < hashTags.length) {
          return hashTags[index];
        }
        return <String, String>{};
      })
      .where((element) => element.isNotEmpty)
      .toList();
}

/*

// タグIDからカードスタイルを決定するヘルパー関数
CardStyle getCardStyleForTag(String tagId) {
  // 音楽・エンタメ系
  if ([
    'music',
    'karaoke',
    'kpop',
    'jpop',
    'abroad-music',
    'edm',
    'band',
    'dj',
    'music_festival',
    'netflix',
    'spotify',
    'soundcloud',
    'youtube',
    'tiktok',
    'twitch'
  ].contains(tagId)) {
    return CardStyle.neon;
  }
  // アウトドア・スポーツ系
  else if ([
    'travel',
    'hiking',
    'camping',
    'fishing',
    'gardening',
    'snowboarding',
    'sports',
    'skateboarding',
    'cycling',
    'running',
    'swimming',
    'surfing',
    'yoga',
    'dancing'
  ].contains(tagId)) {
    return CardStyle.nature;
  }
  // テクノロジー系
  else if (['tech', 'coding', 'science', 'gaming'].contains(tagId)) {
    return CardStyle.tech;
  }
  // アート・文化系
  else if ([
    'art',
    'museum',
    'photography',
    'writing',
    'history',
    'anime',
    'manga',
    'comics',
    'reading'
  ].contains(tagId)) {
    return CardStyle.art;
  }
  // 食べ物・飲み物系
  else if ([
    'food',
    'cafe',
    'izakaya',
    'coffee',
    'ramen',
    'yakiniku',
    'tea',
    'beer',
    'wine'
  ].contains(tagId)) {
    return CardStyle.food;
  }
  // それ以外
  else {
    return CardStyle.minimal;
  }
}



// カードスタイル列挙型
enum CardStyle {
  minimal,
  neon,
  nature,
  tech,
  art,
  food,
}

// ハッシュタグを色付けするための拡張機能
extension HashtagColors on String {
  Color get hashtagColor {
    // カードスタイルに基づいて色を返す
    final style = getCardStyleForTag(this);
    
    switch (style) {
      case CardStyle.neon:
        return Colors.purple;
      case CardStyle.nature:
        return Color(0xFF4CAF50);
      case CardStyle.tech:
        return Color(0xFF00BCD4);
      case CardStyle.art:
        return Colors.amber;
      case CardStyle.food:
        return Colors.deepOrange;
      case CardStyle.minimal:
      default:
        return Colors.blueGrey;
    }
  }
  
  // ハッシュタグの背景色を取得
  Color get hashtagBackgroundColor {
    return hashtagColor.withOpacity(0.2);
  }
  
  // ハッシュタグのアイコンを取得
  IconData get hashtagIcon {
    final style = getCardStyleForTag(this);
    
    switch (style) {
      case CardStyle.neon:
        return Icons.headset;
      case CardStyle.nature:
        return Icons.landscape;
      case CardStyle.tech:
        return Icons.code;
      case CardStyle.art:
        return Icons.palette;
      case CardStyle.food:
        return Icons.restaurant;
      case CardStyle.minimal:
      default:
        return Icons.tag;
    }
  }
}

// 回路基板パターンのカスタムペインター
class CircuitPatterPainter extends CustomPainter {
  final Color lineColor;

  CircuitPatterPainter({
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    final width = size.width;
    final height = size.height;

    // 水平線
    for (var y = spacing; y < height; y += spacing * 2) {
      // ランダムな長さの線を描画
      var startX = 0.0;
      while (startX < width) {
        final lineLength = (spacing * (1 + (y % 3))).clamp(spacing, spacing * 3);
        final endX = (startX + lineLength).clamp(0.0, width);
        
        canvas.drawLine(
          Offset(startX, y),
          Offset(endX, y),
          paint,
        );
        
        // 端点に小さな円を描画
        canvas.drawCircle(
          Offset(startX, y),
          1.5,
          dotPaint,
        );
        
        canvas.drawCircle(
          Offset(endX, y),
          1.5,
          dotPaint,
        );
        
        // 次の線の開始位置
        startX = endX + spacing * (1 + (y % 3));
      }
    }

    // 垂直線と接続線
    for (var x = spacing; x < width; x += spacing * 2) {
      // メインの垂直線
      final lineHeight = spacing * (2 + (x % 3));
      final startY = (height - lineHeight).clamp(0.0, height);
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, height),
        paint,
      );
      
      canvas.drawCircle(
        Offset(x, startY),
        1.5,
        dotPaint,
      );
      
      // 水平線との接続
      for (var y = spacing; y < height; y += spacing * 2) {
        if (x < width - spacing && Random().nextBool()) {
          // L字形の接続
          final pathL = Path()
            ..moveTo(x, y)
            ..lineTo(x + spacing / 2, y)
            ..lineTo(x + spacing / 2, y + spacing / 2);
          
          canvas.drawPath(pathL, paint);
          canvas.drawCircle(
            Offset(x + spacing / 2, y + spacing / 2),
            1.0,
            dotPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 食べ物パターン用のカスタムペインター
class FoodPatternPainter extends CustomPainter {
  final Color lineColor;
  
  FoodPatternPainter({
    required this.lineColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    
    // スパイラルパターン（皿や料理を連想）
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 3 : size.height / 3;
    final spiral = Path();
    
    // スパイラルの描画
    for (var i = 0.0; i < 4 * pi; i += 0.1) {
      final r = radius * (1 - i / (4 * pi)) * 0.8;
      final x = center.dx + r * cos(i);
      final y = center.dy + r * sin(i);
      
      if (i == 0) {
        spiral.moveTo(x, y);
      } else {
        spiral.lineTo(x, y);
      }
    }
    
    canvas.drawPath(spiral, paint);
    
    // 小さな円（食材や装飾）
    final random = Random(42); // 固定シード値
    for (var i = 0; i < 12; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius * 0.9;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      final dotSize = random.nextDouble() * 3 + 1;
      
      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        dotPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// アートパターン用のカスタムペインター
class ArtPatternPainter extends CustomPainter {
  final Color lineColor;
  
  ArtPatternPainter({
    required this.lineColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    
    // 抽象的な曲線パターン
    final random = Random(123); // 固定シード
    final path = Path();
    
    // 開始点
    var x = size.width * 0.2;
    var y = size.height * 0.5;
    path.moveTo(x, y);
    
    // 波線の描画
    for (var i = 0; i < 5; i++) {
      final cp1x = x + size.width * 0.1 * random.nextDouble();
      final cp1y = random.nextBool() 
          ? y - size.height * 0.2 * random.nextDouble()
          : y + size.height * 0.2 * random.nextDouble();
      
      final cp2x = x + size.width * 0.2 * (1 + random.nextDouble() * 0.5);
      final cp2y = random.nextBool()
          ? y - size.height * 0.3 * random.nextDouble() 
          : y + size.height * 0.3 * random.nextDouble();
      
      x = x + size.width * 0.15;
      y = random.nextBool()
          ? y - size.height * 0.1 * random.nextDouble()
          : y + size.height * 0.1 * random.nextDouble();
      
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, x, y);
    }
    
    canvas.drawPath(path, paint);
    
    // 装飾的な円
    for (var i = 0; i < 7; i++) {
      final circleX = random.nextDouble() * size.width;
      final circleY = random.nextDouble() * size.height;
      final radius = size.width * 0.03 * random.nextDouble();
      
      canvas.drawCircle(
        Offset(circleX, circleY),
        radius,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

 */
