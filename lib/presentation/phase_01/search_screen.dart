import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/phase_01/friend_request_screen.dart';
import 'package:app/presentation/phase_01/friends_friends_screen.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
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

    return Scaffold(
      body: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            centerTitle: false,
            title: const Text("友達"),
          ),
          Gap(4),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding - 4),
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
                return UserRequestWidget(user: user);
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
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];
    final deletes =
        ref.watch(deletesIdListNotifierProvider).asData?.value ?? [];

    return asyncValue.when(
      data: (list) {
        //リクエストが来ていないユーザー
        final users = list
            .where((user) => (!requesteds.contains(user.userId) &&
                !deletes.contains(user.userId)))
            .toList();
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
            users.isEmpty
                ? const Text("")
                : ListView.builder(
                    //padding: EdgeInsets.symmetric(horizontal: 12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return UserRequestWidget(user: user);
                    },
                  ),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}
