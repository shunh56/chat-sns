import 'dart:async';

import 'package:app/core/analytics/screen_name.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/popup/popup_handler.dart';
import 'package:app/presentation/pages/_new/discovery_screen.dart';
import 'package:app/presentation/pages/chat/sub_pages/create_chat_screen.dart';
import 'package:app/presentation/pages/main_page/drawer.dart';
import 'package:app/presentation/pages/main_page/heart_animation_overlay.dart';
import 'package:app/presentation/providers/chats/dm_flag_provider.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/follow/followers_list_notifier.dart';
import 'package:app/presentation/providers/session_provider.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/chat/chat_screen.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/search/search_users_screen.dart';
import 'package:app/presentation/pages/posts/create/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/posts/timeline/timeline_page.dart';
import 'package:app/presentation/pages/voice_chat/voice_chat_screen.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/bottom_nav.dart';
import 'package:app/presentation/services/dm_banner.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

class MainPageWrapper extends ConsumerStatefulWidget {
  const MainPageWrapper({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MainPageWrapperState();
}

class _MainPageWrapperState extends ConsumerState<MainPageWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupVoIPListener();
    configureVoiceCall(); // ここに追加
    initPlugin();
    ref.read(myAccountNotifierProvider.notifier).onOpen();
    Future.delayed(const Duration(milliseconds: 500), () {
      final popupManager = ref.read(popupManagerProvider);
      popupManager.checkAndShowPopups(context);
    });
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(myAccountNotifierProvider.notifier).onOpen(); // オンライン状態に
        ref.read(sessionStateProvider.notifier).startSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        ref.read(myAccountNotifierProvider.notifier).onClosed(); // オフライン状態に
        ref.read(sessionStateProvider.notifier).endSession();
        break;
      default:
        break;
    }
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

  configureVoiceCall() async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      //print("callEvent: ${event?.body}");
      //print("eventType : ${event?.event}");
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          showMessage(
              "id(uuid) : ${event.body['id']}\ncallId : ${event.body['extra']['id']}");
          await FlutterCallkitIncoming.endCall(event.body['id']);
          await Future.delayed(const Duration(milliseconds: 30));
          // 通話画面への遷移
          if (navigatorKey.currentState != null) {
            // extra データから通話に必要な情報を取得
            final callId = event.body['extra']?['id'] as String?;
            final uuid = event.body['id'] as String?;
            if (callId != null) {
              /*navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => VoiceChatScreen(
                  id: callId,
                  uuid: uuid ?? '',
                ),
              ),
            ); */
            }
          }
          break;

        case Event.actionCallDecline:
          // TODO: declined an incoming call
          await FlutterCallkitIncoming.endCall(event.body['id']);
          break;
        case Event.actionCallEnded:
          // TODO: ended an incoming/outgoing call
          await FlutterCallkitIncoming.endCall(event.body['id']);
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          await FlutterCallkitIncoming.endCall(event.body['id']);
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      key: ref.watch(scaffoldKeyProvider),
      body: const MainPage(),
    );
  }
}

final mainPageProvidersKeeper = Provider<void>((ref) {
  // 重要なプロバイダーをキープ
  ref.watch(followingListNotifierProvider);
  ref.watch(followersListNotifierProvider);

  // プロバイダーが破棄されないよう明示的にキープする
  ref.keepAlive();

  return;
});

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionStateProvider.notifier).startSession();
        ref.read(mainPageProvidersKeeper);
      });
      return null;
    }, const []);
    return Scaffold(
      drawer: const MainPageDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: ref.watch(bottomNavIndexProvider),
            children: const [
              SearchUsersScreen(),
              TimelinePage(),
              ChatScreen(),
              ProfileScreen(),
              DiscoveryScreen(),
            ],
          ),
          const HeartAnimationArea(),
          const DMNotificationBanner(),
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
      floatingActionButton: (() {
        switch (ref.watch(bottomNavIndexProvider)) {
          case 1:
            return FloatingActionButton(
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
            );
          case 2:
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateChatsScreen(),
                  ),
                );
              },
              backgroundColor: ThemeColor.highlight,
              child: const Icon(
                Icons.comment_outlined,
                color: ThemeColor.white,
                size: 28,
              ),
            );
          default:
            null;
        }
      }()),
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
        _handleTabSelection(ref, value);
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
        BottomNavigationBarItem(
          label: "new",
          icon: Icon(Icons.new_label),
        ),
      ],
    );
  }

  void _handleTabSelection(WidgetRef ref, int value) {
    try {
      // セッション追跡の更新
      switch (value) {
        case 0:
          ref
              .read(sessionStateProvider.notifier)
              .trackScreenView(ScreenName.homePage.value);
          break;
        case 1:
          ref
              .read(sessionStateProvider.notifier)
              .trackScreenView(ScreenName.timelinePage.value);
          break;
        case 2:
          ref
              .read(sessionStateProvider.notifier)
              .trackScreenView(ScreenName.chatPage.value);
          break;
        case 3:
          ref
              .read(sessionStateProvider.notifier)
              .trackScreenView(ScreenName.profilePage.value);
          break;
      }
    } catch (e) {
      // エラーが発生した場合はログに記録
      DebugPrint("タブ選択処理でエラーが発生しました: $e");
    }
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
                return Visibility(
                  visible: ref.watch(dmFlagProvider),
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
