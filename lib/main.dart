// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/core/values.dart';
import 'package:app/datasource/local/hive/friends_map.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/firebase_options.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/auth/signup_page.dart';
import 'package:app/presentation/pages/flows/onboarding/onboarding_screen.dart';
import 'package:app/presentation/pages/flows/onboarding/shared_preferences_provider.dart';
import 'package:app/presentation/pages/onboarding_page/awaiting_screen.dart';
import 'package:app/presentation/pages/onboarding_page/input_invite_code_screen.dart';
import 'package:app/presentation/pages/onboarding_page/onboarding_page.dart';
import 'package:app/presentation/phase_01/main_page.dart';
import 'package:app/presentation/providers/notifier/auth_notifier.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_remote_config.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

bool devMode = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  DebugPrint("Handling a background message: ${message.messageId}");
  //TODO 時差は命取りなので、送信時との時間差が5秒以内であれば鳴らす
  HapticFeedback.vibrate();
  final data = message.data;
  if (data['type'] == "call") {
    final name = data["name"] ?? "name";
    final imageUrl = data['imageUrl'];
    final dateTime = DateTime.parse(data['dateTime']);
    if (DateTime.now().difference(dateTime).inSeconds.abs() < 5) {
      showIncomingCall(name, imageUrl);
    }
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title  // description
  importance: Importance.max,
  enableVibration: true,
  playSound: true,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

configureSystem() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  /* SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      //android
      statusBarColor: ThemeColor.background,
      statusBarIconBrightness: Brightness.dark, // => black text
      //ios
      statusBarBrightness: Brightness.light, // black text
    ),
  ); */ // => appbartheme

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
  );
}

configureNotification() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    //TODO 数字の変更がうまくできないため、一旦なしにする
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  await messaging.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      debugPrint(
          '通知を検出: ${message.notification?.title} - ${message.notification?.body}');
      if (message.notification != null) {
        HapticFeedback.vibrate();
      }
      final data = message.data;
      if (data['type'] == "call") {
        final name = data["name"] ?? "name";
        final imageUrl = data['imageUrl'];
        final dateTime = DateTime.parse(data['dateTime']);
        if (DateTime.now().difference(dateTime).inSeconds.abs() < 5) {
          showIncomingCall(name, imageUrl);
        }
      }
    },
  );
  FirebaseMessaging.onMessageOpenedApp.listen(
    (message) {
      debugPrint(
          'アプリ起動中通知を検出: ${message.notification?.title} - ${message.notification?.body}');
      switch (message.data['action']) {
        case 'push_notification':
          break;
        default:
          break;
      }
    },
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

showIncomingCall(String name, String? imageUrl) async {
  final params = CallKitParams(
    id: const Uuid().v4(),
    nameCaller: name,
    appName: appName,
    // avatar: 'https://i.pravatar.cc/100',
    avatar: imageUrl,
    handle: '',
    type: 0,
    duration: 30000,
    textAccept: '応答',
    textDecline: '拒否',

    missedCallNotification: const NotificationParams(
      //showNotification: false,
      callbackText: "かけ直す",
      subtitle: "不在着信",
      //isShowCallback: false,
      //count: 1,
    ),
    //extra: <String, dynamic>{'userId': '1a2b3c4d'},
    // headers: <String, dynamic>{'apiKey': 'Abc@123!'},
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      missedCallNotificationChannelName: appName,
      incomingCallNotificationChannelName: appName,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#404040',
      // backgroundUrl: 'https://i.pravatar.cc/500',
      actionColor: '#4CAF50',
      isImportant: true,
      isShowFullLockedScreen: true,
    ),
    ios: const IOSParams(
      iconName: null, //'CallKitLogo',
      handleType: 'generic',
      supportsVideo: false,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
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
        // TODO: accepted an incoming call
        // TODO: show screen calling in Flutter
        // await FlutterCallkitIncoming.endCall(event.body['id']);
        await Future.delayed(const Duration(milliseconds: 30));
        //showMessage("action accepted, closing voip");
        /* navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text("VOICE CALL SCREEN"),
              ),
            ),
          ),
        ); */
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

/*configureSwiftMethodChannel() {
  const platform = MethodChannel('com.blank.sns/voip');
  platform.setMethodCallHandler(_handleVoIPCall);
}

Future<void> _handleVoIPCall(MethodCall call) async {
  if (call.method == 'onVoIPReceived') {
    final Map<String, dynamic> payloadData =
        Map<String, dynamic>.from(call.arguments);
    DebugPrint("voip method channel RECIEVED! : $payloadData");
    
  }
}
 */
void main() {
  DebugPrint("main()");
  runZonedGuarded<Future<void>>(
    () async {
      //1. initialize system
      configureSystem();

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      //2. initialize firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Hive.initFlutter();
      HiveBoxes.registerAdapters();
      await HiveBoxes.openBoxes();

      //3. initialize notification
      configureNotification();

      //methodChannelhandler
      //configureSwiftMethodChannel();

      if (kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      }

      if (kProfileMode || kReleaseMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance
            .recordFlutterError(errorDetails, fatal: true);
      };

      debugPrint("runApp");
      runApp(
        const ProviderScope(
          overrides: [
            // firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          ],
          child: MyApp(isUnderMaintenance: false //isUnderMaintenance,
              ),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}

class ScreenTracker extends StatefulWidget {
  final Widget child;
  final void Function(String screenName) onScreenDetected;

  const ScreenTracker({
    super.key,
    required this.child,
    required this.onScreenDetected,
  });

  @override
  State<ScreenTracker> createState() => _ScreenTrackerState();
}

class _ScreenTrackerState extends State<ScreenTracker> {
  Timer? _timer;
  String _currentScreenName = '';

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final context = this.context;
      if (!context.mounted) return;

      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null) {
        final screenName = currentRoute.settings.name ?? 'Unknown';
        if (screenName != _currentScreenName) {
          _currentScreenName = screenName;
          widget.onScreenDetected(screenName);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.isUnderMaintenance});
  final bool isUnderMaintenance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    //4. configure voice call
    configureVoiceCall();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
      ],
      locale: const Locale("ja", "JP"),
      title: appName,
      //theme: AppTheme().lightTheme,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          surfaceTintColor: Colors.transparent,
          toolbarHeight: themeSize.appbarHeight,
          backgroundColor: ThemeColor.background,
          titleSpacing: themeSize.horizontalPadding,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            color: ThemeColor.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: ThemeColor.text,
            size: 24,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            //android
            statusBarColor: Colors.transparent, // ThemeColor.background,
            statusBarIconBrightness: Brightness.dark, // => black text
            //ios
            statusBarBrightness: Brightness.light, // black text
          ),
        ),
        scaffoldBackgroundColor: ThemeColor.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: ThemeColor.beige,
          onPrimary: ThemeColor.text,
          secondary: ThemeColor.highlight,
          onSecondary: ThemeColor.background,
          error: Colors.red,
          onError: ThemeColor.white,
          surface: ThemeColor.button,
          onSurface: ThemeColor.beige,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(),
        ),

        //InkWellを含むSplashFactory全体の設定
        //splashFactory: InkRipple.splashFactory,

        // InkWellのデフォルト設定
        splashColor: Colors.white.withOpacity(0.05),
        highlightColor: Colors.white.withOpacity(0.05),
      ),
      debugShowCheckedModeBanner: false,
      home: isUnderMaintenance
          ? const Scaffold(
              body: Center(
                child: Text(
                  "Maintenance",
                ),
              ),
            )
          : const SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteConfigAsync = ref.watch(remoteConfigProvider);
    final firebaseAuthStream = ref.watch(authChangeProvider);

    return remoteConfigAsync.when(
      data: (remoteConfig) {
        if (remoteConfig.getBool('isUnderMaintenance')) {
          return const MaintenancePage();
        } else {
          return firebaseAuthStream.when(
            data: (user) {
              if (user == null) {
                return const WelcomePage();
              } else {
                final usedCodeAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.usedCode);
                }));
                final usernameAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.username);
                }));
                final accountStatusAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.accountStatus);
                }));
                return usedCodeAsync.when(
                  data: (usedCode) {
                    DebugPrint("usedCode async");
                    switch (usedCode) {
                      case null:
                        return const InputInviteCodeScreen();
                      case "WAITING":
                        return const AwaitingScreen();
                      default:
                        return usernameAsync.when(
                          data: (username) {
                            if (username == "null") {
                              return const OnboardingScreen();
                            } else {
                              return accountStatusAsync.when(
                                data: (accountStatus) {
                                  switch (accountStatus) {
                                    case AccountStatus.banned:
                                      return const Scaffold(
                                        body: Center(
                                          child: Text("BANNED"),
                                        ),
                                      );
                                    case AccountStatus.freezed:
                                      return const Scaffold(
                                        body: Center(
                                          child: Text("FREEZED"),
                                        ),
                                      );
                                    case AccountStatus.deleted:
                                      return const DeletedAccountScreen();
                                    default:
                                      return ref
                                          .watch(initialOnboardingStateProvider)
                                          .when(
                                            data: (onboardingState) {
                                              if (!onboardingState
                                                  .isCompleted) {
                                                return const OnboardingFlowScreen();
                                              }
                                              return const Phase01MainPage();
                                            },
                                            loading: () => const LoadingPage(),
                                            error: (e, s) =>
                                                ErrorPage(e: e, s: s),
                                          );
                                  }
                                },
                                loading: () => const LoadingPage(),
                                error: (e, s) => ErrorPage(e: e, s: s),
                              );
                            }
                          },
                          loading: () => const LoadingPage(),
                          error: (e, s) => ErrorPage(e: e, s: s),
                        );
                    }
                  },
                  loading: () => const LoadingPage(),
                  error: (e, s) => ErrorPage(e: e, s: s),
                );
              }
            },
            loading: () => const LoadingPage(),
            error: (e, s) => ErrorPage(e: e, s: s),
          );
        }
      },
      loading: () => const LoadingPage(),
      error: (e, s) => ErrorPage(e: e, s: s),
    );
  }
}

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Under Maintenance')),
    );
  }
}

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    const borderRadius = 100.0;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPaddingMedium),
            child: Column(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                SizedBox(
                  height: 72,
                  width: 72,
                  child: Image.asset(
                    'assets/images/icons/icon_circle_bg_white.png',
                  ),
                ),
                const Gap(18),
                Text(
                  '新しい友達作りは\nここから始まる',
                  textAlign: TextAlign.center,
                  style: textStyle.w900(
                    fontSize: 20,
                  ),
                ),
                const Gap(36),
                if (Platform.isIOS)
                  Padding(
                    padding: EdgeInsets.only(
                      left: themeSize.horizontalPadding,
                      right: themeSize.horizontalPadding,
                      bottom: 24,
                    ),
                    child: Material(
                      color: ThemeColor.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: InkWell(
                        onTap: () async {
                          await ref
                              .watch(authNotifierProvider)
                              .signInWithApple();
                        },
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: Image.asset(
                                      'assets/images/icons/apple.png',
                                      color: ThemeColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  "Appleでサインイン",
                                  textAlign: TextAlign.center,
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: ThemeColor.text,
                                  ),
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: themeSize.horizontalPadding,
                    right: themeSize.horizontalPadding,
                    bottom: 24,
                  ),
                  child: Material(
                    color: ThemeColor.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () async {
                        await ref
                            .watch(authNotifierProvider)
                            .signInWithGoogle();
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: Image.asset(
                                    'assets/images/icons/google.png',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "Googleでサインイン",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: themeSize.horizontalPadding,
                    right: themeSize.horizontalPadding,
                    bottom: 24,
                  ),
                  child: Material(
                    color: ThemeColor.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () async {
                        await ref
                            .watch(authNotifierProvider)
                            .signInWithTwitter();
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: Image.asset(
                                    Images.xIcon,
                                    color: ThemeColor.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "Xでサインイン",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(24),
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: ThemeColor.subText,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("または"),
                    ),
                    Expanded(
                      child: Divider(
                        color: ThemeColor.subText,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                  ),
                  child: Material(
                    color: ThemeColor.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Icon(
                                    Icons.mail_outline,
                                    color: ThemeColor.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "メールアドレスでログイン",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(48),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "ログインをすると、",
                        style: textStyle.w400(
                          fontSize: 10,
                          color: ThemeColor.subText,
                        ),
                      ),
                      TextSpan(
                        text: "利用規約とプライバシーポリシー",
                        style: const TextStyle(
                          color: ThemeColor.subText,
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                          decorationColor: ThemeColor.subText,
                          decorationThickness: 0.6,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showPolicyDialog(context, ref);
                          },
                      ),
                      TextSpan(
                        text: "に同意したものとみなされます。",
                        style: textStyle.w400(
                          fontSize: 10,
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(MediaQuery.of(context).viewPadding.bottom + 12),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: ref.watch(loginProcessProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Visibility(
              visible: ref.watch(loginProcessProvider),
              child: ShaderWidget(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showPolicyDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);
        return AlertDialog(
          elevation: 0,
          //backgroundColor: Colors.transparent,
          //insetPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: ThemeColor.stroke,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: const Icon(
                            Icons.gavel,
                            size: 24,
                            color: ThemeColor.text,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Center(
                        child: Text(
                          "利用規約",
                          textAlign: TextAlign.center,
                          style: textStyle.w600(fontSize: 18),
                        ),
                      ),
                      const Gap(32),
                      Text(
                        "サービス利用規約",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "本サービス利用規約（以下、「本規約」と称します）は、当社の様々なウェブサイト、API、メール通知、アプリケーション、ボタン、ウィジェット、広告、およびeコマースサービスなどの$appNameのサービス、ならびに本サービスにアップロード、ダウンロードまたは表示される情報、テキスト、リンク、グラフィック、写真、その他のコンテンツにアクセスし、利用する場合に適用されます。本サービスを利用することによって、ユーザーは本規約に拘束されることに同意したことになります。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "利用できる対象",
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "いかなる場合においても、本サービスを利用するためには13歳以上でなければならないものとします。また、本サービスを利用できるのは、$appNameと拘束力のある契約を締結することに同意し、法律によりサービスを受けることが禁止されていない者に限ります。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "プライバシーポリシー",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "本サービスのプライバシーポリシーは、$appNameをご使用いただく際に提供された情報の取り扱いについて説明しています。ユーザーは、本サービスを利用することによって、$appNameおよびその関係会社がこれら情報を保管、処理、使用するために、これら情報の収集および使用（プライバシーポリシーの定めに従って）に同意することを理解しているものとします。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "本サービス上のコンテンツ",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "ユーザーは、適用される法令や規則への遵守を含め、本サービスの利用および自身が提供する情報に対して責任を負います。提供されるコンテンツは、他のユーザーと共有して差し支えのないコンテンツに限定してください。"
                        "本サービスを介して投稿されたまたは本サービスを通じて取得したコンテンツなどの使用またはこれらへの依拠は、ユーザーの自己責任において行ってください。"
                        "当社は、本サービスを介して投稿されたいかなるコンテンツや通信内容についても、その完全性、真実性、正確性、もしくは信頼性を是認、支持、表明もしくは保証せず、また本サービスを介して表示されるいかなる意見についても、それらを是認するものではありません。"
                        "利用者は、本サービスの利用により、不快、有害、不正確あるいは不適切なコンテンツ、場合によっては、不当表示されている投稿またはその他欺瞞的な投稿に接する可能性があることを、理解しているものとします。"
                        "すべてのコンテンツは、その作成者が単独で責任を負うものとします。当社は、本サービスを介して投稿されるコンテンツを監視または管理することはできず、また、そのようなコンテンツについて責任を負うこともできません。"
                        "当社は、ユーザー契約に違反しているコンテンツ（著作権もしくは商標の侵害その他の知的財産の不正利用、詐欺、なりすまし、不法行為または嫌がらせ等）を削除する権利を留保します。"
                        "違反を報告または上申するための特定のポリシーおよびプロセスに関する情報は、本サービスのセーフティルールを参照してください。"
                        "ご自身のコンテンツが著作権を侵害されたと判断される場合は、違反報告をしていただくか、サポートセンターまで報告をお願いします。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "ユーザーの権利およびコンテンツに対する権利の許諾",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "ユーザーは、本サービス上にまたは本サービスを介して自ら送信または表示するコンテンツに対する権利を留保するものとします。ユーザーのコンテンツの所有権はユーザーにあります。"
                        "ユーザーは、本サービス上にまたは本サービスを介してコンテンツを送信または表示することによって、当社が、既知のものか今後開発されるものかを問わず、あらゆる媒体を介してのコンテンツを使用、コピー、複製、処理、改変、修正、公表、送信、表示するための、非独占的ライセンスを当社に対し無償で許諾することになります。"
                        "このライセンスによって、ユーザーは、当社や他のユーザーに対し、ご自身のを国内の他のユーザーからの閲覧を可能とすることを承認することになります。"
                        "ユーザーは、このライセンスには、$appNameが、コンテンツ利用に関する当社の条件に従うことを前提に、本サービスを提供、宣伝および向上させるための権利ならびに本サービスに対しまたは本サービスを介して送信されたコンテンツを他の媒体やサービスで配給、放送、配信、プロモーションまたは公表することを目的として、その他の企業、組織または個人に提供する権利が含まれていることに同意するものとします。"
                        "ユーザーは、$appNameがユーザーのコンテンツを投稿や表示をする際にコンテンツが修正または変更される可能性があること、およびコンテンツを異なるメディアに適合させるためにコンテンツに変更を加える可能性があることを理解しているものとします。"
                        "ユーザーは、ご自身が本サービス上でまたは本サービスを通じて送信または表示するコンテンツに関して、本規約で付与される権利を許諾するために必要な、すべての権利、ライセンス、同意、許可、権能および権限を有していることを表明し保証するものとします。"
                        "ユーザーは、ご自身が必要な許可を得ているまたはその他の理由により素材を投稿し$appNameに上記のライセンスを許諾することができる法的権限を有している場合を除き、当該コンテンツが著作権その他の財産権の対象となる素材を含むものではないことに同意するものとします。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "本サービスの改善と終了",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "$appNameは、サービスの向上を目指し、より便利なSNSアプリに改善していく上で、機能の追加や変更、削除をすることがあります。"
                        "ユーザーの権利や義務に重要な影響がないものに対しては事前通知を行わないことがあります。また、場合によっては本サービスを全面的に停止することもあります。"
                        "その場合、その旨を事前告知します。いかなる状況でもユーザーはアカウントを削除できます。"
                        "ただし、$platformOSプラットフォームなどのサードパーティーが運営している支払いアカウントを使用している場合は、そのプラットフォームを経由してアプリ内購入の管理を行ってください。"
                        "ユーザーが本規約に違反している場合、通知することなくユーザーのアカウントを削除することがあります。その場合、アプリ内購入に対しての払い戻しを受ける権利は消滅します。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "ユーザーに付与する権利",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "本サービスへのアクセスおよび利用に関し、個人的で、国内で利用可能な、著作権使用料無料、譲渡不可能、非独占的、取消し可能、サブライセンス権なしのライセンスをお客様に付与します。"
                        "このライセンスは、$appNameが意図して規約で許可した当サービスの利点をお客様に利用、享受していただくことのみを目的としています。"
                        "したがってお客様は以下の行為を行わないことに合意します：",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "・本サービスに含まれるすべてのコンテンツの商業目的での利用",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・いかなる著作権のある題材、画像、商標、商品名、サービスマーク、その他の知的財産やコンテンツもしくは占有情報の複写、修正、転送、その派生作品の作成、それらの利用または複製。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・すべてのロボット、ボット、スパイダー、クローラー、スクレイパー、サイト検索アプリ、プロキシ、または、本サービスやそのコンテンツのナビゲーション構造もしくは表示にアクセス、検索、索引付け、「データマインニング」もしくは何らかの複製や回避を行うためのその他手動か自動のデバイス、手法もしくはプロセス",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・本サービスまたは本サービスに接続するサーバーやネットワークを妨害、または悪影響をもたらす可能性のある方法での当サービスの利用。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・ウィルスやその他悪質なコードのアップロードまたは別の方法で本サービスのセキュリティを脅かす行為。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・何らかの目的で人を別のウェブサイトに誘導するためのサービスへの参照を含む別のデバイスの利用。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・弊社よる合意なく、本サービスまたは他のメンバーのコンテンツや情報と交流する第三者アプリケーションの利用や開発。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・弊社よる合意のない、アプリケーションのプログラミングインターフェースの使用、アクセスまたは公開。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・本サービスまたはシステムやネットワークの脆弱性の調査、精査または試験。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・本規約の違反に当たる行為の奨励または促進。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        "本サービスの不法または不正利用およびその双方に対応して、お客様のアカウント停止を含めあらゆる可能な法的措置を調査し講じる場合があります。"
                        "$appNameがお客様に提供するすべてのソフトウェアは、アップグレード、アップデートまたはその他新機能を自動的にダウンロードしインストールします。これら自動ダウンロードの設定は、ご自身のデバイスの設定画面から調整できます。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "ユーザーが$appNameに\n付与する権利",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "アカウントを作成することにより、ユーザーが本サービス上でもしくは他のメンバーへの転送時に投稿、アップロード、表示もしくは入手可能にする情報について、ユーザーは以下を$appNameに認めるものとします。"
                        "全地域を対象とし、移転可能、サブライセンス可能、ロイヤルティフリー、所有、保存、使用、コピー、表示、複製、翻案、編集、発行、変更、配布する権利およびライセンス。"
                        "お客様のコンテンツに関する$appNameのライセンスは非独占的とします。"
                        "ただし弊社サービスの利用において作成された派生的作品については$appNameが独占的なライセンスを所有します。"
                        "例えば弊社サービスのスクリーンショットにお客様のコンテンツが写り込んでいる場合は、$appNameが独占的ライセンスを所有します。"
                        "さらに他メンバーもしくは第三者がユーザーコンテンツを本サービスから流用し不当に使用する場合、ユーザーのコンテンツが$appName外で利用されることを防ぐため、弊社がお客様に代わって行動することをお客様は弊社に認めるものとします。"
                        "ユーザーコンテンツについて本サービス外で第三者が流用および使用する場合、ユーザーに代わって当局へ通知すること（ただし義務ではない）を明示的に含みます。"
                        "ユーザーコンテンツに関する$appNameのライセンス認可は、適用法（コンテンツがこれらの法律で定義されている個人情報を含む範囲で、個人情報保護関連法など）の下で認められるお客様の権利に従うものとします。"
                        "またライセンス認可の目的は本サービスの運営、開発、提供、および改善、さらに新サービスの研究開発に限定されます。ユーザーが発信するコンテンツ、またはユーザーが弊社に対しサービスで発信することを承認するコンテンツは他のメンバーが閲覧したり、サービスを訪問もしくは参加する人物が閲覧する可能性があることについて、ユーザーは同意するものとします。"
                        "アカウント作成時に提出したすべての情報が正確かつ真実であり、ユーザーには本サービスにコンテンツを投稿する権利があり、上述の通り$appNameに対しライセンスを付与することにユーザーは合意します。"
                        "本サービスの一環として、弊社がユーザーの公開したコンテンツを監視または審査する場合があることを理解し合意します。$appNameは独自の判断で、本規約に違反する、または本サービスの評判を害するコンテンツの一部または全部を削除することがあります。"
                        "弊社のサポートセンターとのやり取りの際は、ユーザーは礼儀をわきまえ丁寧に応対することに合意します。ユーザーの態度が常に脅迫的か攻撃的であると感じた場合、$appNameはお客様のアカウントを即時解約する権利を留保します。"
                        "$appNameがユーザーに本サービスの利用を許可する対価として、弊社および第三者パートナーが本サービスに広告を掲載できることにユーザーは合意します。"
                        "本サービスに関する提案やフィードバックを$appNameに提出することにより、弊社がユーザーに報酬を支払わず、あらゆる目的でこれらフィードバックを利用し共有する場合があることにユーザーは合意します。"
                        "法律で求められる場合や、ユーザーとの合意の遂行のため、もしくは当該アクセス、保管または開示によって以下に掲げる目的等の正当な利益を実現すると誠実に信じる場合、$appNameはアカウント情報やコンテンツへのアクセス、保管または開示を行うことがあることをご承知おきください"
                        ":(i) 法的手続きの遵守、(ii) 規約の実行、(iii) コンテンツが第三者の権利を侵害するとの申立てへの対応、(iv) 顧客サービスに関してお客様の依頼への対応、または、(v) 当社もしくはその他の者の権利、財産または個人的な安全性の保護。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(32),
                      Text(
                        "コミュニティガイドライン",
                        textAlign: TextAlign.center,
                        style: textStyle.w600(fontSize: 16),
                      ),
                      const Gap(12),
                      Text(
                        "本サービスを利用するユーザーは、以下の事項を行わないことを合意します。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                      const Gap(12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "・不法または本規約で禁じられた目的のための当サービスの利用。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・$appNameに損害を与えるようなサービスの使用",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・コミュニティ ガイドラインの違反",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・他のユーザーに対するスパムメールの送信、金銭の懇請または詐欺。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・なりすまし行為、または許可のない他者の画像の投稿。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・他人に対するいじめ、ストーカー行為、暴力、ハラスメント、虐待または中傷。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・個人の権利に違反または侵害するコンテンツの投稿（肖像権、プライバシー権、著作権、商標権またはその他知的財産権や契約上の権利を含む）。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・暴力を扇動するコンテンツ、またはヌードやどぎつい不要な暴力を含むコンテンツの投稿。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・商業や不法な目的での個人識別情報の要求、または許可なく他者の個人情報を流布すること。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                          Text(
                            "・他のアカウントの利用、他のアカウント共有、もしくは複数のアカウントの保持。",
                            style: textStyle.w400(fontSize: 10),
                          ),
                        ],
                      ),
                      Text(
                        "ユーザーが本サービスを誤用した場合や$appNameが不適切または不法と見なす行動をとった場合、$appNameは購入代金を返金せず、ユーザーのアカウントを調査または解約する権利を留保します。"
                        "このような行為またはコミュニケーションについては、本サービスの利用外で発生した場合であっても本サービスを通じて出会ったユーザーが関与する限り適用するものとします。",
                        style: textStyle.w400(fontSize: 10),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Text(
                          "閉じる",
                          style: textStyle.w600(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 72,
          width: 72,
          child: Image.asset(
            'assets/images/icons/icon_circle_bg_white.png',
          ),
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.e, required this.s});
  final Object e;
  final StackTrace s;
  @override
  Widget build(BuildContext context) {
    DebugPrint("error : $e, stacktrace: $s");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'エラーが発生しました。再起動してください',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: ThemeColor.text,
                    ),
              ),
              const Gap(12),
              Text(
                kDebugMode ? "error : $e\n stacktrace : $s" : "",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: ThemeColor.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeletedAccountScreen extends HookConsumerWidget {
  const DeletedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    // アニメーションコントローラー
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // フェードインアニメーション
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    // スケールアニメーション
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    // コンポーネントが表示されたときにアニメーションを開始
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Opacity(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アイコン
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 削除メッセージ
                  Text('アカウントが削除されています', style: textStyle.w600(fontSize: 20)),

                  const SizedBox(height: 12),

                  // 説明文
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'アカウントを再開するには以下のボタンをタップしてください',
                      textAlign: TextAlign.center,
                      style: textStyle.w600(
                        color: ThemeColor.subText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 再起動ボタン
                  Consumer(
                    builder: (context, ref, _) => FilledButton(
                      onPressed: () {
                        // アニメーション付きのフィードバック
                        HapticFeedback.mediumImpact();
                        ref
                            .read(myAccountNotifierProvider.notifier)
                            .rebootAccount();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ThemeColor.stroke,
                        foregroundColor: ThemeColor.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'アカウントを再開',
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // キャンセルボタン
                  TextButton(
                    onPressed: () {
                      ref.read(authNotifierProvider).signout();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    child: Text(
                      'キャンセル',
                      style: textStyle.w600(
                        fontSize: 14,
                        color: ThemeColor.subText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

waitEnough(int ms) async {
  const minimumVal = 600;
  if (ms < minimumVal) {
    await Future.delayed(Duration(milliseconds: minimumVal - ms));
  }
}
