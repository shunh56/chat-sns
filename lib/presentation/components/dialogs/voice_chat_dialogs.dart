import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:flutter/material.dart';
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
          child: UserIcon.circleIcon(users[i], radius: 20),
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
            child: Column(
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
                          child: UserIcon.circleIcon(user, radius: 24),
                        ),
                      )
                      .toList(),
                ),
                const Gap(4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${users.last.username}の通話",
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
            ),
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
