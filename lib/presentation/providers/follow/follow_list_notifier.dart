import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/follow/follow_user_usecase.dart';
import 'package:app/domain/usecases/follow/get_following_usecase.dart';
import 'package:app/domain/usecases/follow/unfollow_user_usecase.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// フォロー中ユーザーのリストを管理するNotifierProvider
final followingListNotifierProvider = StateNotifierProvider.autoDispose<
    FollowingListNotifier, AsyncValue<List<UserAccount>>>(
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

class FollowingListNotifier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  FollowingListNotifier(
    this.ref,
    this._auth,
    this.followUseCase,
    this.unfollowUseCase,
    this.getFollowingUseCase,
    this.pushNotificationUsecase,
  ) : super(const AsyncValue<List<UserAccount>>.loading());

  final Ref ref;
  final FirebaseAuth _auth;
  final FollowUserUseCase followUseCase;
  final UnfollowUserUseCase unfollowUseCase;
  final GetFollowingUseCase getFollowingUseCase;
  final PushNotificationUsecase pushNotificationUsecase;

  /// フォロー中ユーザーのリストを初期化
  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = AsyncValue.error('ユーザーがログインしていません', StackTrace.current);
        return;
      }

      // フォロー中ユーザーのIDリストを取得
      final followingIds = await getFollowingUseCase(currentUser.uid);

      // IDリストからユーザー情報を取得
      final users = await _getUsersFromIds(followingIds);

      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// ユーザーをフォローする
  Future<void> followUser(UserAccount user) async {
    try {
      final currentState = state;
      if (!currentState.hasValue) return;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final listToUpdate = List<UserAccount>.from(currentState.value!);

      // すでにフォロー中の場合は処理を行わない
      if (listToUpdate.any((u) => u.userId == user.userId)) {
        return;
      }

      // 楽観的更新（Optimistic update）
      listToUpdate.add(user);
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
      final currentState = state;
      if (!currentState.hasValue) return;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final listToUpdate = List<UserAccount>.from(currentState.value!);

      // 楽観的更新（Optimistic update）
      listToUpdate.removeWhere((item) => item.userId == user.userId);
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

  /// ユーザーがフォロー中かどうかを確認する
  bool isFollowing(String userId) {
    final currentState = state;
    if (!currentState.hasValue) return false;
    return currentState.value!.any((user) => user.userId == userId);
  }

  /// IDリストからユーザー情報を取得するヘルパーメソッド
  Future<List<UserAccount>> _getUsersFromIds(List<String> userIds) async {
    final userProvider = ref.read(allUsersNotifierProvider.notifier);
    final users = await userProvider.getUserAccounts(userIds);
    return users;
  }

  // Notifierが破棄されるときのクリーンアップ
  @override
  void dispose() {
    // 必要に応じてクリーンアップロジックを追加
    super.dispose();
  }
}
