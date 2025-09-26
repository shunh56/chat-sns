import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/follow/follow_user_usecase.dart';
import 'package:app/domain/usecases/follow/get_following_usecase.dart';
import 'package:app/domain/usecases/follow/unfollow_user_usecase.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isFollowingProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(followingListNotifierProvider).maybeWhen(
        data: (list) => list.any((id) => id == userId),
        orElse: () => false,
      );
});

/// フォロー中ユーザーのリストを管理するNotifierProvider
final followingListNotifierProvider =
    StateNotifierProvider<FollowingListNotifier, AsyncValue<List<String>>>(
  (ref) {
    return FollowingListNotifier(
      ref,
      ref.watch(authProvider),
      ref.watch(followUserUsecaseProvider),
      ref.watch(unfollowUserUsecaseProvider),
      ref.watch(getFollowingUsecaseProvider),
      ref.watch(pushNotificationUsecaseProvider),
    )..initialize();
  },
);

class FollowingListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  FollowingListNotifier(
    this.ref,
    this._auth,
    this.followUseCase,
    this.unfollowUseCase,
    this.getFollowingUseCase,
    this.pushNotificationUsecase,
  ) : super(const AsyncValue<List<String>>.loading());

  final Ref ref;
  final FirebaseAuth _auth;
  final FollowUserUseCase followUseCase;
  final UnfollowUserUseCase unfollowUseCase;
  final GetFollowingUseCase getFollowingUseCase;
  final PushNotificationUsecase pushNotificationUsecase;

  Future<void> initialize() async {
    try {
      // disposeされていなければ状態を更新しない
      if (!mounted) return;

      state = const AsyncValue.loading();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = AsyncValue.error('ユーザーがログインしていません', StackTrace.current);
        return;
      }

      // フォロー中ユーザーのIDリストを取得
      final followingIds = await getFollowingUseCase(currentUser.uid);

      // IDリストからユーザー情報を取得
      // final users = await _getUsersFromIds(followingIds);

      // disposeされていなければ状態を更新する
      if (mounted) {
        state = AsyncValue.data(followingIds);

        DebugPrint(
            "Following list initialized with ${followingIds.length} users");
      }
    } catch (e, stack) {
      // disposeされていなければエラー状態を設定する
      if (mounted) {
        state = AsyncValue.error(e, stack);
        DebugPrint("Error initializing following list: $e");
      }
    }
  }

  /// ユーザーをフォローする
  Future<void> followUser(UserAccount user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }
      final listToUpdate = List<String>.from(state.value ?? []);
      // すでにフォロー中の場合は処理を行わない
      if (listToUpdate.any((id) => id == user.userId)) {
        return;
      }

      // 楽観的更新（Optimistic update）
      listToUpdate.add(user.userId);
      state = AsyncValue.data(listToUpdate);

      // 実際のAPIコール
      await followUseCase(currentUser.uid, user.userId);

      // 通知を送信
      await pushNotificationUsecase.sendFollow(user);

      // 関連するプロバイダーを無効化して更新を反映
      /*ref.invalidate(userFollowingProvider(currentUser.uid));
      ref.invalidate(
          isFollowingProvider(userId: currentUser.uid, targetId: user.userId)); */
    } catch (e, stack) {
      // エラー時に前の状態に戻す
      state = AsyncValue.error(e, stack);
      // 一貫性を確保するために再初期化
      await initialize();
    }
  }

  /// ユーザーのフォローを解除する
  Future<void> unfollowUser(UserAccount user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }
      final listToUpdate = List<String>.from(state.value ?? []);

      // 楽観的更新（Optimistic update）
      listToUpdate.removeWhere((id) => id == user.userId);
      state = AsyncValue.data(listToUpdate);

      // 実際のAPIコール
      await unfollowUseCase(currentUser.uid, user.userId);

      // 関連するプロバイダーを無効化して更新を反映
      /*ref.invalidate(userFollowingProvider(currentUser.uid));
      ref.invalidate(
          isFollowingProvider(userId: currentUser.uid, targetId: user.userId)); */
    } catch (e, stack) {
      // エラー時に前の状態に戻す
      state = AsyncValue.error(e, stack);
      // 一貫性を確保するために再初期化
      await initialize();
    }
  }

  // Notifierが破棄されるときのクリーンアップ
  @override
  void dispose() {
    DebugPrint("FOLLOWING LIST DISPOSED");
    // 必要に応じてクリーンアップロジックを追加
    super.dispose();
  }
}
