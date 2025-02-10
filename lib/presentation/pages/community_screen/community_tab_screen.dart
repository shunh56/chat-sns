import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/pages/community_screen/joined_communities_tab.dart';
import 'package:app/presentation/pages/community_screen/screens/create_community_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/new_communities_tab.dart';
import 'package:app/presentation/pages/community_screen/screens/popular_communities_tab.dart';
import 'package:app/presentation/pages/community_screen/screens/search_community_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CommunityTabScreen extends ConsumerWidget {
  const CommunityTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchCommunityScreen(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.1), // blue-gray-600
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'コミュニティを検索',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(12),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyTabBarDelegete(
                    TabBar(
                      isScrollable: true,
                      onTap: (val) {},
                      padding: const EdgeInsets.symmetric(horizontal: 8 - 4),
                      indicator: BoxDecoration(
                        color: ThemeColor.button,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      tabAlignment: TabAlignment.start,
                      indicatorPadding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        top: 5,
                        bottom: 7,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: ThemeColor.background,
                      unselectedLabelColor: Colors.white.withOpacity(0.3),
                      dividerColor: ThemeColor.background,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          return states.contains(WidgetState.focused)
                              ? null
                              : Colors.transparent;
                        },
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            children: [
                              Text(
                                "参加中",
                                style: textStyle.tabText(),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Text(
                            "人気",
                            style: textStyle.tabText(),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "新規",
                            style: textStyle.tabText(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [
                JoinedCommunitiesTab(),
                PopularCommunitiesTab(),
                NewCommunitiesTab(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCommunityScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.add_rounded,
            ),
          ),
        ),
      ),
    );
    /* return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverAppBar(
              floating: true,
              title: Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Text(
                    "コミュニティ",
                    style: textStyle.appbarText(japanese: true),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.search_outlined,
                          ),
                        )
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
                                builder: (_) => const OnlineUsersScreen(),
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

            // メインコンテンツ
            SliverToBoxAdapter(
              child: communityAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (community) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommunityCard(community: community),

                      const SizedBox(height: 24),

                      // 人気のトピック
                      const Text(
                        '人気のトピック',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TopicsList(topicsAsyncValue: topicsAsyncValue),

                      const SizedBox(height: 24),

                      // アクティブな通話室
                      /*  const Text(
                        'アクティブな通話室',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12), */
                      /*VoiceRoomsList(
                       voiceRoomsAsyncValue: voiceRoomsAsyncValue,
                          ), */
                    ],
                  ),
                ),
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
}
