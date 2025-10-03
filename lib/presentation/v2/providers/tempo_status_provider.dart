import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entity/tempo_status.dart';
import '../../../domain/usecases/tempo_status_usecase.dart';

/// Tempoアプリのステータス管理プロバイダー
final tempoStatusProvider =
    StateNotifierProvider<TempoStatusNotifier, TempoStatusState>(
  (ref) => TempoStatusNotifier(ref),
);

class TempoStatusState {
  final TempoStatus? status;
  final bool isLoading;
  final String? error;

  const TempoStatusState({
    this.status,
    this.isLoading = false,
    this.error,
  });

  TempoStatusState copyWith({
    TempoStatus? status,
    bool? isLoading,
    String? error,
  }) {
    return TempoStatusState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TempoStatusNotifier extends StateNotifier<TempoStatusState> {
  final Ref ref;
  late final TempoStatusUsecase _usecase;

  TempoStatusNotifier(this.ref) : super(const TempoStatusState()) {
    _usecase = ref.read(tempoStatusUsecaseProvider);
    _loadCurrentStatus();
  }

  /// 現在のステータスを読み込み
  Future<void> _loadCurrentStatus() async {
    debugPrint('_loadCurrentStatus 開始');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('_loadCurrentStatus userId: $userId');
    if (userId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final status = await _usecase.getMyStatus(userId);
      debugPrint(
          '_loadCurrentStatus 取得完了: status=${status?.status}, mood=${status?.mood}');
      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      debugPrint('_loadCurrentStatus エラー: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 新しいステータスを作成
  Future<void> createStatus({
    required String status,
    required String mood,
  }) async {
    debugPrint('TempoStatusProvider.createStatus 開始');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('userId: $userId');

    if (userId == null) {
      debugPrint('ユーザー認証エラー');
      state = state.copyWith(error: 'ユーザーが認証されていません');
      return;
    }

    // バリデーション
    final statusError = _usecase.validateStatusInput(status);
    final moodError = _usecase.validateMoodInput(mood);

    if (statusError != null) {
      debugPrint('ステータス入力エラー: $statusError');
      state = state.copyWith(error: statusError);
      return;
    }

    if (moodError != null) {
      debugPrint('気分入力エラー: $moodError');
      state = state.copyWith(error: moodError);
      return;
    }

    try {
      debugPrint('ステータス作成処理開始');
      state = state.copyWith(isLoading: true, error: null);

      await _usecase.createStatus(
        userId: userId,
        status: status,
        mood: mood,
      );

      debugPrint('ステータス作成完了、最新データを取得');
      // 作成後、最新のステータスを取得
      await _loadCurrentStatus();
      debugPrint('ステータス作成処理完了');
    } catch (e) {
      debugPrint('ステータス作成エラー: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ステータスを更新
  Future<void> updateStatus({
    String? status,
    String? mood,
  }) async {
    debugPrint('TempoStatusProvider.updateStatus 開始');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('userId: $userId');

    if (userId == null) {
      debugPrint('ユーザー認証エラー');
      state = state.copyWith(error: 'ユーザーが認証されていません');
      return;
    }

    // バリデーション
    if (status != null) {
      final statusError = _usecase.validateStatusInput(status);
      if (statusError != null) {
        debugPrint('ステータス入力エラー: $statusError');
        state = state.copyWith(error: statusError);
        return;
      }
    }

    if (mood != null) {
      final moodError = _usecase.validateMoodInput(mood);
      if (moodError != null) {
        debugPrint('気分入力エラー: $moodError');
        state = state.copyWith(error: moodError);
        return;
      }
    }

    try {
      debugPrint('ステータス更新処理開始');
      state = state.copyWith(isLoading: true, error: null);

      await _usecase.updateStatus(
        userId: userId,
        status: status,
        mood: mood,
      );

      debugPrint('ステータス更新完了、最新データを取得');
      // 更新後、最新のステータスを取得
      await _loadCurrentStatus();
      debugPrint('ステータス更新処理完了');
    } catch (e) {
      debugPrint('ステータス更新エラー: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ステータスを削除
  Future<void> deleteStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      state = state.copyWith(error: 'ユーザーが認証されていません');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      await _usecase.deleteStatus(userId);
      state = state.copyWith(status: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 近くのステータス一覧プロバイダー
final nearbyStatusesProvider = FutureProvider<List<TempoStatus>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final usecase = ref.read(tempoStatusUsecaseProvider);
  try {
    return await usecase.getNearbyStatuses(userId);
  } catch (e) {
    return [];
  }
});

/// 自分のステータスへのインタラクション一覧プロバイダー
final myStatusInteractionsProvider =
    FutureProvider<List<TempoInteraction>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final usecase = ref.read(tempoStatusUsecaseProvider);
  try {
    return await usecase.getMyStatusInteractions(userId);
  } catch (e) {
    return [];
  }
});

/// ステータス編集用の一時的な状態管理
final tempoStatusEditProvider =
    StateProvider.autoDispose<TempoStatusEditState>((ref) {
  final currentStatus = ref.watch(tempoStatusProvider).status;
  return TempoStatusEditState(
    status: currentStatus?.status ?? '',
    mood: currentStatus?.mood ?? '😊',
  );
});

class TempoStatusEditState {
  final String status;
  final String mood;

  const TempoStatusEditState({
    required this.status,
    required this.mood,
  });

  TempoStatusEditState copyWith({
    String? status,
    String? mood,
  }) {
    return TempoStatusEditState(
      status: status ?? this.status,
      mood: mood ?? this.mood,
    );
  }
}
