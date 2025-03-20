class TagsDB {
  // 可読性の高い英語のキーを持つタグマップ
  Map<String, String> db = {
    // 食事・カフェ関連
    "cafe_hopping": "カフェ巡り",
    "starbucks": "スタバ",
    "bubble_tea": "タピオカ",
    "instagrammable_lunch": "インスタ映えランチ",
    "sandwich": "サンドイッチ",
    "matcha_sweets": "抹茶スイーツ",
    "pudding_parfait": "プリンパフェ",
    "cheese_tea": "チーズティー",
    
    // 娯楽・活動
    "karaoke": "カラオケ",
    "purikura": "プリクラ",
    "arcade": "ゲームセンター",
    "board_games": "ボードゲーム",
    "idol_support": "推し活",
    "live_concert": "ライブ参戦",
    "movie_watching": "映画鑑賞",
    "anime_pilgrimage": "アニメ聖地巡礼",
    
    // ショッピング
    "vintage_shopping": "古着巡り",
    "cosmetics_shopping": "コスメ購入",
    "stationery_collecting": "文房具集め",
    "variety_store": "雑貨屋さん",
    
    // アウトドア・場所
    "picnic": "ピクニック",
    "cherry_blossom": "花見",
    "illumination": "イルミネーション",
    "rooftop_terrace": "屋上テラス",
    "park_walk": "公園散歩",
    
    // イベント・シーズン
    "school_festival": "学園祭",
    "halloween_costume": "ハロウィン仮装",
    "christmas_party": "クリスマスパーティー",
    "birthday_party": "誕生日会",
    "club_camp": "サークル合宿",
    
    // アクティビティ
    "night_pool": "ナイトプール",
    "night_drive": "夜景ドライブ",
    "cycling": "自転車サイクリング",
    "drawing": "お絵描き",
    "homemade_sweets": "手作りお菓子",
    
    // 勉強・大学生活
    "stylish_study_group": "オシャレ勉強会",
    "library_date": "図書館デート",
    "morning_activity": "朝活",
    "night_cafe_work": "夜カフェ作業",
    "note_taking": "ノート術",
  };

  // カテゴリー別にタグを整理
  final Map<String, List<String>> categorizedTags = {
    "food": [
      "cafe_hopping", "starbucks", "bubble_tea", "instagrammable_lunch",
      "sandwich", "matcha_sweets", "pudding_parfait", "cheese_tea"
    ],
    "entertainment": [
      "karaoke", "purikura", "arcade", "board_games",
      "idol_support", "live_concert", "movie_watching", "anime_pilgrimage"
    ],
    "shopping": [
      "vintage_shopping", "cosmetics_shopping", "stationery_collecting", "variety_store"
    ],
    "outdoor": [
      "picnic", "cherry_blossom", "illumination", "rooftop_terrace", "park_walk"
    ],
    "events": [
      "school_festival", "halloween_costume", "christmas_party", "birthday_party", "club_camp"
    ],
    "activity": [
      "night_pool", "night_drive", "cycling", "drawing", "homemade_sweets"
    ],
    "study": [
      "stylish_study_group", "library_date", "morning_activity", "night_cafe_work", "note_taking"
    ]
  };

  // キーからタグ名を取得
  String? getTagName(String tagId) {
    return db[tagId];
  }

  // タグ名からキーを取得
  String? getTagId(String tagName) {
    for (var entry in db.entries) {
      if (entry.value == tagName) {
        return entry.key;
      }
    }
    return null;
  }

  // カテゴリーからタグIDリストを取得
  List<String> getTagIdsByCategory(String category) {
    return categorizedTags[category] ?? [];
  }

  // カテゴリーからタグ名リストを取得
  List<String> getTagNamesByCategory(String category) {
    final tagIds = getTagIdsByCategory(category);
    return tagIds.map((id) => db[id] ?? "").where((name) => name.isNotEmpty).toList();
  }

  // すべてのカテゴリーを取得
  List<String> getAllCategories() {
    return categorizedTags.keys.toList();
  }

  // 特定のタグIDがどのカテゴリーに属するかを取得
  String? getCategoryForTag(String tagId) {
    for (var entry in categorizedTags.entries) {
      if (entry.value.contains(tagId)) {
        return entry.key;
      }
    }
    return null;
  }
  
  // タグを検索（部分一致）
  List<Map<String, String>> searchTags(String query) {
    final results = <Map<String, String>>[];
    
    for (var entry in db.entries) {
      if (entry.key.contains(query) || entry.value.contains(query)) {
        results.add({
          'id': entry.key,
          'name': entry.value,
          'category': getCategoryForTag(entry.key) ?? "unknown"
        });
      }
    }
    
    return results;
  }
  
  // すべてのタグを取得（id, name, category形式）
  List<Map<String, String>> getAllTags() {
    return db.entries.map((entry) {
      return {
        'id': entry.key,
        'name': entry.value,
        'category': getCategoryForTag(entry.key) ?? "unknown"
      };
    }).toList();
  }
  
  // 複数のタグIDからタグ名リストを取得
  List<String> getTagNamesByIds(List<String> tagIds) {
    return tagIds
        .map((id) => db[id])
        .where((name) => name != null)
        .map((name) => name!)
        .toList();
  }
}