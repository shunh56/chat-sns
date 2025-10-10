import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintDatasourceProvider = Provider(
  (ref) => FootprintDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class FootprintDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FootprintDatasource(this._auth, this._firestore);

  /// v2.0.0: 親コレクション名（全ユーザー共通）
  static const String footprintsCollection = "footprints";

  /// ユーザーのプロフィールを訪問した際に足あとを残す
  ///
  /// v2.0.0設計変更:
  /// - 親コレクション（footprints）に1つのドキュメントのみ作成
  /// - ドキュメントIDは自動生成
  /// - データ量が半分に削減（旧: 2ドキュメント → 新: 1ドキュメント）
  Future<void> addFootprint(String userId) async {
    final myUid = _auth.currentUser!.uid;
    final ts = Timestamp.now();

    // 親コレクションに1つのドキュメントを作成
    final footprintRef =
        _firestore.collection(footprintsCollection).doc(); // 自動生成ID

    await footprintRef.set({
      "visitorId": myUid, // 訪問者（自分）
      "visitedUserId": userId, // 訪問先
      "visitedAt": ts,
      "isSeen": false, // 初期状態は未読
      "version": 2, // v2.0.0データ
    });
  }

  /// 特定のユーザーとの足あとを全て削除する
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから該当する足あとを削除
  /// - 自分が訪問した記録のみ削除（visitorId == 自分 && visitedUserId == 対象）
  Future<void> deleteFootprint(String targetUserId) async {
    final myUid = _auth.currentUser!.uid;

    // 親コレクションから自分→対象ユーザーへの訪問記録を削除
    final footprints = await _firestore
        .collection(footprintsCollection)
        .where("visitorId", isEqualTo: myUid)
        .where("visitedUserId", isEqualTo: targetUserId)
        .get();

    // バッチ処理で削除
    final batch = _firestore.batch();

    for (var doc in footprints.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// 自分を訪問したユーザーのストリーム（訪問者リスト）
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションからvisitedUserId == 自分のドキュメントを取得
  Stream<List<Footprint>> getVisitors(String userId) {
    return _firestore
        .collection(footprintsCollection)
        .where("visitedUserId", isEqualTo: userId)
        .orderBy("visitedAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Footprint.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// 過去24時間の訪問者ストリーム
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションからvisitedUserId == 自分 && visitedAt > 24時間前
  Stream<List<Footprint>> getRecentVisitors(String userId) {
    final twentyFourHoursAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    return _firestore
        .collection(footprintsCollection)
        .where("visitedUserId", isEqualTo: userId)
        .where('visitedAt', isGreaterThan: twentyFourHoursAgo)
        .orderBy('visitedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Footprint.fromFirestore(doc.id, doc.data()))
            .toList())
        .handleError((error) {
      return <Footprint>[];
    });
  }

  /// 自分が訪問したユーザーのストリーム（訪問先リスト）
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションからvisitorId == 自分のドキュメントを取得
  Stream<List<Footprint>> getVisited(String userId) {
    return _firestore
        .collection(footprintsCollection)
        .where("visitorId", isEqualTo: userId)
        .orderBy("visitedAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Footprint.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// 複数の足あとを既読にする（バッチ処理）
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションのドキュメントIDを受け取って既読化
  Future<void> markMultipleAsSeen(
      String userId, List<String> footprintIds) async {
    final batch = _firestore.batch();

    for (final footprintId in footprintIds) {
      final docRef =
          _firestore.collection(footprintsCollection).doc(footprintId);

      batch.update(docRef, {'isSeen': true});
    }

    await batch.commit();
  }

  /// 全ての足あとを既読にする
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && isSeen == false を取得して既読化
  Future<void> markSeen(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where("visitedUserId", isEqualTo: userId)
        .where("isSeen", isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {"isSeen": true});
    }

    await batch.commit();
  }

  /// 過去24時間以内の未読足あと数を取得
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && visitedAt > 24時間前 && isSeen == false
  Future<int> getRecentUnseenCount(String userId) async {
    final twentyFourHoursAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where('visitedUserId', isEqualTo: userId)
        .where('visitedAt', isGreaterThan: twentyFourHoursAgo)
        .where('isSeen', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// 指定期間以降の訪問回数を取得
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && visitedAt > since
  Future<int> getCountForPeriod(String userId, Timestamp since) async {
    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where('visitedUserId', isEqualTo: userId)
        .where('visitedAt', isGreaterThan: since)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// 未読の訪問者数を取得
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && isSeen == false
  Future<int> getUnseenCount(String userId) async {
    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where('visitedUserId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// 過去24時間の時間帯別訪問回数分布を取得
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && visitedAt > 24時間前
  Future<Map<int, int>> getHourlyDistribution(String userId) async {
    final distribution = <int, int>{};

    final twentyFourHoursAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where('visitedUserId', isEqualTo: userId)
        .where('visitedAt', isGreaterThan: twentyFourHoursAgo)
        .get();

    for (final doc in snapshot.docs) {
      final footprint = Footprint.fromFirestore(doc.id, doc.data());
      final hour = footprint.visitedAt.toDate().hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }

    return distribution;
  }

  /// 過去1週間の頻繁な訪問者（上位5人）を取得
  ///
  /// v2.0.0設計変更:
  /// - 親コレクションから visitedUserId == 自分 && visitedAt > 1週間前
  Future<List<String>> getFrequentVisitors(String userId) async {
    final visitorCounts = <String, int>{};

    final oneWeekAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    final snapshot = await _firestore
        .collection(footprintsCollection)
        .where('visitedUserId', isEqualTo: userId)
        .where('visitedAt', isGreaterThan: oneWeekAgo)
        .get();

    for (final doc in snapshot.docs) {
      final footprint = Footprint.fromFirestore(doc.id, doc.data());
      visitorCounts[footprint.visitorId] =
          (visitorCounts[footprint.visitorId] ?? 0) + 1;
    }

    // 訪問回数でソートして上位5人を返す
    final sorted = visitorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }
}
