import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FriendRequestedsScreen extends ConsumerWidget {
  const FriendRequestedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(friendRequestedIdListNotifierProvider);
    final listView = asyncValue.when(
      data: (userIds) {
        if (userIds.isEmpty) {
          return const Center(
            child: Text("フレンドリクエストはありません"),
          );
        }
        return ListView.builder(
          itemCount: userIds.length,
          itemBuilder: (context, index) {
            String userId = userIds[index];
            final user =
                ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    child: UserIcon.tileIcon(user),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(4),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.text,
                          ),
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Material(
                                  color: Colors.pink,
                                  child: InkWell(
                                    splashColor: Colors.black.withOpacity(0.3),
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      ref
                                          .read(
                                              friendRequestedIdListNotifierProvider
                                                  .notifier)
                                          .admitFriendRequested(userId);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: const Center(
                                        child: Text(
                                          "フレンドに追加",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Material(
                                  color: Colors.white.withOpacity(0.1),
                                  child: InkWell(
                                    splashColor: Colors.black.withOpacity(0.3),
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      ref
                                          .read(
                                              friendRequestedIdListNotifierProvider
                                                  .notifier)
                                          .deleteRequested(userId);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: const Center(
                                        child: Text(
                                          "削除",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "フレンドリクエスト",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: listView,
    );
  }
}
