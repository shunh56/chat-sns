import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/providers/session_provider.dart';
import 'package:app/domain/entity/session.dart';
import 'package:app/domain/repository_interface/session_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// セッションリポジトリプロバイダー

// 現在のセッション状態を管理するStateNotifierProvider
final sessionStateProvider =
    StateNotifierProvider<SessionNotifier, Session?>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repository);
});

class SessionNotifier extends StateNotifier<Session?> {
  final SessionRepository _repository;

  SessionNotifier(this._repository) : super(null);

  // 新規セッションの開始
  Future<void> startSession() async {
    DebugPrint("Starting Session");
    if (state != null) {
      DebugPrint("already has session");
      return;
    } // 既にセッションが開始されている場合は何もしない
    final session = await _repository.createSession();
    state = session;
  }

  // セッション終了とFirestoreへの保存
  Future<void> endSession() async {
    DebugPrint("Ending Session");
    if (state == null) {
      DebugPrint("no session found");
      return;
    }

    final endTime = Timestamp.now();
    final duration =
        endTime.toDate().difference(state!.startedAt.toDate()).inSeconds;

    // セッションを更新して終了時間と期間を記録
    final updatedSession = state!.copyWith(
      endedAt: endTime,
      duration: duration,
    );

    // Firestoreに保存
    await _repository.saveSession(updatedSession);

    // 状態をクリア
    state = null;
  }

  // アクションの追跡
  void trackAction(String actionName) {
    if (state == null) return;

    final updatedActions = List<String>.from(state!.actions)..add(actionName);
    state = state!.copyWith(actions: updatedActions);
  }

  // 画面表示の追跡
  void trackScreenView(String screenName) {
    if (state == null) return;

    final screenViewData = {
      'screenName': screenName,
      'viewedAt': Timestamp.now(),
    };

    final updatedScreenViews =
        List<Map<String, dynamic>>.from(state!.screenViews)
          ..add(screenViewData);

    state = state!.copyWith(screenViews: updatedScreenViews);
  }
}
