import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/comunity_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifiier, AsyncValue<Community?>>((ref) {
  return CommunityNotifiier(
    ref,
    ref.watch(communityUsecaseProvider),
  )..initialize();
});

/// State
class CommunityNotifiier extends StateNotifier<AsyncValue<Community?>> {
  CommunityNotifiier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId = "student_life";
  final CommunityUsecase usecase;

  Future<void> initialize() async {
    final res = await usecase.getCommunityFromId(communityId);
    state = AsyncValue.data(res);
  }
}

final communityMembersNotifierProvider = StateNotifierProvider<
    CommunityMembersNotifiier, AsyncValue<List<UserAccount>>>((ref) {
  return CommunityMembersNotifiier(
    ref,
    ref.watch(communityUsecaseProvider),
  )..initialize();
});

/// State
class CommunityMembersNotifiier
    extends StateNotifier<AsyncValue<List<UserAccount>>> {
  CommunityMembersNotifiier(
    this.ref,
    this.usecase,
  ) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId = "student_life";
  final CommunityUsecase usecase;

  Future<void> initialize() async {
    final userIds =
        await ref.read(communityUsecaseProvider).getRecentUsers(communityId);
    final users = await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(userIds);
    state = AsyncValue.data(users);
  }
}

final joinedCommunitiesProvider = StateNotifierProvider<
    JoinedCommunitiesNotifier, AsyncValue<List<Community>>>((ref) {
  return JoinedCommunitiesNotifier(ref);
});

class JoinedCommunitiesNotifier
    extends StateNotifier<AsyncValue<List<Community>>> {
  final Ref ref;

  JoinedCommunitiesNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final user = ref.read(authProvider).currentUser;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('joinedCommunities')
        .snapshots()
        .listen(
      (snapshot) async {
        try {
          final communityIds = snapshot.docs.map((doc) => doc.id).toList();
          if (communityIds.isEmpty) {
            state = const AsyncValue.data([]);
            return;
          }

          final communities = await Future.wait(
            communityIds.map((id) => FirebaseFirestore.instance
                .collection('communities')
                .doc(id)
                .get()
                .then((doc) => Community.fromJson(doc.data()!))),
          );

          state = AsyncValue.data(communities);
        } catch (error, stackTrace) {
          state = AsyncValue.error(error, stackTrace);
        }
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> refresh() async {
    _init();
  }

  Future<void> joinCommunity(Community community) async {
    String communityId = community.id;
    final user = ref.read(authProvider).currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // コミュニティのメンバーに追加
    final memberRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(user.uid);

    batch.set(memberRef, {
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // ユーザーの参加コミュニティに追加
    final userCommRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('joinedCommunities')
        .doc(communityId);

    batch.set(userCommRef, {
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // コミュニティのメンバー数を更新
    final commRef =
        FirebaseFirestore.instance.collection('communities').doc(communityId);

    batch.update(commRef, {
      'memberCount': FieldValue.increment(1),
    });

    try {
      await batch.commit();
      final list = List<Community>.from(state.asData?.value ?? []);
      list.add(community);
      state = AsyncValue.data(list);
      // コミュニティデータの更新を通知
      //ref.invalidate(communityNotifierProvider(communityId));
    } catch (e) {
      // エラーハンドリング
      throw Exception('コミュニティへの参加に失敗しました');
    }
  }

  Future<void> leaveCommunity(Community community) async {
    String communityId = community.id;
    final user = ref.read(authProvider).currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // コミュニティのメンバーから削除
    final memberRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .doc(user.uid);

    batch.delete(memberRef);

    // ユーザーの参加コミュニティから削除
    final userCommRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('joinedCommunities')
        .doc(communityId);

    batch.delete(userCommRef);

    // コミュニティのメンバー数を更新
    final commRef =
        FirebaseFirestore.instance.collection('communities').doc(communityId);

    batch.update(commRef, {
      'memberCount': FieldValue.increment(-1),
    });

    try {
      await batch.commit();
      final list = List<Community>.from(state.asData?.value ?? []);
      list.removeWhere((e) => e.id == community.id);
      state = AsyncValue.data(list);
      // コミュニティデータの更新を通知
      // ref.invalidate(communityNotifierProvider(communityId));
    } catch (e) {
      // エラーハンドリング
      throw Exception('コミュニティからの退会に失敗しました');
    }
  }
}
