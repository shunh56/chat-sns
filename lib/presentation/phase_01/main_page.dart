import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/chat_screen/chat_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/timeline_page/timeline_page.dart';
import 'package:app/presentation/phase_01/search_screen.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class Phase01MainPage extends ConsumerStatefulWidget {
  const Phase01MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Phase01MainPageState();
}

class _Phase01MainPageState extends ConsumerState<Phase01MainPage>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(myAccountNotifierProvider.notifier).onOpen();
        break;
      case AppLifecycleState.paused:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break;
      /* case AppLifecycleState.hidden:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break; 
        case AppLifecycleState.inactive:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break; */
      case AppLifecycleState.detached:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break;
      default:
        break;
    }
  }

  bool showed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(myAccountNotifierProvider.notifier).onOpen();
    ref.read(friendIdListNotifierProvider.notifier).initialize();
    ref.read(friendRequestIdListNotifierProvider.notifier).initialize();
    ref.read(friendRequestedIdListNotifierProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    /* 
 checkFriendsCurrentStatusPosts() {
      final asyncValue = ref.watch(friendsCurrentStatusPostsNotiferProvider);
      asyncValue.when(
        data: (posts) async {
          await Future.delayed(const Duration(milliseconds: 30));
          if (showed) return;
          showed = true;
          if (posts.isNotEmpty) {
            showModalBottomSheet(
              // ignore: use_build_context_synchronously
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              isDismissible: true,
              builder: (context) {
                return SizedBox(
                  height: 432,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.95),
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final user = ref
                          .read(allUsersNotifierProvider)
                          .asData!
                          .value[post.userId]!;

                      return CurrentStatusPostWidgets(context, ref, post, user)
                          .bottomSheet();
                    },
                  ),
                );
              },
            );
          }
        },
        error: (e, s) => {},
        loading: () => {},
      );
    }
    checkFriendsCurrentStatusPosts();
    */

    final asyncValue = ref.watch(myAccountNotifierProvider);
    final fab = asyncValue.when(
      data: (me) {
        return FloatingActionButton(
          shape: const StadiumBorder(),
          onPressed: () {
            navToEditCurrentStatus(context, ref, me);
          },
          backgroundColor: ThemeColor.highlight,
          child: SizedBox(
            height: 22,
            width: 22,
            child: SvgPicture.asset(
              "assets/images/icons/edit.svg",
              color: Colors.white,
            ),
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: ref.watch(bottomNavIndexProvider),
        children: const [
          TimelinePage(),
          ChatScreen(),
          //ThreadsScreen(),
          // PlaygroundScreen(),
          //SearchPage(),
          //PovScreen(),

          //InboxScreen(),
          Scaffold(),
          SearchScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ShaderWidget(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: const BottomBar(),
        ),
      ),
      floatingActionButton: ref.watch(bottomNavIndexProvider) == 0 ? fab : null,
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditCurrentStatusScreen(),
      ),
    );
  }

  /* _buildFriendsCurrentStatusPosts(WidgetRef ref) {
    final asyncValue = ref.watch(friendsCurrentStatusPostsNotiferProvider);
    return asyncValue.when(
      data: (posts) async {
        await Future.delayed(const Duration(milliseconds: 30));
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) {
            return Container(
              height: 240,
              color: Colors.black,
            );
          },
        );
        return Container(
          height: 240,
          color: Colors.black,
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  } */
}

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (value) {
        HapticFeedback.lightImpact();
        if (value == 2) {
          PostBottomModelSheet(context).openPostMenu();
        }
        ref.watch(bottomNavIndexProvider.notifier).changeIndex(context, value);
      },
      items: [
        _bottomNavItem(context, ref, "ホーム", 0, "assets/images/icons/home.svg"),
        _bottomNavItem(context, ref, "チャット", 1, "assets/images/icons/chat.svg"),
        _bottomNavItem(context, ref, "投稿", 2, "assets/images/icons/send.svg"),
        _bottomNavItem(
            context, ref, "友達", 3, "assets/images/icons/friends.svg"),
        _bottomNavItem(
            context, ref, "アカウント", 4, "assets/images/icons/profile.svg"),
      ],
    );
  }

  BottomNavigationBarItem _bottomNavItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    int index,
    String path,
  ) {
    return BottomNavigationBarItem(
      label: label,
      icon: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: SizedBox(
              height: 24,
              width: 24,
              child: SvgPicture.asset(
                path,
                color: index == ref.watch(bottomNavIndexProvider)
                    ? Colors.white
                    : ThemeColor.button.withOpacity(0.3),
              ),
            ),
          ),
          (() {
            switch (index) {
              case (3):
                return Visibility(
                  visible: (ref
                              .watch(friendRequestedIdListNotifierProvider)
                              .asData
                              ?.value ??
                          [])
                      .isNotEmpty,
                  child: Positioned(
                    top: 0, // 上部の位置を調整
                    right: 0, // 右側の位置を調整
                    child: CircleAvatar(
                      radius: 4, // サイズを小さくする
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
            }
            return const SizedBox();
          })(),
        ],
      ),
    );
  }
}
