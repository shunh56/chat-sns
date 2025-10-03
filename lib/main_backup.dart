// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/flavor.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/core/values.dart';
import 'package:app/data/datasource/hive/hive_boxes.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/firebase_options.dart';
import 'package:app/presentation/pages/main_page/error_page.dart';
import 'package:app/presentation/pages/main_page/loading_page.dart';
import 'package:app/presentation/pages/main_page/maintenance_screen.dart';
import 'package:app/presentation/pages/main_page/welcome_page.dart';
import 'package:app/presentation/services/notification_handler.dart';
import 'package:app/presentation/services/notification_service.dart';
import 'package:app/presentation/pages/account_status_screen/banned_screen.dart';
import 'package:app/presentation/pages/account_status_screen/deleted_screen.dart';
import 'package:app/presentation/pages/account_status_screen/freezed_screen.dart';
import 'package:app/presentation/pages/onboarding/onboarding_screen.dart';
import 'package:app/presentation/pages/onboarding/shared_preferences_provider.dart';
import 'package:app/presentation/pages/onboaring_account/onboarding_screen.dart';
import 'package:app/presentation/pages/version/update_notifier.dart';
import 'package:app/presentation/pages/version/version_manager.dart';
import 'package:app/presentation/pages/main_page/main_page.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_remote_config.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  HapticFeedback.vibrate();
  await NotificationHandler.handleBackgroundMessage(message);
  /*final data = message.data;
  if (data['type'] == "call") {
    final name = data["name"] ?? "name";
    final imageUrl = data['imageUrl'];
    final dateTime = DateTime.parse(data['dateTime']);
    if (DateTime.now().difference(dateTime).inSeconds.abs() < 5) {
      NotificationService.showIncomingCall(name, imageUrl);
    }
  }
  */
}

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  final container = ProviderContainer();
  final handler = container.read(notificationHandlerProvider);
  await handler.handleForegroundMessage(message);
  /* final data = message.data;
  final type = data['type'];
  showMessage("data : $data"); */
  //アプリ内widgetとして通知を表示する
  /*switch (type) {
    case 'call':
      await NotificationService.showCallNotification(
        callerName: data['name'] ?? 'Unknown',
        callerImage: data['imageUrl'],
        callId: data['callId'],
      );
      break;
    default:
      await NotificationService.showPushNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: data,
      );
  } */
}

void configureSystem() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      //android
      statusBarColor: ThemeColor.background,
      statusBarIconBrightness: Brightness.dark, // => black text
      //ios
      statusBarBrightness: Brightness.dark, // black text
    ),
  ); // => appbartheme

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
  );
}

Future<void> initializeFirebaseApp() async {
  try {
    // 既に初期化されているかチェック
    final apps = Firebase.apps;
    if (apps.isNotEmpty) {
      DebugPrint('Firebase is already initialized');
      return;
    }

    await Firebase.initializeApp(
      name: Flavor.getEnv,
      options: DefaultFirebaseOptions.currentPlatform,
    );
    DebugPrint('Firebase initialized successfully');
  } catch (e, stack) {
    DebugPrint('Firebase initialization error: $e');
    DebugPrint(stack.toString());
  }
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
  runZonedGuarded<Future<void>>(
    () async {
      // initialize
      WidgetsFlutterBinding.ensureInitialized();
      await MobileAds.instance.initialize();

      //1. initialize system
      configureSystem();

      //2. initialize firebase
      await initializeFirebaseApp();

      //3. initialize Notification
      await NotificationService.initialize();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      FirebaseMessaging.onMessage.listen(
        _firebaseMessagingForegroundHandler,
      );
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      // 通知タップ時のハンドリング
      if (initialMessage != null) {
        // アプリ起動時に通知からの起動の場合
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // UIが構築された後に処理
          final container = ProviderContainer();
          final handler = container.read(notificationHandlerProvider);
          handler.handleNotificationTap(initialMessage);
        });
      }
      // 通知をタップしてアプリが開かれた場合のハンドリング
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final container = ProviderContainer();
        final handler = container.read(notificationHandlerProvider);
        handler.handleNotificationTap(message);
      });

      //4. configure local DB
      await Hive.initFlutter();
      final prefs = await SharedPreferences.getInstance();
      final internalVersionStr = prefs.getString('current_version') ?? "1.0.0";
      final lastVersion = AppVersion.parse(internalVersionStr);
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = AppVersion.parse(packageInfo.version);
      if (lastVersion < currentVersion) {
        await Hive.deleteBoxFromDisk('userAccount');
      }
      prefs.setString("current_version", packageInfo.version);
      HiveBoxes.registerAdapters();
      await HiveBoxes.openBoxes();
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      }

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance
            .recordFlutterError(errorDetails, fatal: true);
      };

      runApp(
        const ProviderScope(
          overrides: [
            // firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
          ],
          child: MyApp(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GlobalProviderRef.initialize(ref);
    final themeSize = ref.watch(themeSizeProvider(context));

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
      // theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
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
            statusBarBrightness: Brightness.dark, // black text
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
      home: const UpdateNotifier(
        child: SplashScreen(),
      ),
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
        final isUnderMaintenance = remoteConfig.getBool('isUnderMaintenance');
        if (isUnderMaintenance) {
          return const MaintenanceScreen();
        } else {
          return firebaseAuthStream.when(
            data: (user) {
              if (user == null) {
                return const WelcomePage();
              } else {
                final usernameAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.username);
                }));
                final accountStatusAsync =
                    ref.watch(myAccountNotifierProvider.select((userAccount) {
                  return userAccount.whenData((user) => user.accountStatus);
                }));
                return usernameAsync.when(
                  data: (username) {
                    if (username == "null") {
                      return const OnboardingScreen();
                    } else {
                      return accountStatusAsync.when(
                        data: (accountStatus) {
                          switch (accountStatus) {
                            case AccountStatus.banned:
                              return const BannedAccountScreen();
                            case AccountStatus.freezed:
                              return const FreezedAccountScreen();
                            case AccountStatus.deleted:
                              return const DeletedAccountScreen();
                            default:
                              return ref
                                  .watch(initialOnboardingStateProvider)
                                  .when(
                                    data: (onboardingState) {
                                      if (!onboardingState.isCompleted) {
                                        return const OnboardingFlowScreen();
                                      }
                                      return const MainPageWrapper();
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

waitEnough(int ms) async {
  const minimumVal = 600;
  if (ms < minimumVal) {
    await Future.delayed(Duration(milliseconds: minimumVal - ms));
  }
}
