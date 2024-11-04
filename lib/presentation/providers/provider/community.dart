import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
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
}
