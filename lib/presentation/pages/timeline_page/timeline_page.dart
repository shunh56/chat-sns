import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/subscription_bottomsheet.dart';
import 'package:app/presentation/components/core/sticky_tabbar.dart';
import 'package:app/presentation/pages/activies_screen/activities_screen.dart';
import 'package:app/presentation/pages/new_screen.dart';
import 'package:app/presentation/pages/timeline_page/threads/friends_posts.dart';
import 'package:app/presentation/pages/timeline_page/threads/public_posts.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/phase_01/main_page.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final visibleProvider = StateProvider((ref) => false);
final angleProvider = StateProvider((ref) => 0.0);
final sizeProvider = StateProvider((ref) => 50.0);
final xPosProvider = StateProvider((ref) => 0.0);
final yPosProvider = StateProvider((ref) => 0.0);
final color01Provider = StateProvider<Color>((ref) => Colors.pink);
final color02Provider = StateProvider<Color>((ref) => Colors.pink);

class TimelinePage extends ConsumerWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    /*   final chatIcon = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            DefaultTabController(
              length: 2,
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
                                      scaffoldKey.currentState?.openDrawer();
                                    },
                                    onDoubleTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NewScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      appName,
                                      style: textStyle.appbarText(),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  subscriptionLogo,
                                  Gap(12),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ActivitiesScreen(),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: ThemeColor.icon,
                                    ),
                                  ),
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
                            onTap: (val) {},
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
                              /* Tab(
                                child: Text(
                                  "知り合いかも",
                                  style: textStyle.tabText(),
                                ),
                              ), */
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
                      PublicPostsThread(),
                      //FriendFriendsPostsThread(),
                    ],
                  ),
                ),
              ),
            ),
            //heart animation
            const HeartAnimationArea(),
          ],
        ),
      ),
    );
  }
}

class HeartAnimationArea extends ConsumerWidget {
  const HeartAnimationArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DebugPrint("HEART ANIMATION");
    final visible = ref.watch(visibleProvider);
    final angle = ref.watch(angleProvider);
    final size = ref.watch(sizeProvider);
    final color_01 = ref.watch(color01Provider);
    final color_02 = ref.watch(color02Provider);
    //
    return AnimatedPositioned(
      duration: visible ? const Duration(milliseconds: 400) : Duration.zero,
      curve: Curves.easeInOutQuint,
      left: ref.watch(xPosProvider),
      top: ref.watch(yPosProvider),
      child: AnimatedOpacity(
        duration: visible ? const Duration(milliseconds: 400) : Duration.zero,
        opacity: visible ? 1.0 : 0.0,
        child: AnimatedRotation(
          turns: angle,
          curve: Curves.easeOut,
          duration: visible ? const Duration(milliseconds: 200) : Duration.zero,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color_01,
                  color_02,
                ],
              ).createShader(bounds);
            },
            child: Icon(
              size: size,
              Icons.favorite,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
