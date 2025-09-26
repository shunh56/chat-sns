import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/tempo_status.dart';
import '../../data/repository/tempo_status_repository.dart';

final tempoStatusUsecaseProvider = Provider<TempoStatusUsecase>((ref) {
  return TempoStatusUsecase(ref.read(tempoStatusRepositoryProvider));
});

class TempoStatusUsecase {
  final TempoStatusRepository _repository;

  TempoStatusUsecase(this._repository);

  /// 自分のステータスを取得
  Future<TempoStatus?> getMyStatus(String userId) async {
    return await _repository.getMyStatus(userId);
  }

  /// 新しいステータスを作成
  Future<void> createStatus({
    required String userId,
    required String status,
    required String mood,
  }) async {
    // 位置情報を取得
    final location = await _getCurrentLocation();

    // 天気情報を取得（オプション）
    final weather = await _getWeatherInfo(location);

    final tempoStatus = TempoStatus.create(
      userId: userId,
      status: status,
      mood: mood,
      location: location,
      weather: weather,
    );

    await _repository.createStatus(tempoStatus);
  }

  /// ステータスを更新
  Future<void> updateStatus({
    required String userId,
    String? status,
    String? mood,
    bool? isActive,
  }) async {
    final currentStatus = await _repository.getMyStatus(userId);
    if (currentStatus == null) {
      throw Exception('更新するステータスが見つかりません');
    }

    // 位置情報を再取得（ステータス内容が変更された場合）
    TempoLocation? newLocation;
    TempoWeather? newWeather;

    if (status != null || mood != null) {
      newLocation = await _getCurrentLocation();
      newWeather = await _getWeatherInfo(newLocation);
    }

    final updatedStatus = currentStatus.copyWith(
      status: status,
      mood: mood,
      location: newLocation,
      weather: newWeather,
      isActive: isActive,
      updatedAt: Timestamp.now(),
    );

    await _repository.updateStatus(updatedStatus);
  }

  /// ステータスを削除
  Future<void> deleteStatus(String userId) async {
    await _repository.deleteStatus(userId);
  }

  /// 近くのユーザーのステータス一覧を取得
  Future<List<TempoStatus>> getNearbyStatuses(String userId) async {
    final myStatus = await _repository.getMyStatus(userId);
    if (myStatus == null) {
      throw Exception('まず自分のステータスを設定してください');
    }

    return await _repository.getNearbyStatuses(
      myStatus.location.geohash,
      limit: 20,
    );
  }

  /// 特定の気分のステータス一覧を取得
  Future<List<TempoStatus>> getStatusesByMood(String mood) async {
    return await _repository.getStatusesByMood(mood, limit: 20);
  }

  /// ステータスを見たことを記録
  Future<void> viewStatus({
    required String viewerId,
    required String viewerName,
    String? viewerAvatarUrl,
    required String statusOwnerId,
  }) async {
    final interaction = TempoInteraction(
      viewerId: viewerId,
      viewerName: viewerName,
      viewerAvatarUrl: viewerAvatarUrl,
      statusOwnerId: statusOwnerId,
      interactionType: 'view',
      timestamp: Timestamp.now(),
    );

    await _repository.recordInteraction(interaction);
  }

  /// ステータスにリアクション
  Future<void> reactToStatus({
    required String viewerId,
    required String viewerName,
    String? viewerAvatarUrl,
    required String statusOwnerId,
    required String reactionEmoji,
  }) async {
    final interaction = TempoInteraction(
      viewerId: viewerId,
      viewerName: viewerName,
      viewerAvatarUrl: viewerAvatarUrl,
      statusOwnerId: statusOwnerId,
      interactionType: 'react',
      timestamp: Timestamp.now(),
      reactionEmoji: reactionEmoji,
    );

    await _repository.recordInteraction(interaction);
  }

  /// 自分のステータスへのインタラクション一覧を取得
  Future<List<TempoInteraction>> getMyStatusInteractions(String userId) async {
    return await _repository.getMyStatusInteractions(userId);
  }

  /// 自分のステータスをリアルタイム監視
  Stream<TempoStatus?> watchMyStatus(String userId) {
    return _repository.watchMyStatus(userId);
  }

  /// ステータス入力のバリデーション
  String? validateStatusInput(String status) {
    if (status.isEmpty) {
      return 'ステータスを入力してください';
    }
    if (status.length > 20) {
      return 'ステータスは20字以内で入力してください';
    }
    return null;
  }

  /// 気分絵文字のバリデーション
  String? validateMoodInput(String mood) {
    if (mood.isEmpty) {
      return '気分を選択してください';
    }
    // 絵文字かどうかの簡単なチェック
    if (mood.runes.length != 1) {
      return '有効な絵文字を選択してください';
    }
    return null;
  }

  /// 現在地を取得
  Future<TempoLocation> _getCurrentLocation() async {
    try {
      // 位置情報の許可を確認
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('位置情報サービスが無効です');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('位置情報の許可が拒否されました');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('位置情報の許可が永続的に拒否されています');
      }

      // 現在地を取得
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // ジオハッシュを生成（精度6で約1.2km四方）
      final geohash =
          _generateGeohash(position.latitude, position.longitude, 6);

      // 住所を取得
      String prefecture = '';
      String city = '';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          prefecture = placemark.administrativeArea ?? '';
          city = placemark.locality ?? placemark.subAdministrativeArea ?? '';
        }
      } catch (e) {
        // ジオコーディングに失敗しても位置情報は記録
        debugPrint('住所取得に失敗: $e');
      }

      return TempoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
        prefecture: prefecture,
        city: city,
      );
    } catch (e) {
      debugPrint('位置情報の取得に失敗、ダミーデータを使用: $e');
      // 位置情報取得に失敗した場合（シミュレーター等）はダミーデータを使用
      return _getDummyLocation();
    }
  }

  /// ダミー位置情報を取得（シミュレーター用）
  TempoLocation _getDummyLocation() {
    // 東京駅の座標をダミーとして使用
    const lat = 35.6812;
    const lon = 139.7671;
    final geohash = _generateGeohash(lat, lon, 6);

    return TempoLocation(
      latitude: lat,
      longitude: lon,
      geohash: geohash,
      prefecture: '東京都',
      city: '千代田区',
    );
  }

  /// 天気情報を取得（オプション）
  Future<TempoWeather?> _getWeatherInfo(TempoLocation location) async {
    try {
      // TODO: OpenWeatherMap APIなどの実装
      // 現在はダミーデータを返す
      return TempoWeather(
        condition: 'sunny',
        temperature: 23.0,
        description: '晴れ',
        icon: '01d',
        fetchedAt: Timestamp.now(),
      );
    } catch (e) {
      // 天気情報の取得に失敗しても処理を継続
      debugPrint('天気情報の取得に失敗: $e');
      return null;
    }
  }

  /// 推奨気分絵文字リスト
  static const List<String> recommendedMoods = [
    '😊', // 嬉しい
    '😴', // 眠い
    '🤔', // 考え中
    '😎', // クール
    '🍔', // お腹空いた
    '☕', // カフェタイム
    '📚', // 勉強中
    '🎵', // 音楽
    '🏃', // 運動中
    '🎮', // ゲーム
    '💻', // 作業中
    '🌟', // 絶好調
    '😌', // まったり
    '🔥', // やる気
    '💤', // 疲れた
    '❤️' // 幸せ
  ];

  /// 推奨ステータステンプレート
  static const List<String> recommendedStatusTemplates = [
    'カフェでまったり',
    'お家でのんびり',
    'お散歩中',
    '勉強中',
    '仕事の合間',
    '電車で移動中',
    '友達と遊んでる',
    'ランチタイム',
    '映画鑑賞中',
    '音楽聞いてる',
    'ゲーム中',
    '本読んでる',
    '買い物中',
    'ジム行ってる',
    '料理してる',
    'お茶してる'
  ];

  /// 簡単なジオハッシュ生成（外部パッケージの代替）
  String _generateGeohash(double lat, double lon, int precision) {
    const String base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    double latMin = -90.0, latMax = 90.0;
    double lonMin = -180.0, lonMax = 180.0;

    String geohash = '';
    int bits = 0;
    int bit = 0;
    bool isLon = true;

    while (geohash.length < precision) {
      double mid;
      if (isLon) {
        mid = (lonMin + lonMax) / 2;
        if (lon >= mid) {
          bits = (bits << 1) | 1;
          lonMin = mid;
        } else {
          bits = bits << 1;
          lonMax = mid;
        }
      } else {
        mid = (latMin + latMax) / 2;
        if (lat >= mid) {
          bits = (bits << 1) | 1;
          latMin = mid;
        } else {
          bits = bits << 1;
          latMax = mid;
        }
      }

      isLon = !isLon;
      bit++;

      if (bit == 5) {
        geohash += base32[bits];
        bits = 0;
        bit = 0;
      }
    }

    return geohash;
  }
}
