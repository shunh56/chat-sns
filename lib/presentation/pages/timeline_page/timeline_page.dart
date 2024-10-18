import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/subscription_bottomsheet.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/pages/timeline_page/threads/friend_friends_post.dart';
import 'package:app/presentation/pages/timeline_page/threads/friends_posts.dart';
import 'package:app/presentation/pages/timeline_page/threads/public_posts.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DebugPrint("Timeline Screen");
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    /*   final chatIcon = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        HapticFeedback.lightImpact();
        _scaffoldKey.currentState?.openDrawer();
      },
      child: Container(
        child: Stack(
          children: [
            Container(
              height: 30,
              width: 30,
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                "assets/images/icons/chat.svg",
                color: ThemeColor.icon,
              ),
            ),
            if ((ref.watch(dmOverviewListNotifierProvider).asData?.value ?? [])
                .where((item) => item.isNotSeen)
                .isNotEmpty)
              const Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.cyan,
                ),
              )
          ],
        ),
      ),
    );
    final myIcon = asyncValue.when(
      data: (user) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
          child: CachedImage.userIcon(user.imageUrl, user.username, 18),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    ); */
    final subscriptionLogo = asyncValue.when(
      data: (user) {
        final subscription = user.subscriptionStatus;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            SubsctiptionBottomSheet(context).openBottomSheet();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: ThemeColor.beige,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                SubscriptionConverter.convertToString(subscription) ??
                    "アップグレード",
                style: textStyle.w600(
                  color: ThemeColor.headline,
                ),
              ),
            ),
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    final isHeartVisible = ref.watch(isHeartVisibleProvider);
    final dmAsyncValue = ref.watch(dmOverviewListNotifierProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: 80,
        clipBehavior: Clip.none,
        backgroundColor: ThemeColor.background,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              /*   Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(strokeWidth),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            canvasTheme.iconGradientStartColor,
                            canvasTheme.iconGradientEndColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          radius + padding + strokeWidth,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8 - strokeWidth),
                        decoration: BoxDecoration(
                          color: ThemeColor.background,
                          borderRadius: BorderRadius.circular(
                            radius + padding,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Container(
                            height: imageHeight,
                            width: imageHeight,
                            color: Colors.white.withOpacity(0.1),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/images/icons/chat.svg",
                                height: imageHeight * 2 / 3,
                                width: imageHeight * 2 / 3,
                                color: ThemeColor.icon,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
             */
              dmAsyncValue.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const SizedBox();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final overview = list[index];
                      final user = ref
                          .read(allUsersNotifierProvider)
                          .asData!
                          .value[overview.userId]!;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChattingScreen(userId: user.userId),
                            ),
                          );
                        },
                        splashColor: ThemeColor.accent,
                        highlightColor: ThemeColor.white.withOpacity(0.1),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToChat(user);
                              },
                              onLongPress: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToProfile(user);
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: UserIcon.tileIcon(user, width: 40),
                                  ),
                                  if (overview.isNotSeen)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.cyan,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                error: (e, s) => const SizedBox(),
                loading: () => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            DefaultTabController(
              length: 3,
              child: Scaffold(
                body: NestedScrollView(
                  controller: ref.watch(timelineScrollController),
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Container(
                              height: kToolbarHeight,
                              padding: EdgeInsets.symmetric(
                                horizontal: themeSize.horizontalPadding,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _scaffoldKey.currentState?.openDrawer();
                                    },
                                    child: Text(
                                     appName,
                                      style: textStyle.appbarText(),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  subscriptionLogo,
                                  /*
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const FootprintedsScreen(),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      size: 24,
                                      Icons.visibility_rounded,
                                      color: ThemeColor.icon,
                                    ),
                                  ),
                                  const Gap(12),
                                  chatIcon, */
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: StickyTabBarDelegete(
                          TabBar(
                            isScrollable: true,
                            onTap: (val) {
                              HapticFeedback.lightImpact();
                            },
                            padding: EdgeInsets.symmetric(
                                horizontal: themeSize.horizontalPadding - 4),
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
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: ThemeColor.background,
                            unselectedLabelColor: Colors.white.withOpacity(0.3),
                            dividerColor: ThemeColor.background,
                            splashFactory: NoSplash.splashFactory,
                            overlayColor:
                                WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                // Use the default focused overlay color
                                return states.contains(WidgetState.focused)
                                    ? null
                                    : Colors.transparent;
                              },
                            ),
                            tabs: [
                              Tab(
                                child: Text(
                                  "友達",
                                  style: textStyle.tabText(),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "知り合いかも",
                                  style: textStyle.tabText(),
                                ),
                              ),
                              Tab(
                                child: Row(
                                  children: [
                                    const Icon(
                                      size: 18,
                                      Icons.public_rounded,
                                    ),
                                    const Gap(4),
                                    Text(
                                      "公開",
                                      style: textStyle.tabText(),
                                    ),
                                  ],
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
                      FriendsPostsThread(),
                      FriendFriendsPostsThread(),
                      PublicPostsThread(),
                    ],
                  ),
                ),
              ),
            ),
            //heart animation
            AnimatedPositioned(
              duration: isHeartVisible
                  ? const Duration(milliseconds: 400)
                  : Duration.zero,
              curve: Curves.easeInOutQuint,
              left: ref.watch(xPosProvider),
              top: ref.watch(yPosProvider),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: isHeartVisible ? 1.0 : 0.0,
                child: AnimatedRotation(
                  turns: ref.watch(angleProvider),
                  duration: const Duration(milliseconds: 600),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: ref.watch(heartSizeProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
