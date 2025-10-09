# チャットリクエスト機能 技術仕様書

## 目次
1. [概要](#概要)
2. [システムアーキテクチャ](#システムアーキテクチャ)
3. [データ構造](#データ構造)
4. [機能仕様](#機能仕様)
5. [API仕様](#api仕様)
6. [UI/UX仕様](#uiux仕様)
7. [通知機能](#通知機能)
8. [エラーハンドリング](#エラーハンドリング)
9. [パフォーマンス最適化](#パフォーマンス最適化)
10. [セキュリティ](#セキュリティ)
11. [将来の拡張](#将来の拡張)

---

## 概要

### 機能の目的
ユーザー間でチャットを開始する前に「リクエスト」を送信し、承認を得てからチャットを開始できる機能。スパムや望まないメッセージを防ぎ、安全で快適なコミュニケーション環境を提供する。

### 主要機能
- チャットリクエストの送信（メッセージ付き可能）
- 受信リクエストの確認・承認・却下
- 送信リクエストの確認・キャンセル
- 既存チャット・リクエストの重複チェック
- リクエスト送信時・承認時のプッシュ通知（マルチデバイス対応）
- 承認後の自動チャット画面遷移
- リアルタイム更新（Firestoreストリーム）

### ビジネス価値
- **ユーザー保護**: 望まないメッセージからユーザーを保護
- **エンゲージメント向上**: 承認ベースの安心できるコミュニケーション
- **スパム防止**: 無差別なメッセージ送信を抑制
- **UX改善**: 丁寧なコミュニケーションの促進

---

## システムアーキテクチャ

### クリーンアーキテクチャの適用

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │  Screen          │→ │  Provider    │→ │  Helper       │ │
│  │  (UI/Widget)     │  │  (State)     │  │  (Utility)    │ │
│  │  - List Screen   │  │  - Notifier  │  │  - Helper     │ │
│  │  - Dialog        │  │              │  │               │ │
│  └──────────────────┘  └──────────────┘  └───────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                      Domain Layer                            │
│  ┌──────────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │  Use Case        │→ │ IRepository  │  │  Entity       │ │
│  │  (Logic)         │  │ (Interface)  │  │  (Model)      │ │
│  │  - SendRequest   │  │              │  │  - Request    │ │
│  │  - AcceptRequest │  │              │  │  - Status     │ │
│  └──────────────────┘  └──────────────┘  └───────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────────────┐  ┌──────────────┐                     │
│  │  Repository      │→ │  Datasource  │→ Firebase Firestore │
│  │  Impl            │  │  (Firebase)  │                     │
│  └──────────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ↓
                    ┌───────────────┐
                    │  Push         │
                    │  Notification │
                    │  (FCM)        │
                    └───────────────┘
```

### レイヤー間の責務

#### Presentation Layer
- **Screen**: UI表示、ユーザーインタラクション処理、画面遷移
- **Provider (Notifier)**: 状態管理（Riverpod）、ストリームデータのバインディング
- **Helper**: リクエスト送信の共通ロジック、エントリーポイント統合

#### Domain Layer
- **UseCase**: ビジネスロジックの実装、通知連携、トランザクション処理
- **IRepository**: データアクセスの抽象インターフェース
- **Entity**: ドメインモデル、ビジネスルール、ステータス管理

#### Data Layer
- **Repository Impl**: IRepositoryの具体的実装、エラー変換
- **Datasource**: Firebase Firestoreへの直接アクセス、CRUD操作

---

## データ構造

### Entity構成

```
domain/entity/
  └── chat_request.dart           # チャットリクエストEntity
```

### Firestore データベーススキーマ

```
/chat_requests/{requestId}
  ├── id: string                  # リクエストID（UUID v4）
  ├── fromUserId: string          # 送信者のユーザーID
  ├── toUserId: string            # 受信者のユーザーID
  ├── createdAt: timestamp        # 作成日時
  ├── status: string              # "pending" | "accepted" | "rejected"
  └── message: string | null      # 添付メッセージ（任意、最大200文字）
```

**設計の特徴:**
- シンプルなフラットな構造
- ステータスによるライフサイクル管理
- タイムスタンプによる時系列管理
- メッセージは任意項目

### Entityモデル

#### ChatRequest Entity

```dart
class ChatRequest {
  final String id;               // リクエストID（UUIDv4）
  final String fromUserId;       // 送信者ユーザーID
  final String toUserId;         // 受信者ユーザーID
  final Timestamp createdAt;     // 作成日時
  final ChatRequestStatus status; // ステータス
  final String? message;         // 添付メッセージ（任意、最大200文字）

  // ビジネスロジック
  bool get isPending => status == ChatRequestStatus.pending;
  bool get isAccepted => status == ChatRequestStatus.accepted;
  bool get isRejected => status == ChatRequestStatus.rejected;

  // Factory
  factory ChatRequest.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  ChatRequest copyWith({...});
}
```

#### ChatRequestStatus Enum

```dart
enum ChatRequestStatus {
  pending('pending'),     // 未承認（デフォルト）
  accepted('accepted'),   // 承認済み
  rejected('rejected');   // 却下済み

  const ChatRequestStatus(this.value);
  final String value;

  static ChatRequestStatus fromString(String value);
}
```

**ステータス遷移:**
```
pending → accepted  （承認）
pending → rejected  （却下）
pending → [削除]    （キャンセル）
```

---

## 機能仕様

### 1. チャットリクエスト送信

#### トリガー
- ユーザーがメッセージボタンをタップ（複数のエントリーポイント）

#### 処理フロー
```
1. SendChatRequestHelper.startChatOrRequest() を呼び出し
   ↓
2. 既存チャットルームの存在確認
   - 存在する → 直接チャット画面へ遷移（処理終了）
   ↓
3. 既存リクエストの存在確認
   - 存在する → エラーメッセージ表示（処理終了）
   ↓
4. リクエスト送信ダイアログを表示
   - メッセージ入力（任意、最大200文字）
   ↓
5. ChatRequestUsecase.sendRequest() を実行
   ↓
6. Repository.sendRequest() でFirestoreに保存
   - requestId: UUIDv4自動生成
   - fromUserId: 送信者ID
   - toUserId: 受信者ID
   - status: "pending"
   - message: 入力メッセージ（または null）
   - createdAt: 現在時刻
   ↓
7. PushNotificationUsecase.sendChatRequest() で通知送信
   - UserAccountを取得
   - マルチデバイス対応（activeDevices）
   - タイトル: 送信者名
   - 本文: メッセージ or "チャットリクエストが届きました。"
   ↓
8. 成功メッセージを表示
```

#### バリデーション
- ログイン状態の確認
- 相手ユーザーの存在確認
- メッセージ文字数制限（200文字）
- 重複リクエストのチェック

#### エントリーポイント
1. **ユーザープロフィール画面**
   - ファイル: `user_profile_page.dart`
   - トリガー: メッセージボタン

2. **フォロー/フォロワー画面**
   - ファイル: `user_request_widget.dart`
   - トリガー: チャットアイコンボタン（UserRequestWidget内）

3. **タイムライン画面**（実装状況要確認）
   - ファイル: `timeline_square_sections.dart`

#### Firestoreトランザクション
```dart
Future<void> sendRequest({
  required String toUserId,
  String? message,
}) async {
  final requestId = const Uuid().v4();
  final request = ChatRequest(
    id: requestId,
    fromUserId: _auth.currentUser!.uid,
    toUserId: toUserId,
    createdAt: Timestamp.now(),
    status: ChatRequestStatus.pending,
    message: message,
  );

  await _firestore
      .collection('chat_requests')
      .doc(requestId)
      .set(request.toJson());
}
```

---

### 2. 受信リクエスト一覧取得

#### データソース
- `chat_requests`コレクション
- フィルタ: `toUserId == myUserId` AND `status == "pending"`

#### 取得方法（リアルタイムストリーム）
```dart
Stream<QuerySnapshot<Map<String, dynamic>>> streamReceivedRequests() {
  return _firestore
      .collection('chat_requests')
      .where('toUserId', isEqualTo: _auth.currentUser!.uid)
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots();
}
```

#### ソート順
- `createdAt` 降順（最新のリクエストが先頭）

#### 表示内容
- 送信者のプロフィール情報（UserWidget経由）
  - ユーザーアイコン
  - ユーザー名
  - オンライン状態
- 添付メッセージ（存在する場合）
- 送信時刻（相対時間表示: "1分前"）
- 承認ボタン
- 却下ボタン

---

### 3. 送信リクエスト一覧取得

#### データソース
- `chat_requests`コレクション
- フィルタ: `fromUserId == myUserId` AND `status == "pending"`

#### 取得方法（リアルタイムストリーム）
```dart
Stream<QuerySnapshot<Map<String, dynamic>>> streamSentRequests() {
  return _firestore
      .collection('chat_requests')
      .where('fromUserId', isEqualTo: _auth.currentUser!.uid)
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots();
}
```

#### 表示内容
- 送信先のプロフィール情報（UserWidget経由）
  - ユーザーアイコン
  - ユーザー名
- "送信済み" バッジ
- 添付メッセージ（存在する場合）
- 送信時刻（相対時間表示）
- キャンセルボタン

---

### 4. チャットリクエスト承認

#### 処理フロー
```
1. ReceivedRequestsNotifier.acceptRequest() を呼び出し
   ↓
2. ChatRequestUsecase.acceptRequest() を実行
   ↓
3. Repository.acceptRequest() でステータスを更新
   - status: "pending" → "accepted"
   ↓
4. DirectMessageOverviewUsecase.joinChat() でDMルームを作成
   - /direct_messages/{roomId}
   - roomId: DMKeyConverter.getKey(myUserId, otherUserId)
   - users: {myUserId: true, otherUserId: true}
   ↓
5. PushNotificationUsecase.sendChatRequestAccepted() で通知送信
   - 送信者のUserAccountを取得
   - マルチデバイス対応
   - タイトル: 承認者名
   - 本文: "チャットリクエストが承認されました。"
   ↓
6. チャット画面に自動遷移（Navigator.pushReplacement）
```

#### Firestore更新処理
```dart
// リクエストステータス更新
Future<void> acceptRequest(String requestId) async {
  await _firestore
      .collection('chat_requests')
      .doc(requestId)
      .update({
    'status': ChatRequestStatus.accepted.value,
  });
}

// DMルーム作成
Future<void> joinChat(String otherUserId) async {
  String roomId = DMKeyConverter.getKey(_auth.currentUser!.uid, otherUserId);
  await _firestore
      .collection("direct_messages")
      .doc(roomId)
      .set({
    "users.${_auth.currentUser!.uid}": true,
    "users.$otherUserId": true,
  }, SetOptions(merge: true));
}
```

#### バリデーション
- リクエストの存在確認
- リクエストのステータス確認（pending のみ承認可能）
- 送信者・受信者の整合性確認

---

### 5. チャットリクエスト却下

#### 処理フロー
```
1. 確認ダイアログを表示
   - タイトル: "リクエストを却下"
   - メッセージ: "このリクエストを却下しますか？"
   ↓
2. 確認後、ReceivedRequestsNotifier.rejectRequest() を呼び出し
   ↓
3. Repository.rejectRequest() でFirestoreから削除
   ↓
4. 成功メッセージを表示
   ↓
5. リストから自動削除（ストリーム更新により）
```

**重要:** 却下時は送信者に通知を送らない（プライバシー保護）

#### Firestore削除処理
```dart
Future<void> rejectRequest(String requestId) async {
  await _firestore
      .collection('chat_requests')
      .doc(requestId)
      .delete();
}
```

---

### 6. チャットリクエストキャンセル

#### 処理フロー
```
1. 確認ダイアログを表示
   - タイトル: "リクエストをキャンセル"
   - メッセージ: "このリクエストをキャンセルしますか？"
   ↓
2. 確認後、SentRequestsNotifier.cancelRequest() を呼び出し
   ↓
3. Repository.cancelRequest() でFirestoreから削除
   ↓
4. 成功メッセージを表示
   ↓
5. 両者のリストから自動削除（ストリーム更新により）
```

#### Firestore削除処理
```dart
Future<void> cancelRequest(String requestId) async {
  await _firestore
      .collection('chat_requests')
      .doc(requestId)
      .delete();
}
```

---

### 7. 既存リクエストの重複チェック

#### チェック内容
1. **既存チャットルームの確認**
   - DMOverviewリストを確認
   - 存在する → 直接チャット画面へ遷移

2. **既存リクエストの確認**
   - 自分が送ったpendingリクエスト
   - 相手から受け取ったpendingリクエスト
   - 存在する → エラーメッセージ表示

#### クエリ処理
```dart
Future<ChatRequest?> checkExistingRequest(String otherUserId) async {
  // 自分が送ったリクエスト
  final sentQuery = await _firestore
      .collection('chat_requests')
      .where('fromUserId', isEqualTo: _auth.currentUser!.uid)
      .where('toUserId', isEqualTo: otherUserId)
      .where('status', isEqualTo: 'pending')
      .limit(1)
      .get();

  if (sentQuery.docs.isNotEmpty) {
    return ChatRequest.fromJson(sentQuery.docs.first.data());
  }

  // 相手から受け取ったリクエスト
  final receivedQuery = await _firestore
      .collection('chat_requests')
      .where('fromUserId', isEqualTo: otherUserId)
      .where('toUserId', isEqualTo: _auth.currentUser!.uid)
      .where('status', isEqualTo: 'pending')
      .limit(1)
      .get();

  if (receivedQuery.docs.isNotEmpty) {
    return ChatRequest.fromJson(receivedQuery.docs.first.data());
  }

  return null;
}
```

---

## API仕様

### Repository Interface（IChatRequestRepository）

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `streamReceivedRequests()` | `Stream<List<ChatRequest>>` | 受信リクエスト一覧（リアルタイム） |
| `streamSentRequests()` | `Stream<List<ChatRequest>>` | 送信リクエスト一覧（リアルタイム） |
| `checkExistingRequest(String otherUserId)` | `Future<ChatRequest?>` | 既存リクエストの確認 |
| `sendRequest({required String toUserId, String? message})` | `Future<void>` | リクエストを送信 |
| `acceptRequest(String requestId)` | `Future<void>` | リクエストを承認 |
| `rejectRequest(String requestId)` | `Future<void>` | リクエストを却下 |
| `cancelRequest(String requestId)` | `Future<void>` | リクエストをキャンセル |
| `getRequest(String requestId)` | `Future<ChatRequest?>` | リクエストを取得 |

---

### UseCases

#### ChatRequestUsecase
```dart
class ChatRequestUsecase {
  final Ref _ref;
  final ChatRequestRepository _repository;
  final DirectMessageOverviewUsecase _dmOverviewUsecase;
  final PushNotificationUsecase _pushNotificationUsecase;

  // 受信リクエストストリーム
  Stream<List<ChatRequest>> streamReceivedRequests() {
    return _repository.streamReceivedRequests();
  }

  // 送信リクエストストリーム
  Stream<List<ChatRequest>> streamSentRequests() {
    return _repository.streamSentRequests();
  }

  // 既存リクエストチェック
  Future<ChatRequest?> checkExistingRequest(String otherUserId) {
    return _repository.checkExistingRequest(otherUserId);
  }

  // リクエスト送信（通知統合）
  Future<void> sendRequest({
    required String toUserId,
    String? message,
  }) async {
    // 既存リクエストチェック
    final existingRequest = await checkExistingRequest(toUserId);
    if (existingRequest != null) {
      throw Exception('既にリクエストが存在します');
    }

    // リクエスト送信
    await _repository.sendRequest(
      toUserId: toUserId,
      message: message,
    );

    // 通知送信（エラーは握りつぶす）
    try {
      final toUser = await _getUserAccount(toUserId);
      if (toUser != null) {
        await _pushNotificationUsecase.sendChatRequest(toUser, message);
      }
    } catch (e) {
      print('チャットリクエスト通知の送信に失敗: $e');
    }
  }

  // リクエスト承認（通知統合）
  Future<void> acceptRequest(String requestId) async {
    final request = await _repository.getRequest(requestId);
    if (request == null) {
      throw Exception('リクエストが見つかりません');
    }

    // リクエスト承認
    await _repository.acceptRequest(requestId);

    // チャットルームに参加
    await _dmOverviewUsecase.joinChat(request.fromUserId);

    // 通知送信（エラーは握りつぶす）
    try {
      final fromUser = await _getUserAccount(request.fromUserId);
      if (fromUser != null) {
        await _pushNotificationUsecase.sendChatRequestAccepted(fromUser);
      }
    } catch (e) {
      print('チャットリクエスト承認通知の送信に失敗: $e');
    }
  }

  // リクエスト却下
  Future<void> rejectRequest(String requestId) {
    return _repository.rejectRequest(requestId);
  }

  // リクエストキャンセル
  Future<void> cancelRequest(String requestId) {
    return _repository.cancelRequest(requestId);
  }

  // UserAccount取得ヘルパー
  Future<UserAccount?> _getUserAccount(String userId) async {
    // AllUsersNotifierからユーザー情報を取得
    // キャッシュにない場合は取得を試みる
  }
}
```

---

### Providers（State Management）

#### receivedRequestsNotifierProvider
```dart
@riverpod
class ReceivedRequestsNotifier extends _$ReceivedRequestsNotifier {
  @override
  Stream<List<ChatRequest>> build() {
    return ref.watch(chatRequestUsecaseProvider).streamReceivedRequests();
  }

  Future<void> acceptRequest(ChatRequest request) async {
    await ref.read(chatRequestUsecaseProvider).acceptRequest(request.id);
  }

  Future<void> rejectRequest(ChatRequest request) async {
    await ref.read(chatRequestUsecaseProvider).rejectRequest(request.id);
  }
}
```

#### sentRequestsNotifierProvider
```dart
@riverpod
class SentRequestsNotifier extends _$SentRequestsNotifier {
  @override
  Stream<List<ChatRequest>> build() {
    return ref.watch(chatRequestUsecaseProvider).streamSentRequests();
  }

  Future<void> cancelRequest(ChatRequest request) async {
    await ref.read(chatRequestUsecaseProvider).cancelRequest(request.id);
  }
}
```

#### pendingRequestCountProvider（オプション）
```dart
@riverpod
Future<int> pendingRequestCount(PendingRequestCountRef ref) async {
  final requests = await ref.watch(receivedRequestsNotifierProvider.future);
  return requests.length;
}
```

---

## UI/UX仕様

### チャットリクエスト一覧画面（ChatRequestListScreen）

#### レイアウト構成
```
┌────────────────────────────────────┐
│    AppBar: "チャットリクエスト"      │
├────────────────────────────────────┤
│  TabBar                            │
│  ┌─────────┬─────────────┐        │
│  │  受信   │    送信      │        │
│  └─────────┴─────────────┘        │
├────────────────────────────────────┤
│  TabBarView                        │
│  ┌──────────────────────────────┐ │
│  │  ┌──────────────────────┐   │ │
│  │  │  UserCard            │   │ │
│  │  │  ├─ Icon & Name      │   │ │
│  │  │  ├─ Message (opt)    │   │ │
│  │  │  ├─ Timestamp        │   │ │
│  │  │  └─ Actions          │   │ │
│  │  │     [却下] [承認]    │   │ │
│  │  └──────────────────────┘   │ │
│  │  ┌──────────────────────┐   │ │
│  │  │  UserCard            │   │ │
│  │  └──────────────────────┘   │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

#### タブ構成
1. **受信タブ**: 自分宛のリクエスト一覧
2. **送信タブ**: 自分が送ったリクエスト一覧

#### カード表示（受信リクエスト）

**デザイン:**
- 背景色: `ThemeColor.accent`
- 角丸: 16px
- パディング: 18px
- シャドウ: 軽いドロップシャドウ

**内容:**
```
┌────────────────────────────────────┐
│ 👤 [アイコン]  ユーザー名   1分前  │
│                ✓ オンライン        │
│                                    │
│ ┌──────────────────────────────┐ │
│ │ "はじめまして！お話ししたい    │ │
│ │  です"                        │ │
│ └──────────────────────────────┘ │
│                                    │
│ [    却下    ]  [    承認    ]    │
│  (アウトライン)  (グラデーション)  │
└────────────────────────────────────┘
```

**承認ボタン:**
- グラデーション: `ThemeColor.highlight` → `Colors.cyan`
- アイコン: `Icons.check_circle`
- テキスト: "承認"

**却下ボタン:**
- アウトライン: `ThemeColor.stroke`
- アイコン: `Icons.close`
- テキスト: "却下"

#### カード表示（送信リクエスト）

**内容:**
```
┌────────────────────────────────────┐
│ 👤 [アイコン]  ユーザー名   1分前  │
│                [送信済み]          │
│                                    │
│ ┌──────────────────────────────┐ │
│ │ "はじめまして！お話ししたい    │ │
│ │  です"                        │ │
│ └──────────────────────────────┘ │
│                                    │
│ [   リクエストをキャンセル   ]    │
│        (赤色アウトライン)          │
└────────────────────────────────────┘
```

**送信済みバッジ:**
- グラデーション背景（薄め）
- アイコン: `Icons.send`（サイズ12）
- テキスト: "送信済み"

**キャンセルボタン:**
- アウトライン: `Colors.red.shade400`
- アイコン: `Icons.cancel_outlined`
- テキスト: "リクエストをキャンセル"

#### 状態表示

##### ローディング状態
```dart
Center(child: CircularProgressIndicator())
```

##### エラー状態
```dart
Center(
  child: Text(
    'エラーが発生しました',
    style: TextStyle(color: ThemeColor.subText),
  ),
)
```

##### 空状態（受信タブ）
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.inbox_outlined, size: 64),
      Gap(16),
      Text("リクエストはありません"),
    ],
  ),
)
```

##### 空状態（送信タブ）
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.send_outlined, size: 64),
      Gap(16),
      Text("送信したリクエストはありません"),
    ],
  ),
)
```

---

### リクエスト送信ダイアログ

#### デザイン
```
┌────────────────────────────────────┐
│ 💬 チャットリクエスト              │
│                                    │
│ メッセージを添えてリクエストを      │
│ 送信できます                       │
│                                    │
│ ┌──────────────────────────────┐ │
│ │ 例: はじめまして！            │ │
│ │ お話ししたいです              │ │
│ │                               │ │
│ │                               │ │
│ └──────────────────────────────┘ │
│ 0/200文字                          │
│                                    │
│ [キャンセル]     [送信]            │
│  (アウトライン)  (グラデーション)  │
└────────────────────────────────────┘
```

#### 仕様
- 背景色: `ThemeColor.accent`
- 角丸: 20px
- シャドウ: 強めのドロップシャドウ
- アイコン: グラデーション背景の`Icons.chat_bubble_outline`
- テキストフィールド:
  - 最大行数: 4行
  - 最大文字数: 200文字
  - プレースホルダー: "例: はじめまして！お話ししたいです"
- 送信ボタン: グラデーション + `Icons.send`

#### インタラクション
- キャンセル: ダイアログを閉じる（nullを返す）
- 送信: 入力テキストを返す（空文字列可）

---

### ヘルパークラス（SendChatRequestHelper）

#### 役割
複数のエントリーポイントから統一的にリクエスト送信処理を実行

#### メソッド
```dart
static Future<void> startChatOrRequest({
  required BuildContext context,
  required WidgetRef ref,
  required String targetUserId,
}) async {
  // 1. 既存チャットルームチェック
  // 2. 既存リクエストチェック
  // 3. リクエスト送信ダイアログ表示
  // 4. リクエスト送信処理
}
```

#### 使用例
```dart
// ユーザープロフィール画面
IconButton(
  icon: Icon(Icons.chat_bubble_outline),
  onPressed: () {
    SendChatRequestHelper.startChatOrRequest(
      context: context,
      ref: ref,
      targetUserId: user.userId,
    );
  },
)

// フォロー/フォロワー画面
IconButton(
  icon: Icon(Icons.chat_bubble_outline),
  onPressed: () {
    SendChatRequestHelper.startChatOrRequest(
      context: context,
      ref: ref,
      targetUserId: user.userId,
    );
  },
)
```

---

## 通知機能

### プッシュ通知の統合

#### PushNotificationType拡張
```dart
enum PushNotificationType {
  dm,
  call,
  like,
  comment,
  follow,
  friendRequest,
  chatRequest,           // ★ 新規追加
  chatRequestAccepted,   // ★ 新規追加
  defaultType,
}
```

### チャットリクエスト送信通知

#### 仕様
```dart
Future<void> sendChatRequest(UserAccount user, String? message) async {
  final sender = _generateSender();
  final receivers = _generateReceivers(user); // マルチデバイス対応

  if (receivers.isEmpty) return;

  await _sendPushNotification(
    type: PushNotificationType.chatRequest,
    sender: sender,
    recipients: receivers,
    content: PushNotificationContent(
      title: sender.name,
      body: message?.isNotEmpty == true
          ? message!
          : "チャットリクエストが届きました。",
    ),
    payload: PushNotificationPayload(
      text: message,
    ),
  );
}
```

#### 通知表示例
```
通知バー:
┌────────────────────────────────┐
│ 👤 山田太郎                     │
│ はじめまして！お話ししたいです  │
└────────────────────────────────┘
```

#### マルチデバイス対応
- UserAccount.activeDevices から全デバイスを取得
- FCMトークンが有効なデバイスに通知送信
- フォールバック: activeDevicesが空の場合は fcmToken を使用

---

### チャットリクエスト承認通知

#### 仕様
```dart
Future<void> sendChatRequestAccepted(UserAccount user) async {
  final sender = _generateSender();
  final receivers = _generateReceivers(user); // マルチデバイス対応

  if (receivers.isEmpty) return;

  await _sendPushNotification(
    type: PushNotificationType.chatRequestAccepted,
    sender: sender,
    recipients: receivers,
    content: PushNotificationContent(
      title: sender.name,
      body: "チャットリクエストが承認されました。",
    ),
  );
}
```

#### 通知表示例
```
通知バー:
┌────────────────────────────────┐
│ 👤 佐藤花子                     │
│ チャットリクエストが承認されまし │
│ た。                            │
└────────────────────────────────┘
```

---

### 通知のエラーハンドリング

#### 方針
通知送信の失敗はリクエスト送信/承認処理の失敗とはしない

#### 実装
```dart
// リクエスト送信時
try {
  final toUser = await _getUserAccount(toUserId);
  if (toUser != null) {
    await _pushNotificationUsecase.sendChatRequest(toUser, message);
  }
} catch (e) {
  // 通知送信のエラーは握りつぶす（ログのみ）
  print('チャットリクエスト通知の送信に失敗: $e');
}
```

**理由:**
- 通知はユーザー体験の補助機能
- 通知失敗でもリクエスト自体は成功とする
- リクエスト一覧から確認可能

---

## エラーハンドリング

### カスタム例外
現在はException()を使用。将来的にカスタム例外を定義可能。

```dart
class ChatRequestException implements Exception {
  final String message;
  ChatRequestException(this.message);

  @override
  String toString() => 'ChatRequestException: $message';
}
```

### エラーケース

| エラー | 原因 | 処理 | ユーザーへの表示 |
|--------|------|------|----------------|
| 既存リクエスト存在 | checkExistingRequest()で検出 | Exception をスロー | "既にリクエストを送信しています" |
| リクエスト送信失敗 | Firestore書き込み失敗 | Exception をスロー | "エラーが発生しました: {詳細}" |
| リクエスト承認失敗 | Firestoreステータス更新失敗 | Exception をスロー | "エラーが発生しました: {詳細}" |
| リクエスト却下失敗 | Firestore削除失敗 | Exception をスロー | "エラーが発生しました: {詳細}" |
| リクエストキャンセル失敗 | Firestore削除失敗 | Exception をスロー | "エラーが発生しました: {詳細}" |
| リクエスト不存在 | getRequest()で null | Exception をスロー | "リクエストが見つかりません" |
| 通知送信失敗 | FCM送信失敗 | **エラーを握りつぶす** | （表示なし） |
| ネットワークエラー | オフライン | Exception をスロー | "ネットワークエラーが発生しました" |

### ストリームエラーハンドリング
```dart
// Provider側でエラーハンドリング
@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncValue = ref.watch(receivedRequestsNotifierProvider);

  return asyncValue.when(
    data: (requests) => ListView(...),
    loading: () => Center(child: CircularProgressIndicator()),
    error: (error, _) => Center(
      child: Text('エラーが発生しました'),
    ),
  );
}
```

---

## パフォーマンス最適化

### 1. Firestoreクエリ最適化

#### インデックス
```
Collection: chat_requests
Composite Index 1:
  - toUserId (Ascending)
  - status (Ascending)
  - createdAt (Descending)

Composite Index 2:
  - fromUserId (Ascending)
  - status (Ascending)
  - createdAt (Descending)
```

**理由:**
- `where` + `orderBy` のクエリに必要
- 受信/送信リクエスト一覧の取得を高速化

#### クエリ効率化
```dart
// statusフィルタで pending のみ取得（フルスキャン回避）
.where('status', isEqualTo: 'pending')
.orderBy('createdAt', descending: true)
```

---

### 2. リアルタイムストリーム

#### autoDisposeの活用
```dart
@riverpod
class ReceivedRequestsNotifier extends _$ReceivedRequestsNotifier {
  @override
  Stream<List<ChatRequest>> build() {
    // 画面を離れたら自動的にストリームを閉じる
    return ref.watch(chatRequestUsecaseProvider).streamReceivedRequests();
  }
}
```

**メリット:**
- メモリリーク防止
- 不要なFirestoreリスナーの自動解除
- Firestoreの課金削減

---

### 3. 通知送信の非同期化

#### 並列処理
```dart
// リクエスト送信と通知送信を分離
await _repository.sendRequest(...);  // 先に完了

// 通知は非同期でバックグラウンド実行
try {
  await _pushNotificationUsecase.sendChatRequest(...);
} catch (e) {
  // エラーは握りつぶす
}
```

**メリット:**
- ユーザーを待たせない
- 通知失敗でもリクエスト送信は成功

---

### 4. UI最適化

#### ListView最適化
```dart
ListView.builder(
  padding: const EdgeInsets.symmetric(vertical: 8),
  itemCount: requests.length,
  itemBuilder: (context, index) {
    // 必要な時だけWidget構築
    return ReceivedRequestCard(request: requests[index]);
  },
)
```

#### アニメーションの適度な使用
- カード表示時のフェードイン（ローディング時のみ）
- 削除時のスライドアウト（オプション）
- 過度なアニメーションは避ける（パフォーマンス優先）

---

## セキュリティ

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // チャットリクエスト関連のルール
    match /chat_requests/{requestId} {

      // リクエストの作成: 自分が送信者の場合のみ
      allow create: if request.auth != null
        && request.resource.data.fromUserId == request.auth.uid
        && request.resource.data.status == 'pending'
        && request.resource.data.keys().hasAll(['id', 'fromUserId', 'toUserId', 'createdAt', 'status'])
        && (!request.resource.data.keys().hasAny(['message'])
            || request.resource.data.message.size() <= 200);

      // リクエストの読み取り: 送信者または受信者のみ
      allow read: if request.auth != null
        && (resource.data.fromUserId == request.auth.uid
            || resource.data.toUserId == request.auth.uid);

      // リクエストの更新: 受信者が承認する場合のみ
      // ステータスを "accepted" に変更する操作のみ許可
      allow update: if request.auth != null
        && resource.data.toUserId == request.auth.uid
        && resource.data.status == 'pending'
        && request.resource.data.status == 'accepted'
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status']);

      // リクエストの削除: 送信者または受信者のみ
      // 却下（受信者）またはキャンセル（送信者）
      allow delete: if request.auth != null
        && (resource.data.fromUserId == request.auth.uid
            || resource.data.toUserId == request.auth.uid);
    }
  }
}
```

### データバリデーション

#### クライアント側
```dart
// リクエスト送信前のバリデーション
if (myUserId.isEmpty || toUserId.isEmpty) {
  throw Exception('ユーザーIDが無効です');
}

if (message != null && message.length > 200) {
  throw Exception('メッセージは200文字以内で入力してください');
}

// 自分自身へのリクエストを防止
if (myUserId == toUserId) {
  throw Exception('自分自身にリクエストを送信できません');
}
```

#### サーバー側（Firestore Rules）
- 送信者IDが認証ユーザーIDと一致すること
- ステータスが "pending" で作成されること
- 必須フィールドが全て存在すること
- メッセージが200文字以内であること

---

### プライバシー保護

#### 却下時の通知なし
- リクエスト却下時は送信者に通知を送らない
- 相手に拒否されたことがわからない（心理的負担軽減）
- ストーカー対策

#### 通知制御
- ユーザーが通知をOFFにできる（将来実装）
- ブロックしたユーザーからのリクエストを自動却下（将来実装）

---

## 将来の拡張

### 実装予定機能

#### 1. リクエスト有効期限
```dart
class ChatRequest {
  final DateTime? expiresAt;  // 有効期限（7日後など）

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt);
}
```

**メリット:**
- 古いリクエストの自動削除
- データベースサイズの管理

---

#### 2. リクエスト数制限
```dart
// 1日あたりの送信可能数を制限
Future<void> sendRequest(...) async {
  final todayCount = await _getTodayRequestCount();
  if (todayCount >= 10) {
    throw Exception('本日のリクエスト送信上限に達しました');
  }
  // ...
}
```

**メリット:**
- スパム防止
- サーバー負荷軽減

---

#### 3. ブロック機能との統合
```dart
// ブロック状態のチェック
Future<void> sendRequest(...) async {
  final isBlocked = await _checkBlockStatus(toUserId);
  if (isBlocked) {
    throw Exception('このユーザーにリクエストを送信できません');
  }
  // ...
}

// ブロックされたユーザーからのリクエストを自動却下
Stream<List<ChatRequest>> streamReceivedRequests() {
  return _repository.streamReceivedRequests()
      .map((requests) => requests.where((req) => !_isBlockedUser(req.fromUserId)));
}
```

---

#### 4. リクエストテンプレート
```dart
// 定型メッセージの提供
final templates = [
  "はじめまして！お話ししませんか？",
  "プロフィールを見て興味を持ちました",
  "趣味が合いそうですね",
];

// ダイアログでテンプレート選択可能
```

---

#### 5. リクエスト統計情報
```dart
class ChatRequestStatistics {
  final int totalReceived;    // 総受信数
  final int totalSent;        // 総送信数
  final int acceptedCount;    // 承認数
  final int rejectedCount;    // 却下数
  final double acceptanceRate; // 承認率
}
```

---

#### 6. カスタム通知音
```dart
// リクエスト受信時の専用通知音
Future<void> sendChatRequest(...) async {
  await _sendPushNotification(
    ...
    metadata: PushNotificationMetadata(
      sound: 'chat_request_sound.mp3',  // カスタム音
    ),
  );
}
```

---

#### 7. リクエスト理由の選択
```dart
class ChatRequest {
  final String? reason;  // "共通の趣味" | "友達になりたい" | "質問がある" など
}

// ダイアログで理由を選択
showDialog<ChatRequestReason>(
  context: context,
  builder: (context) => _SelectReasonDialog(),
);
```

---

## テスト仕様

### ユニットテスト

#### Repository Test
```dart
test('sendRequest should create a pending request', () async {
  await repository.sendRequest(
    toUserId: 'user123',
    message: 'Hello',
  );

  verify(datasource.sendRequest(
    toUserId: 'user123',
    message: 'Hello',
  )).called(1);
});

test('checkExistingRequest should return null if no request exists', () async {
  when(datasource.checkExistingRequest('user123'))
    .thenAnswer((_) async => null);

  final result = await repository.checkExistingRequest('user123');

  expect(result, isNull);
});
```

#### UseCase Test
```dart
test('sendRequest should throw exception if request already exists', () async {
  when(repository.checkExistingRequest('user123'))
    .thenAnswer((_) async => mockChatRequest);

  expect(
    () => usecase.sendRequest(toUserId: 'user123'),
    throwsException,
  );
});

test('acceptRequest should create DM room', () async {
  when(repository.getRequest('req123'))
    .thenAnswer((_) async => mockChatRequest);

  await usecase.acceptRequest('req123');

  verify(dmOverviewUsecase.joinChat(mockChatRequest.fromUserId)).called(1);
});
```

---

### 統合テスト

#### E2E Scenario 1: 基本フロー
```
1. ユーザーAがユーザーBのプロフィールを開く
2. メッセージボタンをタップ
3. リクエスト送信ダイアログが表示される
4. メッセージを入力して送信
5. ユーザーBに通知が届く
6. ユーザーBがリクエスト一覧を開く
7. ユーザーAのリクエストが表示される
8. 承認ボタンをタップ
9. チャット画面に遷移
10. ユーザーAに承認通知が届く
```

#### E2E Scenario 2: 重複チェック
```
1. ユーザーAがユーザーBにリクエスト送信
2. 再度メッセージボタンをタップ
3. エラーメッセージが表示される
4. リクエスト一覧に1件のみ表示される
```

---

## パフォーマンスベンチマーク

### 目標値
- リクエスト送信処理: < 500ms
- リクエスト一覧取得: < 300ms
- リクエスト承認処理: < 800ms（DM作成含む）
- 通知送信: < 1000ms（非同期）

### 最適化指標
- Firestoreクエリ数: 最小化（1画面1-2クエリ）
- ストリームリスナー: 必要最小限（autoDispose）
- 通知送信: バックグラウンド実行（ユーザーを待たせない）

---

## 依存関係

### パッケージ
```yaml
dependencies:
  cloud_firestore: ^4.x.x
  hooks_riverpod: ^2.x.x
  flutter_hooks: ^0.x.x
  uuid: ^4.x.x
  firebase_messaging: ^14.x.x
```

### 内部依存
```
Presentation Layer
  ├── pages/chat_request/
  │   ├── chat_request_list_screen.dart
  │   └── send_chat_request_helper.dart
  └── providers/chat_requests/
      ├── received_requests_notifier.dart
      ├── sent_requests_notifier.dart
      └── pending_request_count_provider.dart
  ↓
Domain Layer
  ├── entity/
  │   └── chat_request.dart
  ├── usecases/
  │   ├── chat_request_usecase.dart
  │   ├── direct_message_overview_usecase.dart
  │   └── push_notification_usecase.dart
  └── repository/
      └── chat_request_repository_interface.dart
  ↓
Data Layer
  ├── repository/
  │   └── chat_request_repository.dart
  └── datasource/
      └── chat_request_datasource.dart
  ↓
Firebase
  ├── Firestore
  └── Cloud Messaging
```

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0.0 | 2025-10-09 | 初版リリース（基本機能実装） |
| 1.1.0 | 2025-10-09 | プッシュ通知機能統合（マルチデバイス対応） |
| 1.2.0 | 未定 | リクエスト有効期限・数制限実装予定 |
| 1.3.0 | 未定 | ブロック機能統合予定 |

### v1.0.0の実装内容
- チャットリクエストの送信・承認・却下・キャンセル
- 受信/送信リクエスト一覧（リアルタイム更新）
- 既存チャット・リクエストの重複チェック
- SendChatRequestHelper による統一的なエントリーポイント
- リクエスト送信ダイアログ（メッセージ入力）

### v1.1.0の実装内容
- プッシュ通知機能の統合
  - リクエスト送信通知
  - リクエスト承認通知
  - マルチデバイス対応（UserAccount.activeDevices）
- PushNotificationUsecase へのメソッド追加
  - `sendChatRequest(UserAccount, String?)`
  - `sendChatRequestAccepted(UserAccount)`
- ChatRequestUsecase での通知連携
- エラーハンドリング（通知失敗は握りつぶす）

---

## 用語集

| 用語 | 説明 |
|-----|------|
| ChatRequest | ユーザー間のチャット開始リクエスト |
| pending | 未承認の状態 |
| accepted | 承認済みの状態（チャット開始可能） |
| rejected | 却下済みの状態 |
| fromUserId | リクエスト送信者のユーザーID |
| toUserId | リクエスト受信者のユーザーID |
| UseCase | ビジネスロジックを実装する単一責任のクラス |
| Repository | データアクセスの抽象インターフェース |
| Datasource | Firestoreへの直接アクセス層 |
| Provider (Notifier) | Riverpodによる状態管理クラス |
| Helper | 共通ロジックを提供するユーティリティクラス |
| FCM | Firebase Cloud Messaging（プッシュ通知） |

---

## 参考資料

### クリーンアーキテクチャ
- Domain層でインターフェースを定義
- Data層で具体的実装を提供
- 依存性の逆転原則（DIP）を適用

### Riverpod（Code Generation）
- `@riverpod`: プロバイダー自動生成
- `StreamProvider`: リアルタイムデータ監視
- `autoDispose`: 自動リソース解放

### Firestore Best Practices
- インデックス最適化（複合インデックス）
- Security Rules によるアクセス制御
- リアルタイムリスナーの最小化

### Firebase Cloud Messaging
- マルチデバイス対応（activeDevices）
- データメッセージの活用
- 通知のカスタマイズ

---

## まとめ

チャットリクエスト機能は、クリーンアーキテクチャに基づき、以下の特徴を持つ：

1. **レイヤー分離**: Presentation / Domain / Data の明確な分離
2. **依存性の逆転**: Domain層がData層の詳細を知らない
3. **テスタビリティ**: 各レイヤーが独立してテスト可能
4. **拡張性**: 新機能追加時に既存コードへの影響を最小化
5. **ユーザー保護**: 承認ベースの安全なコミュニケーション
6. **パフォーマンス**: インデックス最適化・ストリーム管理・通知の非同期化
7. **セキュリティ**: Firestore Security Rules によるアクセス制御
8. **プライバシー**: 却下時の通知なし、ブロック機能との統合（将来）
9. **通知統合**: マルチデバイス対応のプッシュ通知

この仕様書に従うことで、保守性・拡張性の高いチャットリクエスト機能を実現できる。

---

**最終更新**: 2025年10月9日
**バージョン**: 1.1.0
**作成者**: 開発チーム
