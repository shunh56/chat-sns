// lib/presentation/providers/followers_stream_notifier.dart

import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/follow/get_followers_stream_usecase.dart';
import 'package:app/domain/usecases/follow/get_followers_usecase.dart';

import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// フォロワーストリームを提供するプロバイダー
/// ユーザーIDが指定されている場合はそのユーザーのフォロワーを、
/// 指定されていない場合は現在ログイン中のユーザーのフォロワーを返す
final followersStreamProvider =
    StreamProvider.autoDispose.family<List<String>, String?>((ref, userId) {
  final targetUserId = userId ?? ref.watch(authProvider).currentUser?.uid;

  if (targetUserId == null) {
    return Stream.value([]);
  }

  // ストリームを維持する
  ref.keepAlive();
  return ref.watch(getFollowersStreamUsecaseProvider).call(targetUserId);
});

// フォロワー状態をチェックするための最適化されたプロバイダー
final isFollowerProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(followersListNotifierProvider).maybeWhen(
        data: (list) => list.any((id) => id == userId),
        orElse: () => false,
      );
});

final followersListNotifierProvider = StateNotifierProvider.autoDispose<
    FollowersListNotifier, AsyncValue<List<String>>>(
  (ref) => FollowersListNotifier(
    ref,
    ref.watch(authProvider),
  )..initialize(),
);

class FollowersListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  FollowersListNotifier(
    this.ref,
    this._auth,
  ) : super(const AsyncValue<List<String>>.loading());

  final Ref ref;
  final FirebaseAuth _auth;

  // ストリームサブスクリプションを管理
  StreamSubscription? _followerSubscription;

  Future<void> initialize() async {
    try {
      // disposeされていれば処理をスキップ
      if (!mounted) return;

      state = const AsyncValue.loading();
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        state = AsyncValue.error('ユーザーがログインしていません', StackTrace.current);
        return;
      }

      // フォロワーユーザーのIDリストを初期取得
      final followerIds =
          await ref.read(getFollowersUsecaseProvider).call(currentUser.uid);

      // IDリストからユーザー情報を取得

      // disposeされていなければ状態を更新
      if (mounted) {
        // 状態を更新
        state = AsyncValue.data(followerIds);
        DebugPrint(
            "Followers list initialized with ${followerIds.length} users");

        // ストリームの監視を開始
        _startListeningToFollowers(currentUser.uid);
      }
    } catch (e, stack) {
      if (mounted) {
        DebugPrint("Error in initialize followers: $e");
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// ストリームの監視を開始
  void _startListeningToFollowers(String userId) {
    // 既存のサブスクリプションがあればキャンセル
    _followerSubscription?.cancel();

    // フォロワーIDのストリームを監視
    _followerSubscription =
        ref.read(followersStreamProvider(userId).stream).listen(
      (followerIds) async {
        if (!mounted) return;

        try {
          // IDリストからユーザー情報を取得

          // 状態を更新
          if (mounted) {
            state = AsyncValue.data(followerIds);
          }
        } catch (e) {
          DebugPrint("Error updating followers: $e");
          // エラーが発生しても完全に置き換えるのではなく、エラー情報を保持
          if (mounted) {
            state = AsyncValue.error(e, StackTrace.current);
          }
        }
      },
      onError: (error) {
        if (mounted) {
          state = AsyncValue.error(error, StackTrace.current);
        }
      },
    );

    // Notifierが破棄されるときにサブスクリプションをキャンセル
    ref.onDispose(() {
      DebugPrint("フォロワーストリームの購読をキャンセル");
      _followerSubscription?.cancel();
      _followerSubscription = null;
    });
  }

  /// 特定のユーザーのフォロワーリストを一度だけ取得
  Future<List<UserAccount>> getFollowers({String? userId}) async {
    try {
      final targetUserId = userId ?? ref.read(authProvider).currentUser?.uid;

      if (targetUserId == null) {
        return [];
      }

      final userIds =
          await ref.read(getFollowersUsecaseProvider).call(targetUserId);
      return await ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(userIds);
    } catch (e) {
      DebugPrint("Error getting followers: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _followerSubscription?.cancel();
    super.dispose();
  }
}

// FollowerSortOption enum
enum FollowerSortOption {
  latestFirst, // 最新順
  oldestFirst, // 古い順
  nameAscending, // 名前昇順
  nameDescending, // 名前降順
}
