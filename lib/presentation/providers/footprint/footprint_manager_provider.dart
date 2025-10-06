import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/footprint/mark_seen_provider.dart';
import 'package:app/presentation/providers/footprint/remove_footprint_provider.dart';
import 'package:app/presentation/providers/footprint/unread_count_provider.dart';
import 'package:app/presentation/providers/footprint/visit_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 足あと機能の操作をまとめて提供する複合プロバイダ
final footprintManagerProvider = Provider(
  (ref) => FootprintManager(
    ref.watch(visitProfileProvider),
    ref.watch(markFootprintsSeenProvider),
    ref.watch(removeFootprintProvider),
    //ref.watch(footprintPrivacyProvider.notifier),
    ref,
  ),
);

class FootprintManager {
  final VisitProfileProvider _visitProfileProvider;
  final MarkSeenProvider _markSeenProvider;
  final RemoveFootprintProvider _removeFootprintProvider;
  //final PrivacySettingNotifier _privacySettingNotifier;
  final Ref _ref;

  FootprintManager(
    this._visitProfileProvider,
    this._markSeenProvider,
    this._removeFootprintProvider,
    // this._privacySettingNotifier,
    this._ref,
  );

  // プロフィール訪問時に足あとを残す
  Future<void> visitUserProfile(UserAccount user) async {
    await _visitProfileProvider.visitProfile(user);
  }

  // 全ての足あとを既読にする
  Future<void> markAllFootprintsSeen() async {
    await _markSeenProvider.markAllSeen();
  }

  // 特定の足あとを削除する
  Future<void> removeFootprint(String userId) async {
    await _removeFootprintProvider.removeFootprint(userId);
  }

  // 未読足あと数を取得
  int getUnreadCount() {
    final countState = _ref.read(unreadFootprintCountProvider);
    return countState.value ?? 0;
  }

  /* // プライバシー設定を更新する
  Future<void> updatePrivacySetting(FootprintPrivacy privacy) async {
    await _privacySettingNotifier.updatePrivacy(privacy);
  }

  // 足あと機能の有効/無効を切り替え
  Future<void> toggleFootprintFeature(bool enabled) async {
    final privacy =
        enabled ? FootprintPrivacy.everyone : FootprintPrivacy.disabled;
    await updatePrivacySetting(privacy);
  } 

   // 現在の足あと機能の状態を取得
  bool isFootprintEnabled() {
    final privacyState = _ref.read(footprintPrivacyProvider);
    return privacyState.value != FootprintPrivacy.disabled;
  }
  
  */
}
