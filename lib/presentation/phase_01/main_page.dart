import 'dart:async';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/main.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/chat_screen/chat_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/timeline_page.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:app/presentation/phase_01/search_users_screen.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/bottom_nav.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class Phase01MainPage extends ConsumerStatefulWidget {
  const Phase01MainPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Phase01MainPageState();
}

class _Phase01MainPageState extends ConsumerState<Phase01MainPage>
    with WidgetsBindingObserver {
  MyAccountNotifier? _myAccountNotifier;

  @override
  void initState() {
    super.initState();

    _setupVoIPListener();
    configureVoiceCall(); // ここに追加
    WidgetsBinding.instance.addObserver(this);
    _myAccountNotifier = ref.read(myAccountNotifierProvider.notifier);
    _myAccountNotifier?.onOpen();
    initPlugin();
  }

  configureData() async {
    final users = await FirebaseFirestore.instance.collection("users").get();
    for (var user in users.docs) {
      final friends = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .collection("friends")
          .get();
      final friendIds = friends.docs.map((doc) => doc.id).toList();
      FirebaseFirestore.instance
          .collection("friends")
          .doc(user.id)
          .set({"data": friendIds});
    }
  }

  initPlugin() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  @override
  void dispose() {
    // refを使用する前に_myAccountNotifierがnullでないことを確認
    _myAccountNotifier?.onClosed();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _myAccountNotifier?.onOpen();
        break;
      case AppLifecycleState.paused:
        _myAccountNotifier?.onClosed();
        break;
      /* case AppLifecycleState.hidden:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break; 
        case AppLifecycleState.inactive:
        ref.read(myAccountNotifierProvider.notifier).onClosed();
        break; */
      case AppLifecycleState.detached:
        _myAccountNotifier?.onClosed();
        break;
      default:
        break;
    }
  }

  bool showed = false;
  List<String> _previousFriends = [];

  Future<void> showNewFriendDialog(UserAccount user) async {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    Timer timer = Timer(const Duration(milliseconds: 2400), () {
      Navigator.of(context).pop();
    });
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      barrierLabel: "CLOSE",
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOutCubic.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: ThemeColor.accent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  UserIcon(user: user),
                  Text(
                    user.name,
                    style: textStyle.w600(fontSize: 14),
                  ),
                  const Gap(16),
                  Text(
                    "とフレンドになりました!",
                    style: textStyle.w600(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ).then((value) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  // VoIP応答時の処理
  void _setupVoIPListener() {
    const platform = MethodChannel('com.blank.sns/voip');
    platform.setMethodCallHandler(
      (MethodCall call) async {
        if (call.method == "onVoIPReceived") {
          final Map<String, dynamic> args =
              Map<String, dynamic>.from(call.arguments);
          final id = args['extra']['id'] ?? "";
          final uuid = args['uuid'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VoiceChatScreen(
                id: id,
                uuid: uuid,
              ),
            ),
          );
          /* Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("voice chat screen"),
                      Text("$args"),
                      Gap(12),
                      GestureDetector(
                        onTap: () {
                          
                          final id = args['extra']['id'] ?? "";
                          final uuid = args['uuid'];
                          if (id.isEmpty) {
                            showMessage("SOME KIND OF ERROR");
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoiceChatScreen(
                                id: id,
                                uuid: uuid,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: ThemeColor.accent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: ThemeColor.stroke,
                              width: 0.4,
                            ),
                          ),
                          child: Text("JOIN"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ); */
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //return NativeInlinePage();
    ref.listen(friendIdsStreamNotifier, (prev, next) {
      next.whenData((friendInfos) {
        List<String> newFriends = friendInfos
            .where((friend) => !_previousFriends.any((prev) => prev == friend))
            .toList();
        if (newFriends.isNotEmpty && _previousFriends.isNotEmpty) {
          final user = ref
              .read(allUsersNotifierProvider)
              .asData!
              .value[newFriends.first]!;
          showNewFriendDialog(user);
        }
        _previousFriends = friendInfos;
      });
    });

    /* final fab = FloatingActionButton(
      heroTag: "edit_currentStatus",
      shape: const StadiumBorder(),
      onPressed: () {
        final me = ref.read(myAccountNotifierProvider).asData?.value;
        if (me != null) {
          navToEditCurrentStatus(context, ref, me);
        }
      },
      backgroundColor: ThemeColor.highlight,
      child: SizedBox(
        height: 22,
        width: 22,
        child: SvgPicture.asset(
          "assets/images/icons/edit.svg",
          // ignore: deprecated_member_use
          color: Colors.white,
        ),
      ),
    ); */

    final dmAsyncValue = ref.watch(dmOverviewListNotifierProvider);
    return Scaffold(
      extendBody: true,
      key: scaffoldKey,
      drawer: Drawer(
        width: 92,
        clipBehavior: Clip.none,
        backgroundColor: ThemeColor.accent,
        child: SafeArea(
          maintainBottomViewPadding: true,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              /*   Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      
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
                        splashColor: ThemeColor.accent,
                        highlightColor: ThemeColor.white.withOpacity(0.1),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToChat(user);
                              },
                              onLongPress: () {
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToChat(user);
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: UserIcon(
                                      user: user,
                                    ),
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
      body: Stack(
        children: [
          IndexedStack(
            index: ref.watch(bottomNavIndexProvider),
            children: const [
              //FollowingScreen(),
              //0
              TimelinePage(),
              //1
              //CommunityTabScreen(),
              SearchUsersScreen(),
              //2

              //3
              ChatScreen(),
              //4
              //ThreadsScreen(),
              //SearchScreen(),
              ProfileScreen(),
              //ThreadsScreen(),
              // PlaygroundScreen(),
              //PovScreen(),
              //InboxScreen(),
            ],
          ),
          const HeartAnimationArea(),
        ],
      ),
      bottomNavigationBar: ShaderWidget(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
          child: const BottomBar(),
        ),
      ),
      floatingActionButton: ref.watch(bottomNavIndexProvider) == 0
          ? FloatingActionButton(
              heroTag: "create_post",
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransitionMethods.slideUp(
                    const CreatePostScreen(),
                  ),
                );
              },
              backgroundColor: ThemeColor.highlight,
              child: const Icon(
                Icons.edit,
                color: ThemeColor.white,
                size: 30,
              ),
            )
          : null,
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      PageTransitionMethods.slideUp(
        const EditCurrentStatusScreen(),
      ),
    );
  }
}

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.white, // 選択されたアイテムの色を設定
      unselectedItemColor: ThemeColor.button.withOpacity(0.3), //
      selectedLabelStyle: textStyle.w600(fontSize: 11),
      unselectedLabelStyle: textStyle.w600(fontSize: 11),
      onTap: (value) {
        ref.watch(bottomNavIndexProvider.notifier).changeIndex(context, value);
      },
      currentIndex: ref.watch(bottomNavIndexProvider),
      items: [
        _bottomNavItem(context, ref, "ホーム", 0, "assets/images/icons/home.svg"),
        _bottomNavItem(
            context, ref, "探す", 1, "assets/images/icons/search_normal.svg"),
        //_bottomNavItem(context, ref, "投稿", 2, "assets/images/icons/send.svg"),
        _bottomNavItem(
            context, ref, "ソーシャル", 2, "assets/images/icons/chat.svg"),
        _bottomNavItem(
            context, ref, "プロフィール", 3, "assets/images/icons/profile.svg"),
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
                // ignore: deprecated_member_use
                color: index == ref.watch(bottomNavIndexProvider)
                    ? Colors.white
                    : ThemeColor.button.withOpacity(0.3),
              ),
            ),
          ),
          (() {
            switch (index) {
              case (2):
                final dms =
                    ref.watch(dmOverviewListNotifierProvider).asData?.value ??
                        [];
                bool flag = false;
                for (var dm in dms) {
                  final q = dm.userInfoList.where((item) =>
                      item.userId == ref.read(authProvider).currentUser!.uid);
                  if (q.isNotEmpty) {
                    final myInfo = q.first;
                    if (myInfo.lastOpenedAt.compareTo(dm.updatedAt) < 0) {
                      flag = true;
                    }
                  } else {
                    flag = true;
                  }
                }

                return Visibility(
                  visible: flag,
                  child: const Positioned(
                    top: 0, // 上部の位置を調整
                    right: 0, // 右側の位置を調整

                    child: CircleAvatar(
                      radius: 4, // サイズを小さくする
                      backgroundColor: Colors.blue,
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
