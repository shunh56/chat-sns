import 'package:cloud_firestore/cloud_firestore.dart';

/// 足あと（個別訪問記録）
///
/// v2.0.0設計変更:
/// - 親コレクション（`footprints`）に変更
/// - ドキュメントIDはFirestoreの自動生成ID（訪問ごとにユニーク）
/// - 同じユーザーの複数回訪問も全て記録される
/// - これにより正確な統計情報（訪問回数、時間帯分布など）が取得可能
class Footprint {
  final String id; // ドキュメントID（Firestoreの自動生成ID）
  final String visitorId; // 足あとを残したユーザーID
  final String visitedUserId; // 足あとをつけられたユーザーID
  final Timestamp visitedAt; // 訪問日時
  final bool isSeen; // 既読状態（所有者が確認したかどうか）
  final int version; // データバージョン（マイグレーション用）

  Footprint({
    required this.id,
    required this.visitorId,
    required this.visitedUserId,
    required this.visitedAt,
    this.isSeen = false,
    this.version = 2, // v2.0.0（親コレクション）
  });

  /// Firestoreドキュメントから変換
  ///
  /// v1データの互換性について:
  /// - v1データ（旧ネスト構造）は読み込みません
  /// - v1データが存在する場合は、旧データ削除スクリプトで削除してください
  /// - scripts/cleanup_old_footprints.js を実行
  factory Footprint.fromFirestore(String docId, Map<String, dynamic> json) {
    // v2データ形式のみサポート
    return Footprint(
      id: docId,
      visitorId: json["visitorId"] as String,
      visitedUserId: json["visitedUserId"] as String,
      visitedAt: json["visitedAt"] as Timestamp,
      isSeen: json["isSeen"] as bool? ?? false,
      version: json["version"] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "visitorId": visitorId,
      "visitedUserId": visitedUserId,
      "visitedAt": visitedAt,
      "isSeen": isSeen,
      "version": version,
    };
  }

  Footprint copyWith({
    String? id,
    String? visitorId,
    String? visitedUserId,
    Timestamp? visitedAt,
    bool? isSeen,
    int? version,
  }) {
    return Footprint(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      visitedUserId: visitedUserId ?? this.visitedUserId,
      visitedAt: visitedAt ?? this.visitedAt,
      isSeen: isSeen ?? this.isSeen,
      version: version ?? this.version,
    );
  }
}
