import 'package:app/data/datasource/footprint_datasource.dart';
import 'package:app/domain/entity/footprint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintRepositoryProvider = Provider(
  (ref) => FootprintRepository(
    ref.watch(footprintDatasourceProvider),
  ),
);

class FootprintRepository {
  final FootprintDatasource _datasource;

  FootprintRepository(this._datasource);

  // 自分を訪問したユーザー一覧を取得
  Future<List<Footprint>> getFootprinteds() async {
    final res = await _datasource.fetchFootprinteds();
    return res.docs.map((doc) => Footprint.fromJson(doc.data())).toList();
  }

  // 自分が訪問したユーザー一覧を取得
  Future<List<Footprint>> getFootprints() async {
    final res = await _datasource.fetchFootprints();
    return res.docs.map((doc) => Footprint.fromJson(doc.data())).toList();
  }

  // 自分を訪問したユーザー一覧をリアルタイムで監視
  Stream<List<Footprint>> streamFootprinteds() {
    return _datasource.streamFootprinteds().map(
          (snapshot) => snapshot.docs
              .map((doc) => Footprint.fromJson(doc.data()))
              .toList(),
        );
  }

  // ユーザーのプロフィールを訪問した際に足あとを残す
  Future<void> addFootprint(String userId) {
    return _datasource.addFootprint(userId);
  }

  // 足あとを既読にする
  Future<void> markFootprintsSeen() {
    return _datasource.markFootprintsSeen();
  }

  // 足あとを削除する
  Future<void> deleteFootprint(String userId) {
    return _datasource.deleteFootprint(userId);
  }

  // 未読の足あと数を取得
  Future<int> getUnreadFootprintCount() {
    return _datasource.getUnreadFootprintCount();
  }

  /* // 足あとプライバシー設定を取得
  Future<FootprintPrivacy> getFootprintPrivacy({String? userId}) async {
    final settings = await _datasource.getFootprintSettings(userId: userId);
    return FootprintPrivacyExtension.fromString(settings["privacy"]);
  }
  
  // 足あとプライバシー設定を更新
  Future<void> updateFootprintPrivacy(FootprintPrivacy privacy) {
    return _datasource.updateFootprintSettings({
      "privacy": privacy.value,
    });
  }
  
  // 通知設定を更新
  Future<void> updateNotifyOnNew(bool notify) {
    return _datasource.updateFootprintSettings({
      "notifyOnNew": notify,
    });
  } */
}
