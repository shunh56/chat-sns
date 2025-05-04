// lib/providers/rooms_provider.dart
import 'dart:async';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/UNUSED/community_screen/model/room.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/tabs.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final roomProvider =
    StateNotifierProvider.family<RoomNotifier, AsyncValue<Room?>, String>(
  (ref, roomId) => RoomNotifier(ref, roomId),
);

class RoomNotifier extends StateNotifier<AsyncValue<Room?>> {
  final String roomId;
  final Ref ref;

  RoomNotifier(this.ref, this.roomId) : super(const AsyncValue.loading());

  Future<void> joinRoom(String userId) async {
    try {
      final batch = ref.read(firestoreProvider).batch();
      final roomRef =
          ref.read(firestoreProvider).collection('rooms').doc(roomId);

      batch.update(roomRef, {
        'currentParticipants': FieldValue.increment(1),
        'joinedUserIds': FieldValue.arrayUnion([userId]),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('ルームへの参加に失敗しました: $e');
    }
  }

  Future<void> leaveRoom(String userId) async {
    try {
      final batch = ref.read(firestoreProvider).batch();
      final roomRef =
          ref.read(firestoreProvider).collection('rooms').doc(roomId);

      batch.update(roomRef, {
        'currentParticipants': FieldValue.increment(-1),
        'joinedUserIds': FieldValue.arrayRemove([userId]),
        if (state.value?.userId == userId) 'isLive': false,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('ルームからの退出に失敗しました: $e');
    }
  }

  createRoom(Community community, String title, int maxParticipants) async {
    if (title.isEmpty) return;
    final room = Room(
      id: const Uuid().v4(),
      communityId: community.id,
      title: title,
      userId: ref.read(authProvider).currentUser!.uid,
      tags: [],
      currentParticipants: 1,
      maxParticipants: maxParticipants,
      isLive: true,
      joinedUserIds: [
        ref.read(authProvider).currentUser!.uid,
      ],
      createdAt: DateTime.now(),
    );
    await ref
        .watch(firestoreProvider)
        .collection("rooms")
        .doc(room.id)
        .set(room.toJson());
  }
}

final participantsStreamProvider = StreamProvider.family((ref, String roomId) {
  return ref
      .watch(firestoreProvider)
      .collection("rooms")
      .doc(roomId)
      .collection("participants")
      .snapshots();
});

// lib/screens/rooms/room_screen.dart
class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key, required this.room});
  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final participants = ref.watch(participantsStreamProvider(room.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          room.title,
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: Column(
        children: [
          RoomCard(room: room),
          Expanded(
            child: participants.when(
              data: (participants) {
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: participants.docs.length,
                  itemBuilder: (context, index) {
                    final participantData = participants.docs[index].data();
                    final userId = participantData["userId"] as String;

                    return FutureBuilder(
                      future: ref
                          .read(allUsersNotifierProvider.notifier)
                          .getUserAccounts([userId]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final user = snapshot.data![0];
                        return ListTile(
                          leading: UserIcon(user: user, width: 40),
                          title: Text(
                            user.name,
                            style: textStyle.w600(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.mic),
                        );
                      },
                    );
                  },
                );
              },
              error: (e, s) => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: ThemeColor.stroke,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic_off),
              ),
              IconButton(
                onPressed: () => _leaveRoom(context, ref),
                icon: const Icon(Icons.exit_to_app),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _leaveRoom(BuildContext context, WidgetRef ref) async {
    // 退室処理を実装
  }
}
