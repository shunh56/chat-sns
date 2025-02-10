import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/comunity_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final joinedCommunitiesProvider =
    StreamProvider.autoDispose<List<Community>>((ref) {
  final usecase = ref.watch(communityUsecaseProvider);
  return usecase.streamJoinedCommunities();
});

// 参加中のコミュニティのIDリストを管理するプロバイダー
// これを使って参加/退会ボタンの状態を管理
final joinedCommunityIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(joinedCommunitiesProvider).when(
        data: (communities) => communities.map((c) => c.id).toList(),
        error: (_, __) => [],
        loading: () => [],
      );
});

// 人気のコミュニティプロバイダー
final popularCommunitiesProvider = FutureProvider<List<Community>>((ref) async {
  final usecase = ref.watch(communityUsecaseProvider);
  return await usecase.getPopularCommunities();
});

// 新規のコミュニティプロバイダー
final newCommunitiesProvider = FutureProvider<List<Community>>((ref) async {
  final usecase = ref.watch(communityUsecaseProvider);
  return await usecase.getNewCommunities();
});

class CommunityMember {
  final Timestamp joinedAt;
  final UserAccount user;

  CommunityMember(this.joinedAt, this.user);
}

final communityMembersNotifierProvider = StateNotifierProvider.family<
    CommunityMembersNotifiier,
    AsyncValue<List<CommunityMember>>,
    String>((ref, communityId) {
  return CommunityMembersNotifiier(
    ref,
    communityId,
    ref.watch(communityUsecaseProvider),
  )..initialize();
});

/// State
class CommunityMembersNotifiier
    extends StateNotifier<AsyncValue<List<CommunityMember>>> {
  CommunityMembersNotifiier(
    this.ref,
    this.communityId,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId;
  final CommunityUsecase usecase;
  Timestamp timestamp = Timestamp.now();

  Future<void> initialize() async {
    try {
      final res =
          await ref.read(communityUsecaseProvider).getRecentUsers(communityId);
      final userIds = res.map((data) => data["userId"] as String).toList();
      await ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(userIds);
      final map = ref.read(allUsersNotifierProvider).asData!.value;
      timestamp = res[res.length - 1]["joinedAt"];
      state = AsyncValue.data(res
          .map(
              (data) => CommunityMember(data["joinedAt"], map[data["userId"]]!))
          .toList());
    } catch (e) {
      state = const AsyncValue.data([]);
    }
  }

  refresh() async {
    final res =
        await ref.read(communityUsecaseProvider).getRecentUsers(communityId);
    final userIds = res.map((data) => data["userId"] as String).toList();
    await ref.read(allUsersNotifierProvider.notifier).getUserAccounts(userIds);
    final map = ref.read(allUsersNotifierProvider).asData!.value;
    timestamp = res[res.length - 1]["joinedAt"];
    state = AsyncValue.data(res
        .map((data) => CommunityMember(data["joinedAt"], map[data["userId"]]!))
        .toList());
  }

  Future<bool> loadMore() async {
    DebugPrint("RES : $timestamp");
    final list = state.asData?.value ?? [];
    final res = await ref
        .read(communityUsecaseProvider)
        .getRecentUsers(communityId, timestamp: timestamp);
    if (res.isEmpty) return false;
    final userIds = res.map((data) => data["userId"] as String).toList();
    await ref.read(allUsersNotifierProvider.notifier).getUserAccounts(userIds);
    final map = ref.read(allUsersNotifierProvider).asData!.value;
    timestamp = res[res.length - 1]["joinedAt"];

    state = AsyncValue.data([
      ...list,
      ...res.map(
          (data) => CommunityMember(data["joinedAt"], map[data["userId"]]!))
    ]);
    return true;
  }
}
