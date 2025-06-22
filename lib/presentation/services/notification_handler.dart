// lib/services/notification_handler.dart
import 'dart:convert';
import 'package:app/core/utils/variables.dart';
import 'package:app/domain/entity/push_notification_model.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/providers/dm_notification_provider.dart';
import 'package:app/presentation/services/notification_service.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class GlobalProviderRef {
  static WidgetRef? _ref;

  static void initialize(WidgetRef ref) {
    _ref = ref;
  }

  static WidgetRef? get ref => _ref;
}

// プロバイダー定義
final notificationHandlerProvider = Provider((ref) => NotificationHandler(ref));

class NotificationHandler {
  final Ref ref;
  static const bool isDevMode = true;

  // 静的インスタンス
  static NotificationHandler? _instance;

  NotificationHandler(this.ref) {
    _instance = this;
  }
  // バックグラウンド通知用ハンドラー - グローバル関数として定義
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    HapticFeedback.vibrate();
    final data = message.data;
    final type = data['type'];

    DebugPrint('Background notification received: $data');

    // 通話通知の特別処理
    if (type == "call") {
      final name = data["name"] ?? "不明";
      final imageUrl = data['imageUrl'];
      final userId = data['userId'];
      final dateTime = data['dateTime'] != null
          ? DateTime.parse(data['dateTime'])
          : DateTime.now();

      // 最近の通知のみ処理（古い通知は無視）
      if (DateTime.now().difference(dateTime).inSeconds.abs() < 30) {
        // CallKit表示
        _showCallkitIncoming(name, imageUrl, userId);
      }
    }
  }

  // フォアグラウンド通知を処理するメソッド
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    DebugPrint('Foreground notification received: $data');

    // 通知を適切なタイプに変換
    final notification = _convertToNotificationModel(data);

    // 開発モードの場合、通知データを表示
    // DMの場合はトップ通知を表示、それ以外は開発モードモーダルを表示
    if (notification.type == PushNotificationType.dm) {
      // DMはトップバナーで表示
      _showDMBanner(notification);
    } else if (isDevMode && navigatorKey.currentState != null) {
      // DM以外は開発モードのボトムモーダルを表示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDevModeBottomModal(
            navigatorKey.currentContext!, notification, data);
      });
    }
    // タイプに基づいて処理を分岐
    switch (notification.type) {
      case PushNotificationType.call:
        await _handleCallNotification(notification);
        break;
      case PushNotificationType.dm:
        await _handleDmNotification(notification);
        break;
      case PushNotificationType.like:
        await _handleLikeNotification(notification);
        break;
      case PushNotificationType.comment:
        await _handleCommentNotification(notification);
        break;
      case PushNotificationType.follow:
        await _handleFollowNotification(notification);
        break;
      case PushNotificationType.friendRequest:
        await _handleFriendRequestNotification(notification);
        break;
      default:
        await _handleDefaultNotification(notification);
    }
  }

  // DMバナーをRiverpodで表示
  void _showDMBanner(PushNotificationModel notification) {
    if (GlobalProviderRef.ref != null) {
      GlobalProviderRef.ref!
          .read(dmNotificationProvider.notifier)
          .showNotification(notification);
    }
  }

  //TODO DMの通知バナーのみ対応しているので、投稿やフォローなどにも対応できるようにする。
  void _showPostReactionBanner(PushNotificationModel notification) {}

  // 通知タップ時の処理
  Future<void> handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    DebugPrint('Notification tapped: $data');

    // 通知を適切なタイプに変換
    final notification = _convertToNotificationModel(data);

    // DM以外は開発モードの場合、通知データを表示
    if (notification.type != PushNotificationType.dm &&
        isDevMode &&
        navigatorKey.currentState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDevModeBottomModal(
          navigatorKey.currentContext!,
          notification,
          data,
          isFromTap: true,
        );
      });
      // 開発モードでもタップの処理は続行させる
    }

    // タイプに基づいて画面遷移を分岐
    switch (notification.type) {
      case PushNotificationType.call:
        _navigateToCallScreen(notification);
        break;
      case PushNotificationType.dm:
        _navigateToChatScreen(notification);
        break;
      case PushNotificationType.like:
      case PushNotificationType.comment:
        _navigateToPostScreen(notification);
        break;
      case PushNotificationType.follow:
      case PushNotificationType.friendRequest:
        _navigateToProfileScreen(notification);
        break;
      default:
        // デフォルト（何もしない）
        break;
    }
  }

  // 開発モード用ボトムモーダル表示
  void _showDevModeBottomModal(BuildContext context,
      PushNotificationModel notification, Map<String, dynamic> rawData,
      {bool isFromTap = false}) {
/*    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final themeSize = ref.watch(themeSizeProvider(context));
          final textStyle = ThemeTextStyle(themeSize: themeSize);
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Text(
                        '🔔 開発モード: 通知データ',
                        style: textStyle.w600(fontSize: 18),
                      ),
                      Chip(
                        label: Text(
                          isFromTap ? '通知タップ時のイベント' : 'フォアグラウンド受信イベント',
                          style:
                              textStyle.w600(fontSize: 12, color: Colors.white),
                        ),
                        backgroundColor:
                            isFromTap ? Colors.orange : Colors.green,
                      ),
                      const Gap(16),
                      _buildSection(
                        '通知タイプ',
                        notification.type.toString().split('.').last,
                        textStyle,
                        color: _getTypeColor(notification.type),
                      ),
                      _buildSection(
                        '送信者情報',
                        '名前: ${notification.sender.name}\n'
                            'ID: ${notification.sender.userId}\n'
                            '画像URL: ${notification.sender.imageUrl}',
                        textStyle,
                      ),
                      _buildSection(
                        '通知内容',
                        'タイトル: ${notification.content.title}\n'
                            '本文: ${notification.content.body}',
                        textStyle,
                      ),
                      if (notification.payload != null)
                        _buildSection(
                          'ペイロード',
                          _formatPayload(notification.payload!),
                          textStyle,
                        ),
                      _buildSection(
                        'メタデータ',
                        '時刻: ${notification.metadata.timestamp}\n'
                            '優先度: ${notification.metadata.priority}\n'
                            'カテゴリ: ${notification.metadata.category ?? "なし"}',
                        textStyle,
                      ),
                      _buildSection(
                        '生データ (FCM)',
                        const JsonEncoder.withIndent('  ').convert(rawData),
                        textStyle,
                        isCode: true,
                      ),
                      const Gap(16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.button,
                            foregroundColor: ThemeColor.text,
                          ),
                          child: const Text('閉じる'),
                        ),
                      ),
                      const Gap(32),
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    ); */
  }

  // セクション表示用ウィジェット
  Widget _buildSection(String title, String content, ThemeTextStyle textStyle,
      {Color? color, bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '■ $title',
          style: textStyle.w600(
            fontSize: 14,
            color: color ?? ThemeColor.text,
          ),
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeColor.stroke.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isCode
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    content,
                    style: textStyle.w400(
                      fontSize: 12,
                      color: Colors.green.withOpacity(0.7),
                    ),
                  ),
                )
              : Text(
                  content,
                  style: textStyle.w400(fontSize: 12),
                ),
        ),
        const Gap(16),
      ],
    );
  }

  // 通知タイプに応じた色を取得
  Color _getTypeColor(PushNotificationType type) {
    switch (type) {
      case PushNotificationType.call:
        return Colors.red;
      case PushNotificationType.dm:
        return Colors.blue;
      case PushNotificationType.like:
        return Colors.pink;
      case PushNotificationType.comment:
        return Colors.purple;
      case PushNotificationType.follow:
        return Colors.green;
      case PushNotificationType.friendRequest:
        return Colors.orange;
      default:
        return ThemeColor.text;
    }
  }

  // ペイロードデータのフォーマット
  String _formatPayload(PushNotificationPayload payload) {
    final buffer = StringBuffer();

    if (payload.messageId != null) {
      buffer.writeln('メッセージID: ${payload.messageId}');
    }

    if (payload.text != null) buffer.writeln('テキスト: ${payload.text}');

    if (payload.chatId != null) buffer.writeln('チャットID: ${payload.chatId}');

    if (payload.postId != null) buffer.writeln('投稿ID: ${payload.postId}');

    if (payload.commentId != null) {
      buffer.writeln('コメントID: ${payload.commentId}');
    }

    if (payload.callId != null) buffer.writeln('通話ID: ${payload.callId}');

    if (payload.callType != null) buffer.writeln('通話タイプ: ${payload.callType}');

    return buffer.isEmpty ? 'ペイロードなし' : buffer.toString();
  }

  // 各通知タイプのハンドラー実装
  Future<void> _handleCallNotification(
      PushNotificationModel notification) async {
    final senderName = notification.sender.name;
    final senderImageUrl = notification.sender.imageUrl;
    final senderId = notification.sender.userId;

    // 通話画面をすぐに表示する代わりに、CallKitを表示
    _showCallkitIncoming(senderName, senderImageUrl, senderId);
  }

  Future<void> _handleDmNotification(PushNotificationModel notification) async {
    // インアプリ通知を表示
    NotificationService.showPushNotification(
      title: notification.content.title ?? notification.sender.name,
      body: notification.content.body ?? "新しいメッセージが届いています",
      payload: {
        'type': 'dm',
        'senderId': notification.sender.userId,
        'chatId': notification.payload?.chatId,
      },
    );
  }

  Future<void> _handleLikeNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content.title ?? notification.sender.name,
      body: notification.content.body ?? "あなたの投稿にいいねしました",
      payload: {
        'type': 'like',
        'senderId': notification.sender.userId,
        'postId': notification.payload?.postId,
      },
    );
  }

  Future<void> _handleCommentNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content.title ?? notification.sender.name,
      body: notification.content.body ?? "あなたの投稿にコメントしました",
      payload: {
        'type': 'comment',
        'senderId': notification.sender.userId,
        'postId': notification.payload?.postId,
        'commentId': notification.payload?.commentId,
      },
    );
  }

  Future<void> _handleFollowNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content.title ?? notification.sender.name,
      body: notification.content.body ?? "あなたをフォローしました",
      payload: {
        'type': 'follow',
        'senderId': notification.sender.userId,
      },
    );
  }

  Future<void> _handleFriendRequestNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content.title ?? notification.sender.name,
      body: notification.content.body ?? "フレンドリクエストが届きました",
      payload: {
        'type': 'friendRequest',
        'senderId': notification.sender.userId,
      },
    );
  }

  Future<void> _handleDefaultNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content.title ?? "新しい通知",
      body: notification.content.body ?? "",
      payload: {'type': 'default'},
    );
  }

  // 画面遷移メソッド
  void _navigateToCallScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;
    final callId = notification.payload?.callId;

    if (callId != null && navigatorKey.currentState != null) {
      /*navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => CallPage(
            userId: userId,
            callId: callId,
          ),
        ),
      ); */
      DebugPrint('通話画面への遷移: userId=$userId, callId=$callId');
    }
  }

  void _navigateToChatScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ChattingScreen(
            userId: userId,
          ),
        ),
      );
    }
  }

  void _navigateToPostScreen(PushNotificationModel notification) {
    final postId = notification.payload?.postId;

    if (postId != null && navigatorKey.currentState != null) {
      /* navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => PostDetailPage(
            postId: postId,
          ),
        ),
      ); */
      DebugPrint('投稿詳細画面への遷移: postId=$postId');
    }
  }

  void _navigateToProfileScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;

    if (navigatorKey.currentState != null) {
      /* navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userId: userId,
          ),
        ),
      ); */
      DebugPrint('プロフィール画面への遷移: userId=$userId');
    }
  }

  // データをPushNotificationModelに変換するヘルパーメソッド
  PushNotificationModel _convertToNotificationModel(Map<String, dynamic> data) {
    // 通知タイプを特定
    final typeStr = data['type'] as String? ?? 'default';
    final type = _getNotificationTypeFromString(typeStr);

    // 送信者情報
    final sender = PushNotificationSender(
      userId: data['userId'] ?? data['senderId'] ?? '',
      name: data['name'] ?? data['senderName'] ?? '',
      imageUrl: data['imageUrl'] ?? data['senderImageUrl'],
    );

    // 通知内容
    final content = PushNotificationContent(
      title: data['title'] ?? sender.name,
      body: data['text'] ?? '',
    );

    // ペイロード構築
    final payload = PushNotificationPayload(
      messageId: data['messageId'],
      text: data['text'],
      chatId: data['chatId'],
      postId: data['postId'],
      commentId: data['commentId'],
      callId: data['callId'],
      callType: data['callType'],
    );

    // メタデータ
    final metadata = PushNotificationMetadata(
      timestamp: data['dateTime'] != null
          ? DateTime.parse(data['dateTime'])
          : DateTime.now(),
      priority: data['priority'] ?? 'normal',
      category: data['category'],
    );

    return PushNotificationModel(
      type: type,
      sender: sender,
      content: content,
      payload: payload,
      metadata: metadata,
    );
  }

  // 文字列からPushNotificationTypeを取得するヘルパーメソッド
  PushNotificationType _getNotificationTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'call':
        return PushNotificationType.call;
      case 'dm':
        return PushNotificationType.dm;
      case 'like':
        return PushNotificationType.like;
      case 'comment':
        return PushNotificationType.comment;
      case 'follow':
        return PushNotificationType.follow;
      case 'friendRequest':
        return PushNotificationType.friendRequest;
      default:
        return PushNotificationType.defaultType;
    }
  }

  // CallKitを表示するヘルパーメソッド
  static Future<void> _showCallkitIncoming(
      String name, String? imageUrl, String? userId) async {
    final params = CallKitParams(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: name,
      appName: 'Blank',
      avatar: imageUrl,
      handle: '',
      type: 0, // 音声通話
      duration: 30000, // 30秒
      textAccept: '応答',
      textDecline: '拒否',
      //textMissedCall: '不在着信',
      //textCallback: 'コールバック',
      extra: <String, dynamic>{
        'userId': userId,
      },
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#333333',
        backgroundUrl: imageUrl,
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: false,
        maximumCallGroups: 1,
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


/*
// lib/services/notification_handler.dart
import 'package:app/core/utils/variables.dart';
import 'package:app/domain/entity/push_notification_model.dart';
import 'package:app/presentation/services/notification_service.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// プロバイダー定義
final notificationHandlerProvider = Provider((ref) => NotificationHandler(ref));

class NotificationHandler {
  final Ref ref;

  NotificationHandler(this.ref);

  // バックグラウンド通知用ハンドラー - グローバル関数として定義
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    HapticFeedback.vibrate();
    final data = message.data;
    final type = data['type'];

    DebugPrint('Background notification received: $data');

    // 通話通知の特別処理
    if (type == "call") {
      final name = data["name"] ?? "不明";
      final imageUrl = data['imageUrl'];
      final userId = data['userId'];
      final dateTime = data['dateTime'] != null
          ? DateTime.parse(data['dateTime'])
          : DateTime.now();

      // 最近の通知のみ処理（古い通知は無視）
      if (DateTime.now().difference(dateTime).inSeconds.abs() < 30) {
        // CallKit表示
        _showCallkitIncoming(name, imageUrl, userId);
      }
    }
  }

  // フォアグラウンド通知を処理するメソッド
  Future<void> handleForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    DebugPrint('Foreground notification received: $data');

    // 通知を適切なタイプに変換
    final notification = _convertToNotificationModel(data);

    // タイプに基づいて処理を分岐
    switch (notification.type) {
      case PushNotificationType.call:
        await _handleCallNotification(notification);
        break;
      case PushNotificationType.dm:
        await _handleDmNotification(notification);
        break;
      case PushNotificationType.like:
        await _handleLikeNotification(notification);
        break;
      case PushNotificationType.comment:
        await _handleCommentNotification(notification);
        break;
      case PushNotificationType.follow:
        await _handleFollowNotification(notification);
        break;
      case PushNotificationType.friendRequest:
        await _handleFriendRequestNotification(notification);
        break;
      default:
        await _handleDefaultNotification(notification);
    }
  }

  // 通知タップ時の処理
  Future<void> handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    DebugPrint('Notification tapped: $data');

    // 通知を適切なタイプに変換
    final notification = _convertToNotificationModel(data);

    // タイプに基づいて画面遷移を分岐
    switch (notification.type) {
      case PushNotificationType.call:
        _navigateToCallScreen(notification);
        break;
      case PushNotificationType.dm:
        _navigateToChatScreen(notification);
        break;
      case PushNotificationType.like:
      case PushNotificationType.comment:
        _navigateToPostScreen(notification);
        break;
      case PushNotificationType.follow:
      case PushNotificationType.friendRequest:
        _navigateToProfileScreen(notification);
        break;
      default:
        // デフォルト（何もしない）
        break;
    }
  }

  // 各通知タイプのハンドラー実装
  Future<void> _handleCallNotification(
      PushNotificationModel notification) async {
    final senderName = notification.sender.name;
    final senderImageUrl = notification.sender.imageUrl;
    final senderId = notification.sender.userId;

    // 通話画面をすぐに表示する代わりに、CallKitを表示
    _showCallkitIncoming(senderName, senderImageUrl, senderId);
  }

  Future<void> _handleDmNotification(PushNotificationModel notification) async {
    // インアプリ通知を表示
    NotificationService.showPushNotification(
      title: notification.content?.title ?? notification.sender.name,
      body: notification.content?.body ?? "新しいメッセージが届いています",
      payload: {
        'type': 'dm',
        'senderId': notification.sender.userId,
        'chatId': notification.payload?.chatId,
      },
    );
  }

  Future<void> _handleLikeNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content?.title ?? notification.sender.name,
      body: notification.content?.body ?? "あなたの投稿にいいねしました",
      payload: {
        'type': 'like',
        'senderId': notification.sender.userId,
        'postId': notification.payload?.postId,
      },
    );
  }

  Future<void> _handleCommentNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content?.title ?? notification.sender.name,
      body: notification.content?.body ?? "あなたの投稿にコメントしました",
      payload: {
        'type': 'comment',
        'senderId': notification.sender.userId,
        'postId': notification.payload?.postId,
        'commentId': notification.payload?.commentId,
      },
    );
  }

  Future<void> _handleFollowNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content?.title ?? notification.sender.name,
      body: notification.content?.body ?? "あなたをフォローしました",
      payload: {
        'type': 'follow',
        'senderId': notification.sender.userId,
      },
    );
  }

  Future<void> _handleFriendRequestNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content?.title ?? notification.sender.name,
      body: notification.content?.body ?? "フレンドリクエストが届きました",
      payload: {
        'type': 'friendRequest',
        'senderId': notification.sender.userId,
      },
    );
  }

  Future<void> _handleDefaultNotification(
      PushNotificationModel notification) async {
    NotificationService.showPushNotification(
      title: notification.content?.title ?? "新しい通知",
      body: notification.content?.body ?? "",
      payload: {'type': 'default'},
    );
  }

  // 画面遷移メソッド
  void _navigateToCallScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;
    final callId = notification.payload?.callId;

    if (userId != null && callId != null && navigatorKey.currentState != null) {
      /*navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => CallPage(
            userId: userId,
            callId: callId,
          ),
        ),
      ); */
    }
  }

  void _navigateToChatScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;
    final chatId = notification.payload?.chatId;

    if (userId != null && navigatorKey.currentState != null) {
      /*navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            userId: userId,
            chatId: chatId,
          ),
        ),
      ); */
    }
  }

  void _navigateToPostScreen(PushNotificationModel notification) {
    final postId = notification.payload?.postId;

    if (postId != null && navigatorKey.currentState != null) {
      /* navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => PostDetailPage(
            postId: postId,
          ),
        ),
      ); */
    }
  }

  void _navigateToProfileScreen(PushNotificationModel notification) {
    final userId = notification.sender.userId;

    if (userId != null && navigatorKey.currentState != null) {
      /* navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userId: userId,
          ),
        ),
      ); */
    }
  }

  // データをPushNotificationModelに変換するヘルパーメソッド
  PushNotificationModel _convertToNotificationModel(Map<String, dynamic> data) {
    // 通知タイプを特定
    final typeStr = data['type'] as String? ?? 'default';
    final type = _getNotificationTypeFromString(typeStr);

    // 送信者情報
    final sender = PushNotificationSender(
      userId: data['userId'] ?? data['senderId'] ?? '',
      name: data['name'] ?? data['senderName'] ?? '',
      imageUrl: data['imageUrl'] ?? data['senderImageUrl'],
    );

    // 通知内容
    final content = PushNotificationContent(
      title: data['title'] ?? sender.name,
      body: data['body'] ?? '',
    );

    // ペイロード構築
    final payload = PushNotificationPayload(
      messageId: data['messageId'],
      text: data['text'],
      chatId: data['chatId'],
      postId: data['postId'],
      commentId: data['commentId'],
      callId: data['callId'],
      callType: data['callType'],
    );

    // メタデータ
    final metadata = PushNotificationMetadata(
      timestamp: data['dateTime'] != null
          ? DateTime.parse(data['dateTime'])
          : DateTime.now(),
      priority: data['priority'] ?? 'normal',
      category: data['category'],
    );

    return PushNotificationModel(
      type: type,
      sender: sender,
      content: content,
      payload: payload,
      metadata: metadata,
    );
  }

  // 文字列からPushNotificationTypeを取得するヘルパーメソッド
  PushNotificationType _getNotificationTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'call':
        return PushNotificationType.call;
      case 'dm':
        return PushNotificationType.dm;
      case 'like':
        return PushNotificationType.like;
      case 'comment':
        return PushNotificationType.comment;
      case 'follow':
        return PushNotificationType.follow;
      case 'friendRequest':
        return PushNotificationType.friendRequest;
      default:
        return PushNotificationType.defaultType;
    }
  }

  // CallKitを表示するヘルパーメソッド
  static Future<void> _showCallkitIncoming(
      String name, String? imageUrl, String? userId) async {
    final params = CallKitParams(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: name,
      appName: 'アプリ名',
      avatar: imageUrl,
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
    /*
    final params = CallKitParams(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: name,
      appName: 'Blank',
      avatar: imageUrl,
      handle: '',
      type: 0, // 音声通話
      duration: 30000, // 30秒
      textAccept: '応答',
      textDecline: '拒否',
      textMissedCall: '不在着信',
      textCallback: 'コールバック',
      extra: <String, dynamic>{
        'userId': userId,
      },
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#333333',
        backgroundUrl: imageUrl,
        actionColor: '#4CAF50',
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: false,
        maximumCallGroups: 1,
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
    */
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}

*/