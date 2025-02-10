import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/phase_01/friend_request_screen.dart';
import 'package:app/presentation/phase_01/friends_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Scaffold(
      body: ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            centerTitle: false,
            title: Text(
              "友達",
              style: textStyle.appbarText(japanese: true),
            ),
          ),
          const Gap(4),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding - 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
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
                /*   GestureDetector(
                  onTap: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const userIdsScreen(),
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
                const Gap(8), */
                GestureDetector(
                  onTap: () {
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
          friendRequestedListView(context, ref),
          friendsFriendListView(context, ref),
        ],
      ),
    );
  }

  Widget friendRequestedListView(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final requestedIds = ref.watch(requestedIdsProvider);
    if (requestedIds.isEmpty) return const SizedBox();
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
        const Gap(12),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 100 + 8,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: requestedIds.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                itemBuilder: (context, index) {
                  final userId = requestedIds[index];
                  final user =
                      ref.read(allUsersNotifierProvider).asData!.value[userId]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(navigationRouterProvider(context))
                            .goToProfile(user);
                      },
                      child: UserIcon(user: user, width: 108),
                    ),
                  );
                },
              ),
            ),
            const Gap(12),
          ],
        ),
      ],
    );
  }

  Widget friendsFriendListView(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final friendIds = ref.watch(friendIdsProvider);
    final deletes =
        ref.watch(deletesIdListNotifierProvider).asData?.value ?? [];
    final requesteds = ref.watch(requestedIdsProvider);
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    final filters = deletes +
        requesteds +
        blocks +
        blockeds +
        friendIds +
        [ref.read(authProvider).currentUser!.uid];
    final asyncValue = ref.watch(maybeFriends);
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
        asyncValue.when(
          data: (ids) {
            final userIds =
                ids.where((userId) => !filters.contains(userId)).toList();
            final users = ref
                .read(allUsersNotifierProvider)
                .asData!
                .value
                .values
                .where((item) => userIds.contains(item.userId))
                .toList();
            //フレンドリクエストが来ているユーザーは消す
            users.removeWhere((user) => filters.contains(user.userId));
            if (users.isEmpty) {
              return SizedBox(
                height: themeSize.screenHeight * 0.1,
                child: Center(
                  child: Text(
                    "おすすめのユーザーはいません。",
                    style: textStyle.w600(
                      color: ThemeColor.subText,
                    ),
                  ),
                ),
              );
            }
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                users.isEmpty
                    ? const Text("")
                    : ListView.builder(
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
        ),
      ],
    );
  }


}
