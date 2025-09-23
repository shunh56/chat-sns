import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entity/tempo_status.dart';

final tempoStatusRepositoryProvider = Provider<TempoStatusRepository>((ref) {
  return TempoStatusRepositoryImpl();
});

abstract class TempoStatusRepository {
  // 自分のステータスを取得
  Future<TempoStatus?> getMyStatus(String userId);
  
  // ステータスを作成
  Future<void> createStatus(TempoStatus status);
  
  // ステータスを更新
  Future<void> updateStatus(TempoStatus status);
  
  // ステータスを削除
  Future<void> deleteStatus(String userId);
  
  // 近くのアクティブなステータス一覧を取得
  Future<List<TempoStatus>> getNearbyStatuses(String geohash, {int limit = 20});
  
  // 特定の気分のステータス一覧を取得
  Future<List<TempoStatus>> getStatusesByMood(String mood, {int limit = 20});
  
  // インタラクションを記録
  Future<void> recordInteraction(TempoInteraction interaction);
  
  // 自分のステータスへのインタラクション一覧を取得
  Future<List<TempoInteraction>> getMyStatusInteractions(String statusOwnerId);
  
  // ステータスのリアルタイム監視
  Stream<TempoStatus?> watchMyStatus(String userId);
}

class TempoStatusRepositoryImpl implements TempoStatusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<TempoStatus?> getMyStatus(String userId) async {
    try {
      final doc = await _firestore
          .collection('tempoStatuses')
          .doc(userId)
          .get();
      
      if (!doc.exists) return null;
      
      final status = TempoStatus.fromJson(doc.data()!);
      return status.isVisible ? status : null;
    } catch (e) {
      throw Exception('ステータスの取得に失敗しました: $e');
    }
  }

  @override
  Future<void> createStatus(TempoStatus status) async {
    try {
      await _firestore
          .collection('tempoStatuses')
          .doc(status.userId)
          .set(status.toJson());
    } catch (e) {
      throw Exception('ステータスの作成に失敗しました: $e');
    }
  }

  @override
  Future<void> updateStatus(TempoStatus status) async {
    try {
      final updatedStatus = status.copyWith(
        updatedAt: Timestamp.now(),
      );
      
      await _firestore
          .collection('tempoStatuses')
          .doc(status.userId)
          .update(updatedStatus.toJson());
    } catch (e) {
      throw Exception('ステータスの更新に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteStatus(String userId) async {
    try {
      await _firestore
          .collection('tempoStatuses')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('ステータスの削除に失敗しました: $e');
    }
  }

  @override
  Future<List<TempoStatus>> getNearbyStatuses(String geohash, {int limit = 20}) async {
    try {
      final now = Timestamp.now();
      
      // Geohashの前方一致で近くのステータスを検索
      final geohashPrefix = geohash.substring(0, 6); // 精度を調整
      
      final query = await _firestore
          .collection('tempoStatuses')
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      
      final statuses = query.docs
          .map((doc) => TempoStatus.fromJson(doc.data()))
          .where((status) => status.location.geohash.startsWith(geohashPrefix))
          .toList();
      
      return statuses;
    } catch (e) {
      throw Exception('近くのステータス取得に失敗しました: $e');
    }
  }

  @override
  Future<List<TempoStatus>> getStatusesByMood(String mood, {int limit = 20}) async {
    try {
      final now = Timestamp.now();
      
      final query = await _firestore
          .collection('tempoStatuses')
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .where('mood', isEqualTo: mood)
          .orderBy('expiresAt')
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
      
      return query.docs
          .map((doc) => TempoStatus.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('気分別ステータス取得に失敗しました: $e');
    }
  }

  @override
  Future<void> recordInteraction(TempoInteraction interaction) async {
    try {
      final statusId = interaction.statusOwnerId;
      final viewerId = interaction.viewerId;
      
      await _firestore
          .collection('tempoInteractions')
          .doc(statusId)
          .collection('viewers')
          .doc(viewerId)
          .set(interaction.toJson());
    } catch (e) {
      throw Exception('インタラクションの記録に失敗しました: $e');
    }
  }

  @override
  Future<List<TempoInteraction>> getMyStatusInteractions(String statusOwnerId) async {
    try {
      final query = await _firestore
          .collection('tempoInteractions')
          .doc(statusOwnerId)
          .collection('viewers')
          .orderBy('timestamp', descending: true)
          .limit(50) // 最新50件
          .get();
      
      return query.docs
          .map((doc) => TempoInteraction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('インタラクション取得に失敗しました: $e');
    }
  }

  @override
  Stream<TempoStatus?> watchMyStatus(String userId) {
    return _firestore
        .collection('tempoStatuses')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          
          final status = TempoStatus.fromJson(doc.data()!);
          return status.isVisible ? status : null;
        });
  }

  // ヘルパーメソッド: 期限切れステータスをクリーンアップ
  Future<void> cleanupExpiredStatuses() async {
    try {
      final now = Timestamp.now();
      
      final query = await _firestore
          .collection('tempoStatuses')
          .where('expiresAt', isLessThan: now)
          .limit(100)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('期限切れステータスのクリーンアップに失敗しました: $e');
    }
  }

  // ヘルパーメソッド: 古いインタラクションをクリーンアップ（7日以上前）
  Future<void> cleanupOldInteractions() async {
    try {
      final sevenDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 7)),
      );
      
      // すべてのtempoInteractionsドキュメントを取得
      final interactionDocs = await _firestore
          .collection('tempoInteractions')
          .get();
      
      for (final interactionDoc in interactionDocs.docs) {
        final viewersQuery = await interactionDoc.reference
            .collection('viewers')
            .where('timestamp', isLessThan: sevenDaysAgo)
            .limit(100)
            .get();
        
        final batch = _firestore.batch();
        
        for (final viewerDoc in viewersQuery.docs) {
          batch.delete(viewerDoc.reference);
        }
        
        if (viewersQuery.docs.isNotEmpty) {
          await batch.commit();
        }
      }
    } catch (e) {
      throw Exception('古いインタラクションのクリーンアップに失敗しました: $e');
    }
  }
}