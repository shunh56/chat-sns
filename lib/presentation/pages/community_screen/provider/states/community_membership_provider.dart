import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityMembershipProvider =
    StateNotifierProvider.family<CommunityMembershipNotifier, bool, String>(
        (ref, communityId) {
  return CommunityMembershipNotifier(ref, communityId);
});

class CommunityMembershipNotifier extends StateNotifier<bool> {
  final Ref ref;
  final String communityId;

  CommunityMembershipNotifier(this.ref, this.communityId) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final user = ref.read(authProvider).currentUser;
    if (user != null) {
      final isMember = await _checkMembership(user.uid);
      state = isMember;
    }
  }

  Future<bool> _checkMembership(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('joinedCommunities')
        .doc(communityId)
        .get();
    return doc.exists;
  }

  Future<void> joinCommunity() async {
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
      state = true;
      // コミュニティデータの更新を通知
      //ref.invalidate(communityNotifierProvider(communityId));
    } catch (e) {
      // エラーハンドリング
      throw Exception('コミュニティへの参加に失敗しました');
    }
  }

  Future<void> leaveCommunity() async {
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
      state = false;
      // コミュニティデータの更新を通知
      // ref.invalidate(communityNotifierProvider(communityId));
    } catch (e) {
      // エラーハンドリング
      throw Exception('コミュニティからの退会に失敗しました');
    }
  }
}
