import 'dart:math' as math;
import 'package:app/data/datasource/local/hashtags.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagDatasourceProvider = Provider(
  (ref) => TagDatasource(
    ref.watch(authProvider),
    ref.watch(firestoreProvider),
  ),
);

class TagDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  TagDatasource(this._auth, this._firestore);

  Future<void> updateUserTagsImmediate(
      List<String> newTags, List<String> previousTags) async {
    final userId = _auth.currentUser!.uid;
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();

    // 削除されたタグの処理
    final removedTags = previousTags.where((tag) => !newTags.contains(tag));
    for (final tagId in removedTags) {
      // tag_usersのステータスを変更
      final tagUserRef = _firestore
          .collection('tag_users')
          .doc(tagId)
          .collection('users')
          .doc(userId);
      batch.set(
          tagUserRef,
          {
            'status': 'removed',
            'updatedAt': timestamp,
          },
          SetOptions(merge: true));

      // タグのカウントを更新（減少）
      final tagDocRef = _firestore.collection('tags').doc(tagId);
      batch.set(
          tagDocRef,
          {
            'count': FieldValue.increment(-1),
            'lastUpdated': timestamp,
          },
          SetOptions(merge: true));

      // 履歴スナップショットを追加
      final dateId = DateTime.now().toIso8601String().substring(0, 10);
      final historyRef = _firestore
          .collection('tag_stats_history')
          .doc(tagId)
          .collection('snapshots')
          .doc(dateId);

      // 履歴がすでに存在するか確認
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        batch.set(
            historyRef,
            {
              'count': FieldValue.increment(-1),
              'timestamp': timestamp,
            },
            SetOptions(merge: true));
      } else {
        // 履歴用のカウントをタグから取得して設定
        final tagDoc = await tagDocRef.get();
        final currentCount = (tagDoc.data()?['count'] as int?) ?? 0;
        batch.set(historyRef, {
          'count': math.max(0, currentCount - 1), // カウントが0未満にならないよう保護
          'timestamp': timestamp,
        });
      }
    }

    // 追加されたタグの処理
    final addedTags = newTags.where((tag) => !previousTags.contains(tag));
    for (final tagId in addedTags) {
      // タグの処理
      final tagDocRef = _firestore.collection('tags').doc(tagId);
      final tagDoc = await tagDocRef.get();

      if (!tagDoc.exists) {
        // タグが存在しない場合は新規作成（カウント初期値は1）
        batch.set(tagDocRef, {
          'id': tagId,
          'text': getTextFromId(tagId) ?? tagId,
          'count': 1, // 初期値を1に設定
          'lastUpdated': timestamp,
        });
      } else {
        // 既存のタグの場合はカウントを増加
        batch.set(
            tagDocRef,
            {
              'count': FieldValue.increment(1),
              'lastUpdated': timestamp,
            },
            SetOptions(merge: true));
      }

      // 履歴スナップショットを追加
      final dateId = DateTime.now().toIso8601String().substring(0, 10);
      final historyRef = _firestore
          .collection('tag_stats_history')
          .doc(tagId)
          .collection('snapshots')
          .doc(dateId);

      // 履歴がすでに存在するか確認
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        batch.set(
            historyRef,
            {
              'count': FieldValue.increment(1),
              'timestamp': timestamp,
            },
            SetOptions(merge: true));
      } else {
        // 履歴用のカウントをタグから取得して設定
        int newCount = 1;
        if (tagDoc.exists) {
          final currentCount = (tagDoc.data()?['count'] as int?) ?? 0;
          newCount = currentCount + 1;
        }
        batch.set(historyRef, {
          'count': newCount,
          'timestamp': timestamp,
        });
      }
    }

    // バッチ実行
    await batch.commit();
  }

  Future<List<String>> getUserTags(String userId) async {
    final snapshot = await _firestore
        .collection('user_tags')
        .doc(userId)
        .collection('tags')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // 定時処理は残しておくが、リアルタイム更新もできるようにした
  Future<void> updateTagStatsDaily() async {
    // 全タグの統計を更新
    final tagSnapshot = await _firestore.collection('tags').get();
    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();
    final dateId =
        DateTime.now().toIso8601String().substring(0, 10); // 日付をIDとして使用

    for (final tagDoc in tagSnapshot.docs) {
      final tagId = tagDoc.id;

      // アクティブなユーザー数をカウント
      final activeUsersSnapshot = await _firestore
          .collection('tag_users')
          .doc(tagId)
          .collection('users')
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      final activeCount = activeUsersSnapshot.count;

      // タグの統計情報を更新
      final tagRef = _firestore.collection('tags').doc(tagId);
      batch.set(
          tagRef,
          {
            'count': activeCount,
            'lastUpdated': timestamp,
          },
          SetOptions(merge: true));

      // 履歴スナップショットを作成
      final historyRef = _firestore
          .collection('tag_stats_history')
          .doc(tagId)
          .collection('snapshots')
          .doc(dateId);

      // 履歴が既に存在するか確認
      final historyDoc = await historyRef.get();
      if (historyDoc.exists) {
        // 既存の履歴を更新
        batch.update(historyRef, {
          'count': activeCount,
          'timestamp': timestamp,
        });
      } else {
        // 新しい履歴を作成
        batch.set(historyRef, {
          'count': activeCount,
          'timestamp': timestamp,
        });
      }
    }

    // バッチ実行
    await batch.commit();
  }

  Future<Map<String, dynamic>> getTagStat(String tagId) async {
    final doc = await _firestore.collection('tags').doc(tagId).get();
    if (!doc.exists) {
      return {
        'id': tagId,
        'text': getTextFromId(tagId) ?? tagId,
        'count': 0,
        'lastUpdated': Timestamp.now(),
      };
    }
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPopularTags({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('tags')
        .orderBy('count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> getUsersByTag(String tagId,
      {int limit = 20, String? lastUserId}) async {
    Query query = _firestore
        .collection('tag_users')
        .doc(tagId)
        .collection('users')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastUserId != null) {
      final lastDoc = await _firestore
          .collection('tag_users')
          .doc(tagId)
          .collection('users')
          .doc(lastUserId)
          .get();

      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<Map<String, dynamic>>> getTagHistory(
    String tagId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startTimestamp = Timestamp.fromDate(startDate);
    final endTimestamp = Timestamp.fromDate(endDate);

    final snapshot = await _firestore
        .collection('tag_stats_history')
        .doc(tagId)
        .collection('snapshots')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThanOrEqualTo: endTimestamp)
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
