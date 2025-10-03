import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/debug_print.dart';
import '../../core/utils/flavor.dart';
import '../../core/utils/theme.dart';
import '../../data/datasource/hive/hive_boxes.dart';
import '../../firebase_options.dart';
import '../../presentation/pages/version/version_manager.dart';
import '../../presentation/services/notification_service.dart';

/// アプリケーション初期化を管理するクラス
///
/// 各初期化処理を責務ごとに分離し、順序を明確に管理
class AppInitializer {
  /// アプリケーション全体の初期化を実行
  Future<InitializationResult> initialize() async {
    try {
      // Step 1: システム設定
      _configureSystemUI();

      // Step 2: Firebase初期化
      await _initializeFirebase();

      // Step 3: 広告SDK初期化
      await _initializeMobileAds();

      // Step 4: 通知サービス初期化
      await _initializeNotifications();

      // Step 5: ローカルストレージ初期化
      await _initializeLocalStorage();

      // Step 6: クラッシュレポート設定
      await _configureCrashlytics();

      return InitializationResult.success();
    } catch (error, stackTrace) {
      DebugPrint('Initialization failed: $error');
      return InitializationResult.failure(error, stackTrace);
    }
  }

  /// システムUIの設定
  void _configureSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ThemeColor.background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Firebase関連サービスの初期化
  Future<void> _initializeFirebase() async {
    // 既に初期化されているかチェック
    if (Firebase.apps.isNotEmpty) {
      DebugPrint('Firebase is already initialized');
      return;
    }

    await Firebase.initializeApp(
      name: Flavor.getEnv,
      options: DefaultFirebaseOptions.currentPlatform,
    );
    DebugPrint('Firebase initialized successfully');
  }

  /// モバイル広告SDKの初期化
  Future<void> _initializeMobileAds() async {
    await MobileAds.instance.initialize();
    DebugPrint('Mobile Ads initialized');
  }

  /// 通知サービスの初期化
  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    DebugPrint('Notification Service initialized');
  }

  /// ローカルストレージ（Hive）の初期化
  Future<void> _initializeLocalStorage() async {
    await Hive.initFlutter();

    // バージョン管理とマイグレーション
    await _handleVersionMigration();

    // Hiveアダプターとボックスの登録
    HiveBoxes.registerAdapters();
    await HiveBoxes.openBoxes();
    DebugPrint('Local storage initialized');
  }

  /// バージョンマイグレーション処理
  Future<void> _handleVersionMigration() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVersionStr = prefs.getString('current_version') ?? "1.0.0";
    final lastVersion = AppVersion.parse(lastVersionStr);

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = AppVersion.parse(packageInfo.version);

    // バージョンアップ時のデータマイグレーション
    if (lastVersion < currentVersion) {
      await _migrateData(lastVersion, currentVersion);
    }

    await prefs.setString("current_version", packageInfo.version);
  }

  /// データマイグレーション処理
  Future<void> _migrateData(AppVersion from, AppVersion to) async {
    DebugPrint('Migrating data from $from to $to');

    // 特定のバージョンでユーザーアカウントデータをリセット
    if (from < AppVersion.parse("2.0.0")) {
      await Hive.deleteBoxFromDisk('userAccount');
    }

    // 今後のマイグレーション処理をここに追加
  }

  /// Crashlyticsの設定
  Future<void> _configureCrashlytics() async {
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
    DebugPrint('Crashlytics configured');
  }
}

/// 初期化処理の結果
class InitializationResult {
  final bool isSuccess;
  final Object? error;
  final StackTrace? stackTrace;

  InitializationResult._({
    required this.isSuccess,
    this.error,
    this.stackTrace,
  });

  factory InitializationResult.success() {
    return InitializationResult._(isSuccess: true);
  }

  factory InitializationResult.failure(Object error, StackTrace stackTrace) {
    return InitializationResult._(
      isSuccess: false,
      error: error,
      stackTrace: stackTrace,
    );
  }
}