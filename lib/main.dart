// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/core/values.dart';
import 'package:app/firebase_options.dart';
import 'package:app/presentation/pages/auth/sign_in_select_provider_screen.dart';
import 'package:app/presentation/pages/auth/sign_up_select_provider_screen.dart';
import 'package:app/presentation/pages/auth/signin_page.dart';
import 'package:app/presentation/pages/onboarding_page/awaiting_screen.dart';
import 'package:app/presentation/pages/onboarding_page/input_invite_code_screen.dart';
import 'package:app/presentation/pages/onboarding_page/onboarding_page.dart';
import 'package:app/presentation/phase_01/main_page.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_remote_config.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
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

//メンテナンス画面の表示
Future<bool> maintenanceCheck() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(),
      minimumFetchInterval: Duration.zero,
    ),
  );
  return remoteConfig.getBool('isUnderMaintenance');
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
  const platform = MethodChannel('com.shunh.exampleApp/voip');
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
            size: 20,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            //android
            statusBarColor: ThemeColor.background,
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

    return remoteConfigAsync.when(
      data: (_) {
        final remoteConfig = ref.read(firebaseRemoteConfigProvider);
        if (remoteConfig.getBool('isUnderMaintenance')) {
          return const MaintenancePage();
        } else {
          final firebaseAuthStream = ref.watch(authChangeProvider);
          return firebaseAuthStream.when(
            data: (user) {
              if (user == null) {
                return const WelcomePage();
              } else {
                final usedCodeAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.usedCode);
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
                        final usernameAsync = ref.watch(
                            myAccountNotifierProvider.select((userAccount) {
                          return userAccount.whenData((user) => user.username);
                        }));
                        return usernameAsync.when(
                          data: (username) {
                            DebugPrint("username async");
                            if (username == "null") {
                              return const OnboardingScreen();
                            } else {
                              DebugPrint("phase 01");
                              return const Phase01MainPage();
                            }
                          },
                          loading: () => const LoadingPage(),
                          error: (e, _) => const ErrorPage(),
                        );
                    }
                  },
                  loading: () => const LoadingPage(),
                  error: (e, _) => const ErrorPage(),
                );
              }
            },
            loading: () => const LoadingPage(),
            error: (e, _) => const ErrorPage(),
          );
        }
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
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
    return Scaffold(
      body: Container(
        margin:
            EdgeInsets.symmetric(horizontal: themeSize.horizontalPaddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            Text(
              'LOGO',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: 80,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const Expanded(child: SizedBox()),
            Text(
              'Welcome to\n${appName}',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding,
              ),
              child: Material(
                color: ThemeColor.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUpSelectProviderScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: Container(
                        child: Text(
                          "登録",
                          textAlign: TextAlign.center,
                          style: textStyle.w600(
                            fontSize: 14,
                            color: ThemeColor.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding,
              ),
              child: Material(
                color: ThemeColor.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignInSelectProviderScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: Container(
                        child: Text(
                          "ログイン",
                          textAlign: TextAlign.center,
                          style: textStyle.w600(
                            fontSize: 14,
                            color: ThemeColor.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(kToolbarHeight),
          ],
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("SPLASH SCREEN"),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'An error occurred',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: ThemeColor.text,
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
