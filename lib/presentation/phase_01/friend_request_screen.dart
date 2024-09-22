import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FriendRequestScreen extends ConsumerWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(friendRequestIdListNotifierProvider);
    final listView = asyncValue.when(
      data: (requestIds) {
        if (requestIds.isEmpty) {
          return const Center(
            child: Text("リクエスト済みのユーザーはいません。"),
          );
        }
        return ListView.builder(
          itemCount: requestIds.length,
          itemBuilder: (context, index) {
            String userId = requestIds[index];
            final user =
                ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColor.text,
                          ),
                        ),
                        const Gap(8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Colors.white.withOpacity(0.1),
                            child: InkWell(
                              splashColor: Colors.black.withOpacity(0.3),
                              highlightColor: Colors.transparent,
                              onTap: () {
                                ref
                                    .read(
                                        friendRequestIdListNotifierProvider
                                            .notifier)
                                    .cancelFriendRequest(userId);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Center(
                                  child: Text(
                                    "リクエストを取り消す",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
          "リクエスト済みユーザー",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: listView,
    );
  }
}
