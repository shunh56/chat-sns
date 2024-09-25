import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/phase_01/friend_request_screen.dart';
import 'package:app/presentation/phase_01/friends_friends_screen.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final requestIds =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    return Scaffold(
      body: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            centerTitle: false,
            title: const Text("友達"),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FriendsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      "友達",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FriendsFriendsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      "おすすめ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FriendRequestScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      "リクエスト済み",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(themeSize.verticalSpaceMedium),
          friendRequestedListView(ref),
          friendsFriendListView(ref),
        ],
      ),
    );
  }

  Widget friendRequestedListView(WidgetRef ref) {
    final asyncValue = ref.watch(friendRequestedIdListNotifierProvider);
    return asyncValue.when(
      data: (requestedIds) {
        if (requestedIds.isEmpty) {
          return const SizedBox();
        }
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Gap(12),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "フレンドリクエスト",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.text,
                ),
              ),
            ),
            const Gap(6),
            ListView.builder(
              //padding: EdgeInsets.symmetric(horizontal: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requestedIds.length,
              itemBuilder: (context, index) {
                final userId = requestedIds[index];
                final user =
                    ref.read(allUsersNotifierProvider).asData!.value[userId]!;
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
                                        splashColor:
                                            Colors.black.withOpacity(0.3),
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
                                        splashColor:
                                            Colors.black.withOpacity(0.3),
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
            ),
            const Gap(12),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }

  Widget friendsFriendListView(WidgetRef ref) {
    final asyncValue = ref.watch(friendsFriendListNotifierProvider);
    final requests =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];
    return asyncValue.when(
      data: (list) {
        final users =
            list.where((user) => !requesteds.contains(user.userId)).toList();
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Gap(12),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "知り合いかも",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.text,
                ),
              ),
            ),
            const Gap(6),
            ListView.builder(
              //padding: EdgeInsets.symmetric(horizontal: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                if (requests.contains(user.userId)) {
                  return _buildRequestTile(context, ref, user);
                }
                return _buildTile(context, ref, user);
              },
            ),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
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
