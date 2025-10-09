//プッシュ通知専用のモデル

enum PushNotificationType {
  dm,
  call,
  like,
  comment,
  follow,
  friendRequest,
  chatRequest,
  chatRequestAccepted,
  defaultType,
}

class PushNotificationSender {
  final String userId;
  final String name;
  final String? imageUrl;

  PushNotificationSender({
    required this.userId,
    required this.name,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'imageUrl': imageUrl,
      };
}

class PushNotificationReceiver {
  final String userId;
  final String? fcmToken;

  PushNotificationReceiver({
    required this.userId,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fcmToken': fcmToken,
      };
}

class PushNotificationContent {
  final String title;
  final String body;

  PushNotificationContent({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
      };
}

class PushNotificationPayload {
  // DMペイロード
  final String? messageId;
  final String? text;
  final String? chatId;

  // いいね/コメントペイロード
  final String? postId;
  final String? commentId;

  // 通話ペイロード
  final String? callId;
  final String? callType;

  PushNotificationPayload({
    this.messageId,
    this.text,
    this.chatId,
    this.postId,
    this.commentId,
    this.callId,
    this.callType,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (messageId != null) map['messageId'] = messageId;
    if (text != null) map['text'] = text;
    if (chatId != null) map['chatId'] = chatId;
    if (postId != null) map['postId'] = postId;
    if (commentId != null) map['commentId'] = commentId;
    if (callId != null) map['callId'] = callId;
    if (callType != null) map['callType'] = callType;

    return map;
  }
}

class PushNotificationMetadata {
  final DateTime timestamp;
  final String priority;
  final String? category;

  PushNotificationMetadata({
    DateTime? timestamp,
    this.priority = 'normal',
    this.category,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'priority': priority,
        'category': category,
      };
}

class PushNotificationModel {
  final PushNotificationType type;
  final PushNotificationSender sender;
  final PushNotificationReceiver? receiver;
  final List<PushNotificationReceiver>? recipients;
  final PushNotificationContent content;
  final PushNotificationPayload? payload;
  final PushNotificationMetadata metadata;

  PushNotificationModel({
    required this.type,
    required this.sender,
    this.receiver,
    this.recipients,
    required this.content,
    this.payload,
    required this.metadata,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type.toString().split('.').last,
      'sender': sender.toMap(),
      'metadata': metadata.toMap(),
    };
    if (receiver != null) map['receiver'] = receiver!.toMap();
    if (recipients != null) {
      map['recipients'] = recipients!.map((r) => r.toMap()).toList();
    }
    map['content'] = content.toMap();
    if (payload != null) map['payload'] = payload!.toMap();

    return map;
  }
}

/*
{
  "type": "notification_type",      // 通知タイプ（dm, call, like, comment, follow, etc）
  "sender": {                       // 送信者情報
    "userId": "user_id",
    "name": "sender_name",
    "imageUrl": "profile_image_url" 
  },
  "receiver": {                     // 受信者情報（複数の場合はrecipients配列を使用）
    "userId": "user_id",
    "fcmToken": "fcm_token"
  },
  "recipients": [                   // 複数受信者用（マルチキャストの場合）
    { "userId": "user_id1", "fcmToken": "token1" },
    { "userId": "user_id2", "fcmToken": "token2" }
  ],
  "content": {                      // 通知コンテンツ（表示用）
    "title": "通知タイトル",
    "body": "通知本文"
  },
  "payload": {                      // 通知タイプ別の追加データ
    // DMの場合
    "messageId": "message_id",
    "text": "メッセージ内容",
    "chatId": "chat_id",
    
    // いいね/コメントの場合
    "postId": "post_id",
    "commentId": "comment_id",
    
    // 通話の場合
    "callId": "call_id",
    "callType": "audio/video"
  },
  "metadata": {                     // メタデータ
    "timestamp": "ISO8601_timestamp",
    "priority": "high/normal",
    "category": "social/message/call"
  }
}
 */
