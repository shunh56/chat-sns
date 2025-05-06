// lib/presentation/providers/followers_stream_notifier.dart

import 'dart:async';

import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/follow/get_followers_stream_usecase.dart';
import 'package:app/domain/usecases/follow/get_followers_usecase.dart';

import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
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

  return ref.watch(getFollowersStreamUsecaseProvider).call(targetUserId);
});

/// フォロワーリストをUserAccountリストとして提供するプロバイダー
final followersUserStreamProvider = StreamProvider.autoDispose
    .family<List<UserAccount>, String?>((ref, userId) {
  final targetUserId = userId ?? ref.watch(authProvider).currentUser?.uid;

  if (targetUserId == null) {
    return Stream.value([]);
  }

  return ref
      .watch(followersStreamProvider(targetUserId))
      .when(
        data: (data) => Stream.value(data),
        loading: () => Stream.value([]),
        error: (_, __) => Stream.value([]),
      )
      .asyncMap((followerIds) async {
    if (followerIds.isEmpty) {
      return [];
    }
    final userProvider = ref.read(allUsersNotifierProvider.notifier);
    return await userProvider.getUserAccounts(followerIds.cast<String>());
  });
});

final followersListNotifierProvider = StateNotifierProvider.autoDispose<
    FollowersListNotifier, AsyncValue<List<UserAccount>>>(
  (ref) => FollowersListNotifier(ref),
);

class FollowersListNotifier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  FollowersListNotifier(this.ref)
      : super(const AsyncValue<List<UserAccount>>.loading());

  final Ref ref;

  /// 特定のユーザーがフォロワーかどうかをチェック
  bool isFollower(String userId) {
    final asyncValue = ref.read(followersStreamProvider(userId));
    if (!asyncValue.hasValue) return false;
    return asyncValue.value!.any((uid) => uid == userId);
  }

  /// フォロワーの更新を監視する（新しいフォロワーの通知などに利用）
  void watchNewFollowers(Function(UserAccount) onNewFollower) {
    final currentUserId = ref.read(authProvider).currentUser?.uid;
    if (currentUserId == null) return;

    final asyncValue = ref.read(followersStreamProvider(currentUserId));
    if (!asyncValue.hasValue) return;

    List<String> prevFollowers = asyncValue.value ?? [];

    // ストリームを直接サブスクライブする
    final stream = ref.read(followersUserStreamProvider(currentUserId).stream);

    // ストリームサブスクリプション
    final subscription = stream.listen((newFollowers) {
      // 新しく追加されたフォロワーを見つける
      for (final newFollower in newFollowers) {
        if (!prevFollowers.any((uid) => uid == newFollower.userId)) {
          // 新しいフォロワーを発見
          onNewFollower(newFollower);
        }
      }

      // 現在のフォロワーリストを更新
      prevFollowers = newFollowers.map((user) => user.userId).toList();
    });

    // サブスクリプションの管理
    ref.onDispose(() {
      subscription.cancel();
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
      return [];
    }
  }

  /// フォロワーをソートする
  List<UserAccount> sortFollowers(List<UserAccount> followers,
      {FollowerSortOption sortOption = FollowerSortOption.latestFirst}) {
    // ソートロジックをここに実装
    switch (sortOption) {
      case FollowerSortOption.nameAscending:
        followers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case FollowerSortOption.nameDescending:
        followers.sort((a, b) => b.name.compareTo(a.name));
        break;
      // 他のソートオプションは必要に応じて追加
      // ただし最新順/古い順はフォロー日時のデータが必要です
      default:
        // デフォルトはそのまま
        break;
    }
    return followers;
  }
}

// FollowerSortOption enum
enum FollowerSortOption {
  latestFirst, // 最新順
  oldestFirst, // 古い順
  nameAscending, // 名前昇順
  nameDescending, // 名前降順
}
