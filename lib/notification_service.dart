// lib/services/notification_service.dart
import 'dart:io';
import 'package:app/core/values.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // 通知チャンネルの定義
  static const AndroidNotificationChannel pushChannel =
      AndroidNotificationChannel(
    'push_notification_channel',
    '通常通知',
    description: 'アプリからの通知を表示します',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel callChannel =
      AndroidNotificationChannel(
    'call_notification_channel',
    '着信通知',
    description: '通話着信を通知します',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
  );

  // 初期化処理
  static Future<void> initialize() async {
    // iOSの権限要求
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    // Androidのチャンネル設定
    if (Platform.isAndroid) {
      await _setupAndroidChannels();
    }

    // 共通の初期化処理
    await _commonInitialization();
  }

  // iOS固有の権限要求
  static Future<void> _requestIOSPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // 着信通知用
      provisional: false,
    );

    // VoIP通知用の設定（着信用）
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
  }

  // Android固有のチャンネル設定
  static Future<void> _setupAndroidChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(pushChannel);
    await androidPlugin?.createNotificationChannel(callChannel);
  }

  // 共通の初期化処理
  static Future<void> _commonInitialization() async {
    // アプリ起動時の通知設定
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // 通知タップ時の処理設定
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);
  }

  // 通知タップ時の処理
  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    switch (type) {
      case 'call':
        // 着信画面に遷移
        break;
      case 'push':
        // 該当する画面に遷移
        break;
    }
  }

  // プッシュ通知の表示
  static Future<void> showPushNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    if (Platform.isAndroid) {
      await _showAndroidPushNotification(title, body, payload);
    } else if (Platform.isIOS) {
      await _showIOSPushNotification(title, body, payload);
    }
  }

  // 着信通知の表示
  static Future<void> showCallNotification({
    required String callerName,
    String? callerImage,
    required String callId,
  }) async {
    if (Platform.isAndroid) {
      await _showAndroidCallNotification(callerName, callerImage, callId);
    } else if (Platform.isIOS) {
      await _showIOSCallNotification(callerName, callerImage, callId);
    }
  }

  // Android用プッシュ通知
  static Future<void> _showAndroidPushNotification(
    String title,
    String body,
    Map<String, dynamic>? payload,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      pushChannel.id,
      pushChannel.name,
      channelDescription: pushChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload?.toString(),
    );
  }

  // iOS用プッシュ通知
  static Future<void> _showIOSPushNotification(
    String title,
    String body,
    Map<String, dynamic>? payload,
  ) async {
    /*final iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ); */

    await _localNotifications.show(
      0,
      title,
      body,
      null,
      // NotificationDetails(iOS: iosDetails),
      payload: payload?.toString(),
    );
  }

  // Android用着信通知
  static Future<void> _showAndroidCallNotification(
    String callerName,
    String? callerImage,
    String callId,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      callChannel.id,
      callChannel.name,
      channelDescription: callChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true, // 画面を起こす
      category: AndroidNotificationCategory.call,
    );

    await _localNotifications.show(
      1, // 着信は別IDを使用
      '着信',
      '$callerNameさんから着信があります',
      NotificationDetails(android: androidDetails),
      payload: {'type': 'call', 'callId': callId}.toString(),
    );
  }

  // iOS用着信通知
  static Future<void> _showIOSCallNotification(
    String callerName,
    String? callerImage,
    String callId,
  ) async {
    // iOSはCallKitを使用
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'アプリ名',
      avatar: callerImage,
      type: 0,
      duration: 30000,
      textAccept: '応答',
      textDecline: '拒否',
      missedCallNotification: const NotificationParams(
        callbackText: "かけ直す",
        subtitle: "不在着信",
      ),
      ios: const IOSParams(
        iconName: 'CallKitIcon',
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
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static showIncomingCall(String name, String? imageUrl) async {
    final params = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: name,
      appName: appName,
      avatar: imageUrl,
      handle: '',
      type: 0,
      duration: 30000,
      textAccept: '応答',
      textDecline: '拒否',
      missedCallNotification: null,
      /* missedCallNotification: const NotificationParams(
        //showNotification: false,
        callbackText: "かけ直す",
        subtitle: "不在着信",

        //isShowCallback: false,
        //count: 1,
      ), */
      //extra: <String, dynamic>{'userId': '1a2b3c4d'},
      // headers: <String, dynamic>{'apiKey': 'Abc@123!'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        missedCallNotificationChannelName: "着信通知",
        incomingCallNotificationChannelName: "通話",
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#404040',
        actionColor: '#4CAF50',
        isImportant: true,
        isShowFullLockedScreen: false,
        isBot: false,
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
}
