import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/entity/footprint/footprint_statistics.dart';

/// 足あと機能のリポジトリインターフェース
///
/// クリーンアーキテクチャの原則に従い、Domain層でインターフェースを定義
abstract class IFootprintRepository {
  /// 訪問者リストを取得（過去24時間以内）
  Stream<List<Footprint>> getRecentVisitorsStream();

  /// 訪問者リストを取得（全期間）
  Stream<List<Footprint>> getVisitorsStream();

  /// 訪問先リストを取得
  Stream<List<Footprint>> getVisitedStream();

  /// プロフィール訪問時に足あとを残す
  Future<void> visitProfile(String targetUserId);

  /// 複数の足あとを既読にする（バッチ処理）
  ///
  /// 設計変更:
  /// - footprintIds（ドキュメントID）を受け取るように変更
  Future<void> markMultipleAsSeen(List<String> footprintIds);

  /// 全ての足あとを既読にする
  Future<void> markAllFootprintsSeen();

  /// 特定の足あとを削除
  Future<void> removeFootprint(String userId);

  /// 未読の足あと数を取得（過去24時間以内）
  Future<int> getRecentUnseenCount();

  /// 足あと統計情報を取得
  Future<FootprintStatistics> getStatistics();
}
