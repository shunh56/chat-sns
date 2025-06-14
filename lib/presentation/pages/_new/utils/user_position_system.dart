import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/appcolors.dart';

class UserPosition {
  final Offset position;
  final double radius;
  final UserModel user;
  final int index;

  UserPosition({
    required this.position,
    required this.radius,
    required this.user,
    required this.index,
  });
}

class UserPositioningSystem {
  static const double _minDistance = 20.0; // 最小距離
  static const int _maxAttempts = 100; // 配置試行回数
  static const double _screenMargin = 60.0; // 画面端からのマージン

  final Size screenSize;
  final Random _random = Random();
  final List<UserPosition> _placedUsers = [];

  UserPositioningSystem({required this.screenSize});

  List<UserPosition> generatePositions(List<UserModel> users) {
    _placedUsers.clear();

    // ユーザータイプ別にソート（重要度順）
    final sortedUsers = _sortUsersByPriority(users);

    for (int i = 0; i < sortedUsers.length; i++) {
      final user = sortedUsers[i];
      final radius = _getUserRadius(user);
      final position = _generateNonOverlappingPosition(radius, user.type);

      if (position != null) {
        _placedUsers.add(UserPosition(
          position: position,
          radius: radius,
          user: user,
          index: i,
        ));
      }
    }

    return List.from(_placedUsers);
  }

  List<UserModel> _sortUsersByPriority(List<UserModel> users) {
    final List<UserModel> sortedUsers = List.from(users);

    // タイプ別に優先度付けしてソート
    sortedUsers.sort((a, b) {
      final aPriority = _getTypePriority(a.type);
      final bPriority = _getTypePriority(b.type);

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // 同じタイプならcompatibilityで並び替え
      return b.compatibility.compareTo(a.compatibility);
    });

    return sortedUsers;
  }

  int _getTypePriority(UserType type) {
    switch (type) {
      case UserType.primary:
        return 1; // 最優先
      case UserType.secondary:
        return 2;
      case UserType.tertiary:
        return 3;
    }
  }

  double _getUserRadius(UserModel user) {
    switch (user.type) {
      case UserType.primary:
        return AppConstants.primaryPlanetSize * 0.9; // 少し余裕をもたせる
      case UserType.secondary:
        return AppConstants.secondaryPlanetSize * 0.9;
      case UserType.tertiary:
        return AppConstants.tertiaryPlanetSize * 0.9;
    }
  }

  Offset? _generateNonOverlappingPosition(double radius, UserType userType) {
    final availableWidth =
        screenSize.width - (_screenMargin * 2) - (radius * 2);
    final availableHeight =
        screenSize.height - (_screenMargin * 2) - (radius * 2);

    if (availableWidth <= 0 || availableHeight <= 0) {
      return null; // 画面が小さすぎる
    }

    // タイプ別の配置戦略
    final preferredZones =
        _getPreferredZones(userType, availableWidth, availableHeight);

    for (int attempt = 0; attempt < _maxAttempts; attempt++) {
      Offset? candidate;

      // 優先ゾーンから試す
      if (attempt < _maxAttempts * 0.7) {
        candidate = _generatePositionInZones(preferredZones, radius);
      } else {
        // 最後の手段：画面全体からランダム
        candidate =
            _generateRandomPosition(availableWidth, availableHeight, radius);
      }

      if (candidate != null && _isPositionValid(candidate, radius)) {
        return candidate;
      }
    }

    return null; // 配置できなかった場合
  }

  List<Rect> _getPreferredZones(
      UserType userType, double availableWidth, double availableHeight) {
    final width = availableWidth;
    final height = availableHeight;

    switch (userType) {
      case UserType.primary:
        // 中央エリアを優先
        return [
          Rect.fromLTWH(
            width * 0.3,
            height * 0.3,
            width * 0.4,
            height * 0.4,
          ),
        ];

      case UserType.secondary:
        // 四隅と中央周辺
        return [
          // 左上
          Rect.fromLTWH(0, 0, width * 0.4, height * 0.4),
          // 右上
          Rect.fromLTWH(width * 0.6, 0, width * 0.4, height * 0.4),
          // 左下
          Rect.fromLTWH(0, height * 0.6, width * 0.4, height * 0.4),
          // 右下
          Rect.fromLTWH(width * 0.6, height * 0.6, width * 0.4, height * 0.4),
        ];

      case UserType.tertiary:
        // エッジエリア
        return [
          // 上部
          Rect.fromLTWH(width * 0.2, 0, width * 0.6, height * 0.3),
          // 下部
          Rect.fromLTWH(width * 0.2, height * 0.7, width * 0.6, height * 0.3),
          // 左側
          Rect.fromLTWH(0, height * 0.2, width * 0.3, height * 0.6),
          // 右側
          Rect.fromLTWH(width * 0.7, height * 0.2, width * 0.3, height * 0.6),
        ];
    }
  }

  Offset? _generatePositionInZones(List<Rect> zones, double radius) {
    if (zones.isEmpty) return null;

    final zone = zones[_random.nextInt(zones.length)];

    if (zone.width <= 0 || zone.height <= 0) return null;

    final x = zone.left + _random.nextDouble() * zone.width;
    final y = zone.top + _random.nextDouble() * zone.height;

    return Offset(
      (_screenMargin + radius + x).clamp(
          _screenMargin + radius, screenSize.width - _screenMargin - radius),
      (_screenMargin + radius + y).clamp(
          _screenMargin + radius, screenSize.height - _screenMargin - radius),
    );
  }

  Offset _generateRandomPosition(
      double availableWidth, double availableHeight, double radius) {
    final x = _screenMargin + radius + (_random.nextDouble() * availableWidth);
    final y = _screenMargin + radius + (_random.nextDouble() * availableHeight);

    return Offset(x, y);
  }

  bool _isPositionValid(Offset position, double radius) {
    // 画面境界チェック
    if (position.dx - radius < _screenMargin ||
        position.dx + radius > screenSize.width - _screenMargin ||
        position.dy - radius < _screenMargin ||
        position.dy + radius > screenSize.height - _screenMargin) {
      return false;
    }

    // 他のユーザーとの重複チェック
    for (final placedUser in _placedUsers) {
      final distance = (position - placedUser.position).distance;
      final minRequiredDistance = radius + placedUser.radius + _minDistance;

      if (distance < minRequiredDistance) {
        return false;
      }
    }

    return true;
  }

  // デバッグ用：配置効率の統計を取得
  PositioningStats getStats() {
    final typeCount = <UserType, int>{};
    final totalArea = screenSize.width * screenSize.height;
    double usedArea = 0;

    for (final user in _placedUsers) {
      typeCount[user.user.type] = (typeCount[user.user.type] ?? 0) + 1;
      usedArea += pi * user.radius * user.radius;
    }

    return PositioningStats(
      totalUsers: _placedUsers.length,
      typeDistribution: typeCount,
      spaceUtilization: usedArea / totalArea,
      averageDistance: _calculateAverageDistance(),
    );
  }

  double _calculateAverageDistance() {
    if (_placedUsers.length < 2) return 0;

    double totalDistance = 0;
    int pairCount = 0;

    for (int i = 0; i < _placedUsers.length; i++) {
      for (int j = i + 1; j < _placedUsers.length; j++) {
        totalDistance +=
            (_placedUsers[i].position - _placedUsers[j].position).distance;
        pairCount++;
      }
    }

    return pairCount > 0 ? totalDistance / pairCount : 0;
  }
}

class PositioningStats {
  final int totalUsers;
  final Map<UserType, int> typeDistribution;
  final double spaceUtilization;
  final double averageDistance;

  PositioningStats({
    required this.totalUsers,
    required this.typeDistribution,
    required this.spaceUtilization,
    required this.averageDistance,
  });

  @override
  String toString() {
    return 'PositioningStats(users: $totalUsers, utilization: ${(spaceUtilization * 100).toStringAsFixed(1)}%, avgDistance: ${averageDistance.toStringAsFixed(1)})';
  }
}
