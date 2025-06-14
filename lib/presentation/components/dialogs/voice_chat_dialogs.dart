import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/voice_chat/voice_chat_screen.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class VoiceChatDialogs {
  final BuildContext context;
  VoiceChatDialogs(this.context);

  showVoiceChatDialog(VoiceChat vc, List<UserAccount> users) {
    const displayCount = 2;
    List<Widget> stack = [];
    for (int i = 0; i < min(displayCount, users.length); i++) {
      stack.add(
        Positioned(
          left: i * 28,
          child: UserIcon(
            user: users[i],
            r: 40,
          ),
        ),
      );
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: ThemeColor.accent,
            ),
            child: Consumer(builder: (context, ref, child) {
              final admin = vc.adminUsers.isNotEmpty
                  ? ref
                      .read(allUsersNotifierProvider)
                      .asData!
                      .value[vc.adminUsers.first]!
                  : ref
                      .read(allUsersNotifierProvider)
                      .asData!
                      .value[vc.joinedUsers.first]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.close,
                    color: ThemeColor.beige,
                  ),
                  const Gap(8),
                  Text(
                    vc.title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Wrap(
                    children: users
                        .map(
                          (user) => Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 8),
                            child: UserIcon(
                              user: user,
                              r: 48,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${admin.name}の通話",
                        style: const TextStyle(
                          color: ThemeColor.beige,
                        ),
                      ),
                      Text(
                        "${users.length}人が参加中",
                        style: const TextStyle(
                          color: ThemeColor.beige,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoiceChatScreen(id: vc.id),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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
                              "通話に参加する",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  showExitVoiceChatDialog(String id, Function function) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ThemeColor.accent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("ボイスチャットを退出してよろしいですか？"),
                const Gap(24),
                GestureDetector(
                  onTap: () async {
                    function();
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.pink,
                      ),
                      child: const Text(
                        "退出する",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
