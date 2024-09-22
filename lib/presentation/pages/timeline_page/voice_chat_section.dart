import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/dialogs/voice_chat_dialogs.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/chats/voice_chats_list.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class VoiceChatSection extends ConsumerWidget {
  const VoiceChatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(friendIdListNotifierProvider);
    final themeSize = ref.watch(themeSizeProvider(context));
    final listView = asyncValue.when(
      data: (friendIds) {
        final vcAsyncValue = ref.watch(voiceChatListNotifierProvider);
        return vcAsyncValue.when(
          data: (vcList) {
            if (vcList.isEmpty) return const SizedBox();
            /*   vcList = [
              VoiceChat(
                id: "id_01",
                createdAt: Timestamp.now(),
                endAt: Timestamp.now(),
                title: "title",
                joinedUsers: [
                  "vBBBlfPJaOaZKUjQIApcIwucIVB3",
                ],
                adminUsers: ["vBBBlfPJaOaZKUjQIApcIwucIVB3"],
                maxCount: 4,
              ),
              VoiceChat(
                id: "id_02",
                createdAt: Timestamp.now(),
                endAt: Timestamp.now(),
                title: "title",
                joinedUsers: [
                  "vBBBlfPJaOaZKUjQIApcIwucIVB3",
                  "AJNL9L1qGVhlDAmiqFaH7nikSOX2",
                ],
                adminUsers: ["vBBBlfPJaOaZKUjQIApcIwucIVB3"],
                maxCount: 4,
              ),
              VoiceChat(
                id: "id_03",
                createdAt: Timestamp.now(),
                endAt: Timestamp.now(),
                title: "title",
                joinedUsers: [
                  "vBBBlfPJaOaZKUjQIApcIwucIVB3",
                  "AJNL9L1qGVhlDAmiqFaH7nikSOX2",
                  "Bp9DWVP8PGXEZmcdx5LZrqL5apw2",
                  "vBBBlfPJaOaZKUjQIApcIwucIVB3",
                  "AJNL9L1qGVhlDAmiqFaH7nikSOX2",
                  "Bp9DWVP8PGXEZmcdx5LZrqL5apw2",
                  "vBBBlfPJaOaZKUjQIApcIwucIVB3",
                ],
                adminUsers: ["vBBBlfPJaOaZKUjQIApcIwucIVB3"],
                maxCount: 4,
              ),
            ]; */
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vcList.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final vc = vcList[index];
                    return _buildVoiceChatCard(context, ref, vc);
                  },
                ),
              ),
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return listView;
  }

  Widget _buildVoiceChatCard(
    BuildContext context,
    WidgetRef ref,
    VoiceChat vc,
  ) {
    const displayCount = 2;
    return FutureBuilder(
      future: ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(vc.joinedUsers),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          final users = snapshot.data!;
          List<Widget> stack = [];
          for (int i = 0; i < min(displayCount, users.length); i++) {
            stack.add(
              Positioned(
                left: i * 28,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: ThemeColor.accent,
                    ),
                  ),
                  child: UserIcon.circleIcon(users[i], radius: 18),
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              VoiceChatDialogs(context).showVoiceChatDialog(vc, users);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
                  const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: ThemeColor.accent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48 + (min(displayCount, users.length) - 1) * 28,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: stack,
                    ),
                  ),
                  (users.length > 2)
                      ? Text(
                          "+${users.length - displayCount}人が",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.phone_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                  const Text(
                    "通話中",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          );
          switch (vc.joinedUsers.length) {
            case 0:
              return const SizedBox();
            case 1:
              return _buildOneUserCard(context, ref, vc, users);
            case 2:
              return _buildTwoUserCard(context, ref, vc, users);
            case 3:
              return _buildFouruserCard(context, ref, vc, users);
            case 4:
            default:
              return _buildFouruserCard(context, ref, vc, users);
          }
        }
      },
    );
  }

  Widget _buildOneUserCard(BuildContext context, WidgetRef ref, VoiceChat vc,
      List<UserAccount> users) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        child: Center(
          child: UserIcon.circleIcon(users[0], radius: 32),
        ),
      ),
    );
  }

  Widget _buildTwoUserCard(BuildContext context, WidgetRef ref, VoiceChat vc,
      List<UserAccount> users) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: UserIcon.circleIcon(users[0], radius: 28),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: UserIcon.circleIcon(users[1], radius: 28),
          )
        ],
      ),
    );
  }

  Widget _buildFouruserCard(BuildContext context, WidgetRef ref, VoiceChat vc,
      List<UserAccount> users) {
    final users = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .entries
        .where((item) => vc.joinedUsers.contains(item.key))
        .map((item) => item.value);
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Wrap(
          children: users
              .map(
                (user) => Container(
                  padding: const EdgeInsets.all(2),
                  child: UserIcon.circleIcon(user),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  _joinButton(VoiceChat vc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.pink,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.phone_outlined,
            color: Colors.white,
            size: 18,
          ),
          Gap(4),
          Text(
            "通話中",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
