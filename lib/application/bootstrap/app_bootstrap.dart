import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../presentation/app/app.dart';
import '../../presentation/services/notification_handler.dart';
import 'app_initializer.dart';

/// アプリケーションのブートストラップ処理を管理
///
/// 初期化、依存性注入、エラーハンドリングを統括
class AppBootstrap {
  late final AppInitializer _initializer;
  late final ProviderContainer _container;

  AppBootstrap() {
    _initializer = AppInitializer();
    _container = ProviderContainer();
  }

  /// アプリケーションを起動
  Future<Widget> initialize() async {
    // Flutter バインディングの初期化
    WidgetsFlutterBinding.ensureInitialized();

    // 初期化処理の実行
    final result = await _initializer.initialize();

    if (!result.isSuccess) {
      // 初期化失敗時はエラー画面を返す
      return _buildInitializationErrorApp(result.error!, result.stackTrace!);
    }

    // メッセージングハンドラーの設定
    await _configureMessaging();

    // Analytics の設定
    await _configureAnalytics();

    // アプリケーションの構築
    return _buildApp();
  }

  /// Firebase Messagingのハンドラー設定
  Future<void> _configureMessaging() async {
    // バックグラウンドメッセージハンドラー
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // フォアグラウンドメッセージハンドラー
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);

    // 初回起動時のメッセージチェック
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _scheduleInitialMessageHandling(initialMessage);
    }

    // アプリ起動後のメッセージタップハンドリング
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Firebase Analyticsの設定
  Future<void> _configureAnalytics() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  /// アプリケーションウィジェットの構築
  Widget _buildApp() {
    return ProviderScope(
      parent: _container,
      child: const App(),
    );
  }

  /// 初期化エラー時のアプリケーション
  Widget _buildInitializationErrorApp(Object error, StackTrace stackTrace) {
    // Crashlyticsにエラーを報告
    FirebaseCrashlytics.instance.recordError(error, stackTrace);

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'アプリの起動に失敗しました',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('しばらくしてから再度お試しください'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // アプリを再起動
                  SystemNavigator.pop();
                },
                child: const Text('アプリを終了'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 初回メッセージの処理をスケジュール
  void _scheduleInitialMessageHandling(RemoteMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final handler = _container.read(notificationHandlerProvider);
      handler.handleNotificationTap(message);
    });
  }

  /// 通知タップのハンドリング
  void _handleNotificationTap(RemoteMessage message) {
    final handler = _container.read(notificationHandlerProvider);
    handler.handleNotificationTap(message);
  }

  /// Providerコンテナを取得（テスト用）
  @visibleForTesting
  ProviderContainer get container => _container;
}

/// バックグラウンドメッセージハンドラー
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  HapticFeedback.vibrate();
  await NotificationHandler.handleBackgroundMessage(message);
}

/// フォアグラウンドメッセージハンドラー
Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  // 一時的なコンテナを作成してハンドリング
  final container = ProviderContainer();
  final handler = container.read(notificationHandlerProvider);
  await handler.handleForegroundMessage(message);
  container.dispose();
}