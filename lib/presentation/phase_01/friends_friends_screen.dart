import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FriendsFriendsScreen extends ConsumerWidget {
  const FriendsFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(friendsFriendListNotifierProvider);
    final requests =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];

    final listView = asyncValue.when(
      data: (list) {
        final users =
            list.where((user) => !requesteds.contains(user.userId)).toList();
        if (users.isEmpty) {
          return const Center(
            child: Text("おすすめのユーザーはいません"),
          );
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            if (requests.contains(user.userId)) {
              return _buildRequestTile(context, ref, user);
            }
            return _buildTile(context, ref, user);
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "おすすめのユーザー",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: listView,
    );
  }

  _buildTile(BuildContext context, WidgetRef ref, UserAccount user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationRouterProvider(context)).goToProfile(user);
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
                                  .read(friendRequestIdListNotifierProvider
                                      .notifier)
                                  .sendFriendRequest(user);
                             
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Center(
                                child: Text(
                                  "リクエスト",
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
                                  .read(friendsFriendListNotifierProvider
                                      .notifier)
                                  .removeUser(user);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
  }

  _buildRequestTile(BuildContext context, WidgetRef ref, UserAccount user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationRouterProvider(context)).goToProfile(user);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white.withOpacity(0.1),
                    child: InkWell(
                      splashColor: Colors.black.withOpacity(0.3),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        ref
                            .read(friendRequestIdListNotifierProvider.notifier)
                            .cancelFriendRequest(user.userId);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Center(
                          child: Text(
                            "リクエストを取り消す",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
