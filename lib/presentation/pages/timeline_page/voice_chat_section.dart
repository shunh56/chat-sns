import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/dialogs/voice_chat_dialogs.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/chats/voice_chats_list.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceChatSection extends ConsumerWidget {
  const VoiceChatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(friendIdListNotifierProvider);
    //final themeSize = ref.watch(themeSizeProvider(context));
    final listView = asyncValue.when(
      data: (friendIds) {
        final vcAsyncValue = ref.watch(voiceChatListNotifierProvider);
        return vcAsyncValue.when(
          data: (vcList) {
            if (vcList.isEmpty) return const SizedBox();
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
                  child: UserIcon(
                    user: users[i],
                    width: 36,
                    isCircle: true,
                  ),
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
                border: Border.all(
                  color: ThemeColor.stroke,
                  width: 0.4,
                ),
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
        }
      },
    );
  }
}
