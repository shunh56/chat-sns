import 'package:cloud_firestore/cloud_firestore.dart';

class TempoStatus {
  // ユーザー入力データ
  final String status; // 20字以内の自由入力
  final String mood; // 気分絵文字

  // 自動取得データ
  final String userId; // ユーザーID
  final TempoLocation location; // 位置情報
  final TempoWeather? weather; // 天気情報（オプション）

  // システム管理データ
  final bool isActive; // ステータス有効フラグ
  final Timestamp createdAt; // 作成日時
  final Timestamp updatedAt; // 更新日時
  final Timestamp expiresAt; // 24時間後の自動期限
  final String version; // データ構造バージョン

  const TempoStatus({
    required this.status,
    required this.mood,
    required this.userId,
    required this.location,
    this.weather,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.version,
  });

  factory TempoStatus.fromJson(Map<String, dynamic> json) {
    return TempoStatus(
      status: json['status'] ?? '',
      mood: json['mood'] ?? '😊',
      userId: json['userId'] ?? '',
      location: TempoLocation.fromJson(json['location'] ?? {}),
      weather: json['weather'] != null
          ? TempoWeather.fromJson(json['weather'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
      expiresAt: json['expiresAt'] ??
          Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 24)),
          ),
      version: json['version'] ?? '1.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mood': mood,
      'userId': userId,
      'location': location.toJson(),
      if (weather != null) 'weather': weather!.toJson(),
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
      'version': version,
    };
  }

  factory TempoStatus.create({
    required String status,
    required String mood,
    required String userId,
    required TempoLocation location,
    TempoWeather? weather,
  }) {
    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(hours: 24)),
    );

    return TempoStatus(
      status: status,
      mood: mood,
      userId: userId,
      location: location,
      weather: weather,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      expiresAt: expiresAt,
      version: '1.0',
    );
  }

  TempoStatus copyWith({
    String? status,
    String? mood,
    String? userId,
    TempoLocation? location,
    TempoWeather? weather,
    bool? isActive,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? expiresAt,
    String? version,
  }) {
    return TempoStatus(
      status: status ?? this.status,
      mood: mood ?? this.mood,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      version: version ?? this.version,
    );
  }

  // ステータスが有効かどうか
  bool get isExpired => DateTime.now().isAfter(expiresAt.toDate());

  // ステータスが表示可能かどうか
  bool get isVisible => isActive && !isExpired;

  // 作成からの経過時間（分）
  int get minutesSinceCreated =>
      DateTime.now().difference(createdAt.toDate()).inMinutes;

  // 更新からの経過時間（分）
  int get minutesSinceUpdated =>
      DateTime.now().difference(updatedAt.toDate()).inMinutes;

  // 残り時間（時間）
  int get hoursUntilExpiry {
    final now = DateTime.now();
    final expiry = expiresAt.toDate();
    return expiry.difference(now).inHours;
  }
}

class TempoLocation {
  final double latitude; // 緯度
  final double longitude; // 経度
  final String geohash; // 位置情報ハッシュ
  final String prefecture; // 都道府県
  final String city; // 市区町村

  const TempoLocation({
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.prefecture,
    required this.city,
  });

  factory TempoLocation.fromJson(Map<String, dynamic> json) {
    return TempoLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      geohash: json['geohash'] ?? '',
      prefecture: json['prefecture'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'prefecture': prefecture,
      'city': city,
    };
  }

  // 表示用の場所名
  String get displayName {
    if (city.isNotEmpty && prefecture.isNotEmpty) {
      return '$prefecture $city';
    } else if (prefecture.isNotEmpty) {
      return prefecture;
    } else {
      return '場所不明';
    }
  }

  // 短縮版の場所名
  String get shortDisplayName => city.isNotEmpty ? city : prefecture;
}

class TempoWeather {
  final String condition; // "sunny", "cloudy", "rainy", "snowy"
  final double temperature; // 気温（摂氏）
  final String description; // 天気の説明
  final String icon; // 天気アイコンID
  final Timestamp fetchedAt; // 天気情報取得時刻

  const TempoWeather({
    required this.condition,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.fetchedAt,
  });

  factory TempoWeather.fromJson(Map<String, dynamic> json) {
    return TempoWeather(
      condition: json['condition'] ?? 'unknown',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      fetchedAt: json['fetchedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'fetchedAt': fetchedAt,
    };
  }

  // 天気アイコン絵文字
  String get emoji {
    switch (condition) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      default:
        return '🌤️';
    }
  }

  // 温度表示
  String get temperatureDisplay => '${temperature.round()}°C';
}

class TempoInteraction {
  final String viewerId; // 見た人のユーザーID
  final String viewerName; // 見た人の名前
  final String? viewerAvatarUrl; // 見た人のアバター画像URL
  final String statusOwnerId; // ステータス投稿者のID
  final String interactionType; // "view", "interest", "react"
  final Timestamp timestamp; // インタラクション時刻
  final String? reactionEmoji; // リアクション絵文字

  const TempoInteraction({
    required this.viewerId,
    required this.viewerName,
    this.viewerAvatarUrl,
    required this.statusOwnerId,
    required this.interactionType,
    required this.timestamp,
    this.reactionEmoji,
  });

  factory TempoInteraction.fromJson(Map<String, dynamic> json) {
    return TempoInteraction(
      viewerId: json['viewerId'] ?? '',
      viewerName: json['viewerName'] ?? '',
      viewerAvatarUrl: json['viewerAvatarUrl'],
      statusOwnerId: json['statusOwnerId'] ?? '',
      interactionType: json['interactionType'] ?? 'view',
      timestamp: json['timestamp'] ?? Timestamp.now(),
      reactionEmoji: json['reactionEmoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewerId': viewerId,
      'viewerName': viewerName,
      if (viewerAvatarUrl != null) 'viewerAvatarUrl': viewerAvatarUrl,
      'statusOwnerId': statusOwnerId,
      'interactionType': interactionType,
      'timestamp': timestamp,
      if (reactionEmoji != null) 'reactionEmoji': reactionEmoji,
    };
  }

  // インタラクションからの経過時間（分）
  int get minutesAgo => DateTime.now().difference(timestamp.toDate()).inMinutes;

  // 表示用の時間テキスト
  String get timeAgo {
    final minutes = minutesAgo;
    if (minutes < 1) {
      return 'たった今';
    } else if (minutes < 60) {
      return '$minutes分前';
    } else {
      final hours = minutes ~/ 60;
      return '$hours時間前';
    }
  }
}
