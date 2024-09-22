/*import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/providers/provider/free_chats/free_chats_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FreeChatScreen extends ConsumerWidget {
  const FreeChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int usersLength = 10 + Random().nextInt(20);
    final messages = ref.watch(freeChatMessagesListNotifierProvider);
    final listView = messages.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text(
              "静かだ。静かすぎる。。。",
              style: TextStyle(
                color: ThemeColor.highlight,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          reverse: true,
          itemBuilder: (context, index) {
            final message = list[index];
            final user = ref
                .read(allUsersNotifierProvider)
                .asData!
                .value[message.senderId]!;
            final hour = message.createdAt.toDate().hour;
            final min = message.createdAt.toDate().minute;
            final timeText =
                "${hour < 10 ? ("0$hour") : hour.toString()}:${min < 10 ? ("0$min") : min.toString()}";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                     gotoprofile
                    },
                    child: CachedImage.userIcon(user.imageUrl, user.username, 20),
                  ),
                  const Gap(6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ThemeColor.highlight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          message.text,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    final controller = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: 'freechat',
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColor.beige,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeColor.button,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "$usersLength Users",
                        style: const TextStyle(
                          color: ThemeColor.beige,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(child: listView),
                    const Gap(8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: ThemeColor.background,
                      ),
                      child: TextField(
                        controller: controller,
                        cursorColor: ThemeColor.highlight,
                        cursorHeight: 16,
                        maxLength: 28,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            ref
                                .read(freeChatMessagesListNotifierProvider
                                    .notifier)
                                .sendMessage(value);
                            controller.clear();
                          }
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: ThemeColor.highlight,
                            fontWeight: FontWeight.w400,
                          ),
                          hintText: "今なにしてる？",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */