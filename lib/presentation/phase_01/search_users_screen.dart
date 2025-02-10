import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/phase_01/search_params_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/following_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SearchUsersScreen extends ConsumerWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: SizedBox()),
            Text(
              "検索",
              style: textStyle.appbarText(japanese: true),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchParamsScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.search_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(newUsersNotifierProvider.notifier).refresh();
          ref.read(recentUsersNotifierProvider.notifier).refresh();
        },
        child: ListView(
          children: const [
            Gap(12),
            NewUsersSection(),
            Gap(24),
            //RecommendedUsersSection(),
            // Gap(24),
            RecentUsersSection(),
          ],
        ),
      ),
    );
    /*return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverAppBar(
              floating: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  Text(
                    "検索",
                    style: textStyle.appbarText(japanese: true),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SearchParamsScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.search_outlined,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecentUsersScreen(),
                              ),
                            );
                          },
                          splashColor: Colors.white.withOpacity(0.05),
                          highlightColor: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ThemeColor.accent,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.green,
                                    ),
                                    const Gap(6),
                                    Text(
                                      "オンライン",
                                      style: textStyle.w600(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(6),
                                Text(
                                  "アクティブなユーザー",
                                  style: textStyle.w400(
                                    fontSize: 12,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                                const Gap(12),
                                onlineUsersAsyncValue.maybeWhen(
                                  data: (users) {
                                    return UserStackIcons(
                                      imageRadius: 16,
                                      users: users,
                                      strokeColor: ThemeColor.accent,
                                    );
                                  },
                                  orElse: () {
                                    return const EmptyUserStackIcons(
                                      imageRadius: 16,
                                      strokeColor: ThemeColor.accent,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewUsersScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: ThemeColor.accent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    color: ThemeColor.text,
                                    size: 18,
                                  ),
                                  const Gap(6),
                                  Text(
                                    "今日の活動",
                                    style: textStyle.w600(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(6),
                              Text(
                                "新規ユーザー",
                                style: textStyle.w400(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                              const Gap(12),
                              newUsersAsyncValue.maybeWhen(
                                data: (users) {
                                  return UserStackIcons(
                                    imageRadius: 16,
                                    users: users,
                                    strokeColor: ThemeColor.accent,
                                  );
                                },
                                orElse: () {
                                  return const EmptyUserStackIcons(
                                    imageRadius: 16,
                                    strokeColor: ThemeColor.accent,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: friendsFriendListView(context, ref),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
   */
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

class NewUsersSection extends ConsumerWidget {
  const NewUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);
    return UsersSection(
      title: "最近始めたユーザー",
      onSectionTapped: () {},
      asyncValue: newUsersAsyncValue,
    );
  }
}

class RecentUsersSection extends ConsumerWidget {
  const RecentUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineUsersAsyncValue = ref.watch(recentUsersNotifierProvider);
    return UsersSection(
      title: "最近アクティブのユーザー",
      onSectionTapped: () {},
      asyncValue: onlineUsersAsyncValue,
    );
  }
}

class UsersSection extends ConsumerWidget {
  const UsersSection({
    super.key,
    required this.title,
    required this.onSectionTapped,
    required this.asyncValue,
  });

  final String title;
  final VoidCallback onSectionTapped;
  final AsyncValue<List<UserAccount>> asyncValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textStyle.w600(fontSize: 16),
              ),
              GestureDetector(
                onTap: onSectionTapped,
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeColor.icon,
                  size: 18,
                ),
              )
            ],
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 180,
          child: asyncValue.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    'ユーザーが見つかりません',
                    style: textStyle.w400(fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  if (user.userId == ref.read(authProvider).currentUser!.uid) {
                    return const SizedBox();
                  }
                  return _userTile(context, user, ref, textStyle);
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: ThemeColor.error),
                  const Gap(8),
                  Text(
                    'エラーが発生しました\n${error.toString()}',
                    textAlign: TextAlign.center,
                    style: textStyle.w400(
                      fontSize: 12,
                      color: ThemeColor.error,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userTile(
    BuildContext context,
    UserAccount user,
    WidgetRef ref,
    ThemeTextStyle textStyle,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 160,
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(12),
            CachedImage.userIcon(user.imageUrl, user.name, 32),
            const Gap(8),
            Text(
              user.name,
              style: textStyle.w600(fontSize: 16),
            ),
            const Gap(12),
            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserAccount user) {
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);
        ref.watch(followingListNotifierProvider);
        final notifier = ref.read(followingListNotifierProvider.notifier);
        final isFollowing = notifier.isFollowing(user.userId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isFollowing ? Colors.blue : ThemeColor.white,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: () {
                if (!isFollowing) {
                  notifier.followUser(user);
                } else {
                  notifier.unfollowUser(user);
                }
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 96,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    !isFollowing ? 'フォロー' : 'フォロー中',
                    style: textStyle.w500(
                      fontSize: 12,
                      color: isFollowing
                          ? ThemeColor.white
                          : ThemeColor.background,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
