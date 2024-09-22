import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UsersFriendsScreen extends ConsumerWidget {
  const UsersFriendsScreen(
      {super.key, required this.user, required this.friends});
  final UserAccount user;
  final List<UserAccount> friends;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final myFriendIds = friendInfos.map((item) => item.userId).toList();
    final listView = (friends.isEmpty)
        ? const Center(
            child: Text("フレンドはいません"),
          )
        : ListView.builder(
            itemCount: friends.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              String userId = friends[index].userId;
              final user =
                  ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(navigationRouterProvider(context)).goToProfile(user);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ThemeColor.accent,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(navigationRouterProvider(context))
                              .goToProfile(user);
                        },
                        child: UserIcon.tileIcon(user, width: 40),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(4),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.username,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: ThemeColor.text,
                                          height: 1.0),
                                    ),
                                    Text(
                                      "@${user.userId.substring(0, 12)}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const Expanded(child: SizedBox()),
                                if (myFriendIds.contains(user.userId))
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(
                                              navigationRouterProvider(context))
                                          .goToChat(user);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            ThemeColor.white.withOpacity(0.1),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(4),
                            Text(
                              user.aboutMe,
                              maxLines: 4,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "フレンド(${friends.length})",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: listView,
    );
  }
}
