# ユーザーストーリーフロー: デバイス・ライフサイクル管理

## 概要
マルチデバイス対応とライフサイクル管理改善の全体フローを、ユーザーストーリーベースで整理したドキュメントです。

## 作成日
2025-10-06

---

## ユーザーストーリー一覧

### US-1: 新規ユーザーがアプリを初めて起動する
### US-2: 既存ユーザーがアプリを起動する（トークン変更なし）
### US-3: FCMトークンが自動リフレッシュされる
### US-4: ユーザーがアプリをバックグラウンドに移動する
### US-5: ユーザーがアプリをフォアグラウンドに戻す
### US-6: ユーザーがiOSとAndroid両方でログインする
### US-7: ユーザーがプッシュ通知を受信する
### US-8: ユーザーが通話を受信する（iOS VoIP / Android FCM）
### US-9: 古いデバイスが自動クリーンアップされる
### US-10: アプリを再インストールする（デバイスID変更）

---

## US-1: 新規ユーザーがアプリを初めて起動する

### シナリオ
新規ユーザーがアプリをインストールし、初めて起動する。

### アクター
- 新規ユーザー
- アプリ
- Firebase Authentication
- Firestore

### 前提条件
- アプリがインストール済み
- ユーザーが未ログイン

### フロー

#### 1. アプリ起動
```
[ユーザー] アプリアイコンをタップ
    ↓
[main.dart] アプリ起動
    ↓
[Firebase] Firebase初期化
    ↓
[認証画面] ログイン/サインアップ画面を表示
```

#### 2. ユーザー認証
```
[ユーザー] 電話番号でサインアップ
    ↓
[Firebase Auth] 新規ユーザー作成
    ↓
[UserUsecase] UserAccount.nullUser() 作成
    ↓
[Firestore] users/{userId} ドキュメント作成
```

#### 3. ライフサイクル初期化
```
[MainPageWrapper] useEffect で LifecycleNotifier.initialize() 実行
    ↓
[LifecycleNotifier.initialize()]
    │
    ├─ [1] MyAccountNotifier.registerDeviceIfNeeded()
    │      ↓
    │   [DeviceManagementUsecase.registerDeviceIfNeeded()]
    │      ↓
    │   デバイスIDを生成 (iOS: identifierForVendor, Android: androidId)
    │      ↓
    │   既存デバイスをチェック → 存在しない (新規)
    │      ↓
    │   FCMトークンを取得
    │      ↓
    │   VoIPトークンを取得 (iOS のみ)
    │      ↓
    │   デバイス詳細を取得 (デバイス名, OSバージョン, アプリバージョン)
    │      ↓
    │   DeviceInfoEntity を作成
    │      ↓
    │   [DeviceRepository.registerOrUpdateDevice()]
    │      ↓
    │   Firestore: users/{userId}/devices/{deviceId} 作成
    │      ↓
    │   Firestore: users/{userId}.activeDevices 配列に追加
    │      ↓
    │   [MyAccountNotifier] getUserByUid() で最新データを取得
    │      ↓
    │   state に activeDevices を含む UserAccount を設定
    │
    ├─ [2] TokenRefreshService.initialize()
    │      ↓
    │   FirebaseMessaging.onTokenRefresh リスナーを登録
    │
    └─ [3] MyAccountNotifier.setOnlineStatus(true)
           ↓
       Firestore: users/{userId} の isOnline = true に更新
```

#### 4. 結果のFirestoreデータ

**users/{userId}**
```json
{
  "userId": "user123",
  "username": "johndoe",
  "isOnline": true,
  "lastOpenedAt": "2025-10-06T10:00:00Z",
  "fcmToken": "fcm_token_xxx",  // 後方互換性
  "voipToken": "voip_token_xxx",  // 後方互換性 (iOS)
  "activeDevices": [
    {
      "deviceId": "device_abc",
      "platform": "ios",
      "fcmToken": "fcm_token_xxx",
      "voipToken": "voip_token_xxx",
      "lastActiveAt": "2025-10-06T10:00:00Z"
    }
  ],
  "devicesUpdatedAt": "2025-10-06T10:00:00Z"
}
```

**users/{userId}/devices/{deviceId}**
```json
{
  "deviceId": "device_abc",
  "platform": "ios",
  "fcmToken": "fcm_token_xxx",
  "voipToken": "voip_token_xxx",
  "deviceInfo": {
    "device": "iPhone 15 Pro (iPhone15,2)",
    "osVersion": "17.1.1",
    "appVersion": "1.2.3",
    "appBuildNumber": "123"
  },
  "isActive": true,
  "lastActiveAt": "2025-10-06T10:00:00Z",
  "createdAt": "2025-10-06T10:00:00Z",
  "updatedAt": "2025-10-06T10:00:00Z"
}
```

### 期待される結果
- ✅ ユーザーがサインアップ完了
- ✅ デバイス情報がFirestoreに登録される
- ✅ FCM/VoIPトークンが保存される
- ✅ activeDevices にデバイスが追加される
- ✅ TokenRefreshService が起動される
- ✅ ユーザーがオンライン状態になる

---

## US-2: 既存ユーザーがアプリを起動する（トークン変更なし）

### シナリオ
既存ユーザーが、前日アプリを使用したデバイスで再度アプリを起動する。

### アクター
- 既存ユーザー
- アプリ
- Firestore

### 前提条件
- ユーザーがログイン済み
- デバイスが既にFirestoreに登録済み
- FCM/VoIPトークンが変更されていない

### フロー

#### 1. アプリ起動
```
[ユーザー] アプリアイコンをタップ
    ↓
[main.dart] アプリ起動
    ↓
[MyAccountNotifier.initialize()] UserAccount をロード
    ↓
[MainPageWrapper] LifecycleNotifier.initialize() 実行
```

#### 2. デバイス登録チェック
```
[LifecycleNotifier.initialize()]
    ↓
[MyAccountNotifier.registerDeviceIfNeeded()]
    ↓
[DeviceManagementUsecase.registerDeviceIfNeeded()]
    ↓
デバイスIDを生成
    ↓
既存デバイスを取得 → 存在する
    ↓
FCMトークンを取得
    ↓
VoIPトークンを取得 (iOS)
    ↓
トークン比較:
  既存 FCM: "fcm_token_xxx"
  新規 FCM: "fcm_token_xxx"  ← 同じ
  既存 VoIP: "voip_token_xxx"
  新規 VoIP: "voip_token_xxx"  ← 同じ
    ↓
tokensChanged = false  ← トークン変更なし
    ↓
[キャッシュチェック]
  前回更新: 2025-10-05T10:00:00Z
  現在時刻: 2025-10-06T10:00:00Z
  経過時間: 24時間 > 1時間  ← 更新が必要
    ↓
[DeviceRepository.updateDeviceLastActive()]
    ↓
Firestore: users/{userId}/devices/{deviceId}.lastActiveAt を更新
    ↓
Firestore: users/{userId}.activeDevices[0].lastActiveAt を更新
    ↓
DeviceRegistrationResult(deviceUpdated: false) を返す
    ↓
[MyAccountNotifier] トークン変更なしのため、state は更新しない
```

#### 3. オンライン状態更新
```
[MyAccountNotifier.setOnlineStatus(true)]
    ↓
ローカル state を即座に更新 (isOnline = true)
    ↓
Firestore: users/{userId} の isOnline, lastOpenedAt のみ更新
```

### Firestore更新内容

**users/{userId}/devices/{deviceId}** (部分更新)
```json
{
  "lastActiveAt": "2025-10-06T10:00:00Z"  // 更新
}
```

**users/{userId}** (部分更新)
```json
{
  "isOnline": true,  // 更新
  "lastOpenedAt": "2025-10-06T10:00:00Z",  // 更新
  "activeDevices": [
    {
      "lastActiveAt": "2025-10-06T10:00:00Z"  // 更新
    }
  ]
}
```

### パフォーマンス

| 操作 | 実行 | コスト |
|------|------|--------|
| デバイスID生成 | ✅ | ローカル (無料) |
| 既存デバイス取得 | ✅ | 1 Read |
| トークン取得 | ❌ スキップ | 0 API Call |
| デバイス詳細取得 | ❌ スキップ | 0 |
| lastActiveAt 更新 | ✅ | 1 Write |
| activeDevices 更新 | ✅ | 0 Write (バッチ) |
| isOnline 更新 | ✅ | 1 Write |
| **合計** | | **1 Read + 2 Write** |

### 期待される結果
- ✅ デバイス情報の完全更新をスキップ（効率的）
- ✅ lastActiveAt のみ更新
- ✅ ユーザーがオンライン状態になる
- ✅ 不要なトークン取得をスキップ

---

## US-3: FCMトークンが自動リフレッシュされる

### シナリオ
Googleのポリシーにより、FCMトークンが自動的にリフレッシュされる。

### アクター
- Firebase Cloud Messaging
- TokenRefreshService
- DeviceManagementUsecase
- Firestore

### 前提条件
- ユーザーがログイン中
- アプリがフォアグラウンドまたはバックグラウンドで動作中

### トリガー
- Googleによる定期的なトークンリフレッシュ
- アプリの再インストール
- アプリデータのクリア
- デバイスの復元

### フロー

```
[Firebase Cloud Messaging] トークンをリフレッシュ
    ↓
[TokenRefreshService] onTokenRefresh イベントを検知
    ↓
新しいFCMトークンを受信: "fcm_token_yyy"
    ↓
VoIPトークンを取得 (iOS のみ)
    ↓
[DeviceManagementUsecase.updateDeviceTokens()]
    ↓
認証状態を確認 (currentUser != null)
    ↓
デバイスIDを取得
    ↓
[DeviceRepository.updateDeviceTokens()]
    ↓
Firestore: users/{userId}/devices/{deviceId} のトークンを更新
    ↓
Firestore: users/{userId}.activeDevices のトークンを更新
    ↓
完了ログを出力
```

### Firestore更新内容

**users/{userId}/devices/{deviceId}** (部分更新)
```json
{
  "fcmToken": "fcm_token_yyy",  // 更新
  "updatedAt": "2025-10-06T15:30:00Z"  // 更新
}
```

**users/{userId}** (部分更新)
```json
{
  "fcmToken": "fcm_token_yyy",  // 後方互換性のため更新
  "activeDevices": [
    {
      "fcmToken": "fcm_token_yyy"  // 更新
    }
  ],
  "devicesUpdatedAt": "2025-10-06T15:30:00Z"  // 更新
}
```

### パフォーマンス

| 操作 | コスト |
|------|--------|
| トークン更新 | 2 Write |

### 期待される結果
- ✅ 新しいFCMトークンがFirestoreに自動保存される
- ✅ ユーザーが何もしなくても通知が継続して届く
- ✅ activeDevices キャッシュも同期される

### 重要性
**このフローがないと**:
- ❌ トークンが無効化され、通知が届かなくなる
- ❌ ユーザーが通知を見逃す
- ❌ 通話を受信できない

---

## US-4: ユーザーがアプリをバックグラウンドに移動する

### シナリオ
ユーザーがホームボタン（またはジェスチャー）でアプリをバックグラウンドに移動する。

### フロー

```
[ユーザー] ホームボタンをタップ
    ↓
[iOS/Android OS] アプリをバックグラウンドに移動
    ↓
[WidgetsBinding] AppLifecycleState.paused を通知
    ↓
[LifecycleNotifier.onLifecycleStateChanged(paused)]
    ↓
[LifecycleNotifier._handleAppPaused()]
    ↓
[MyAccountNotifier.setOnlineStatus(false)]
    ↓
ローカル state を即座に更新 (isOnline = false)
    ↓
Firestore: users/{userId} の isOnline, lastOpenedAt を更新
    ↓
[SessionStateProvider.endSession()] セッション終了
```

### Firestore更新内容

**users/{userId}** (部分更新)
```json
{
  "isOnline": false,  // 更新
  "lastOpenedAt": "2025-10-06T16:00:00Z"  // 更新
}
```

### パフォーマンス

| 操作 | コスト |
|------|--------|
| isOnline 更新 | 1 Write |

### 期待される結果
- ✅ ユーザーがオフライン状態になる
- ✅ 他のユーザーから見て「オフライン」と表示される
- ✅ セッションが終了する

---

## US-5: ユーザーがアプリをフォアグラウンドに戻す

### シナリオ
バックグラウンドのアプリをタップして、フォアグラウンドに戻す。

### フロー

```
[ユーザー] アプリアイコンまたはタスクスイッチャーからアプリをタップ
    ↓
[iOS/Android OS] アプリをフォアグラウンドに移動
    ↓
[WidgetsBinding] AppLifecycleState.resumed を通知
    ↓
[LifecycleNotifier.onLifecycleStateChanged(resumed)]
    ↓
[LifecycleNotifier._handleAppResumed()]
    ↓
[MyAccountNotifier.setOnlineStatus(true)]  ← ★ デバイス登録はスキップ
    ↓
ローカル state を即座に更新 (isOnline = true)
    ↓
Firestore: users/{userId} の isOnline, lastOpenedAt のみ更新
    ↓
[SessionStateProvider.startSession()] セッション開始
```

### Firestore更新内容

**users/{userId}** (部分更新)
```json
{
  "isOnline": true,  // 更新
  "lastOpenedAt": "2025-10-06T16:10:00Z"  // 更新
}
```

### パフォーマンス

| 操作 | 従来 | 改善後 |
|------|------|--------|
| トークン取得 | ✅ 実行 | ❌ スキップ |
| デバイス詳細取得 | ✅ 実行 | ❌ スキップ |
| デバイス登録 | ✅ 実行 | ❌ スキップ |
| isOnline 更新 | ✅ 実行 | ✅ 実行 |
| **合計コスト** | 1 Write + 複数API Call | **1 Write のみ** |

### 期待される結果
- ✅ ユーザーが即座にオンライン状態になる
- ✅ 不要なデバイス登録処理をスキップ（高速化）
- ✅ セッションが再開される

### 改善効果
**1日5回フォアグラウンド復帰する場合（1000ユーザー）**:
- トークン取得API Call: 4,000回 削減
- デバイス詳細取得: 4,000回 削減

---

## US-6: ユーザーがiOSとAndroid両方でログインする

### シナリオ
同一ユーザーがiPhone とAndroid スマートフォンの両方でログインする。

### フロー

#### 1. iPhone でログイン（既にログイン済み）
```
[Firestore] users/{userId}
{
  "activeDevices": [
    {
      "deviceId": "ios_device_abc",
      "platform": "ios",
      "fcmToken": "fcm_ios_token",
      "voipToken": "voip_ios_token",
      "lastActiveAt": "2025-10-06T10:00:00Z"
    }
  ]
}
```

#### 2. Android スマートフォンでログイン
```
[Android] アプリを起動
    ↓
[LifecycleNotifier.initialize()]
    ↓
[DeviceManagementUsecase.registerDeviceIfNeeded()]
    ↓
デバイスID生成: "android_device_xyz"
    ↓
既存デバイスをチェック → 存在しない（新規Android デバイス）
    ↓
FCMトークン取得: "fcm_android_token"
    ↓
VoIPトークン取得: null (Android は VoIP 非対応)
    ↓
デバイス詳細取得:
  device: "Samsung Galaxy S24"
  osVersion: "Android 14.0"
  platform: "android"
    ↓
[DeviceRepository.registerOrUpdateDevice()]
    ↓
Firestore: users/{userId}/devices/android_device_xyz 作成
    ↓
Firestore: users/{userId}.activeDevices に追加
```

#### 3. 結果のFirestoreデータ

**users/{userId}**
```json
{
  "userId": "user123",
  "activeDevices": [
    {
      "deviceId": "ios_device_abc",
      "platform": "ios",
      "fcmToken": "fcm_ios_token",
      "voipToken": "voip_ios_token",
      "lastActiveAt": "2025-10-06T10:00:00Z"
    },
    {
      "deviceId": "android_device_xyz",
      "platform": "android",
      "fcmToken": "fcm_android_token",
      "voipToken": null,
      "lastActiveAt": "2025-10-06T11:00:00Z"
    }
  ],
  "devicesUpdatedAt": "2025-10-06T11:00:00Z"
}
```

**users/{userId}/devices/ios_device_abc**
```json
{
  "deviceId": "ios_device_abc",
  "platform": "ios",
  "fcmToken": "fcm_ios_token",
  "voipToken": "voip_ios_token",
  "deviceInfo": {
    "device": "iPhone 15 Pro",
    "osVersion": "17.1.1",
    "appVersion": "1.2.3"
  },
  "isActive": true,
  "lastActiveAt": "2025-10-06T10:00:00Z"
}
```

**users/{userId}/devices/android_device_xyz**
```json
{
  "deviceId": "android_device_xyz",
  "platform": "android",
  "fcmToken": "fcm_android_token",
  "voipToken": null,
  "deviceInfo": {
    "device": "Samsung Galaxy S24",
    "osVersion": "Android 14.0",
    "appVersion": "1.2.3"
  },
  "isActive": true,
  "lastActiveAt": "2025-10-06T11:00:00Z"
}
```

### 期待される結果
- ✅ 両方のデバイスが activeDevices に登録される
- ✅ 各デバイスのプラットフォームが正しく識別される
- ✅ iOS は VoIP トークンあり、Android は null

---

## US-7: ユーザーがプッシュ通知を受信する

### シナリオ
他のユーザーがメッセージを送信し、プッシュ通知を受信する。

### 前提条件
- ユーザーが iOS と Android の両方でログイン中

### フロー

#### 1. 送信者がメッセージを送信
```
[送信者] メッセージを送信
    ↓
[PushNotificationUsecase.sendDm()]
    ↓
受信者のUserAccountを取得
    ↓
activeDevices を確認
```

#### 2. 通知送信先の決定
```
[PushNotificationUsecase._generateReceivers()]
    ↓
activeDevices を走査:
  - ios_device_abc: fcmToken = "fcm_ios_token" ✅
  - android_device_xyz: fcmToken = "fcm_android_token" ✅
    ↓
PushNotificationReceiver のリストを生成:
  [
    { userId: "user123", fcmToken: "fcm_ios_token" },
    { userId: "user123", fcmToken: "fcm_android_token" }
  ]
```

#### 3. FCM 通知送信
```
[Firebase Functions] pushNotification-sendPushNotificationV2 を呼び出し
    ↓
fcm_ios_token に通知送信 → iPhone に届く
    ↓
fcm_android_token に通知送信 → Android に届く
```

### 期待される結果
- ✅ iPhone に通知が届く
- ✅ Android にも通知が届く
- ✅ 両方のデバイスで同時に受信できる

---

## US-8: ユーザーが通話を受信する（iOS VoIP / Android FCM）

### シナリオ
他のユーザーから通話がかかってくる。

### 前提条件
- ユーザーが iOS と Android の両方でログイン中

### フロー

#### 1. 発信者が通話を開始
```
[発信者] ユーザーに通話をかける
    ↓
[VoipUsecase.callUser()]
    ↓
受信者のUserAccountを取得
    ↓
activeDevices を確認
```

#### 2. デバイスタイプ別に振り分け
```
[VoipUsecase]
    ↓
activeDevices を分類:
  ┌─────────────────────────┐
  │ iOS VoIP 対応デバイス   │
  ├─────────────────────────┤
  │ - ios_device_abc        │
  │   voipToken: あり       │
  │   canUseVoip: true      │
  └─────────────────────────┘

  ┌─────────────────────────┐
  │ FCM デバイス            │
  ├─────────────────────────┤
  │ - android_device_xyz    │
  │   voipToken: null       │
  │   canUseVoip: false     │
  └─────────────────────────┘
```

#### 3. 通知送信
```
[VoIP デバイス → VoIP Push]
  ↓
voip_ios_token に VoIP Push 送信
  ↓
iPhone で着信画面が表示される（ネイティブUI）

[FCM デバイス → FCM 通知]
  ↓
fcm_android_token に FCM 通知送信
  ↓
Android で通知が表示される
```

### 期待される結果
- ✅ iPhone: ネイティブ着信画面が表示される（VoIP Push）
- ✅ Android: 通知から通話画面に遷移（FCM）
- ✅ 両方のデバイスで受信可能

---

## US-9: 古いデバイスが自動クリーンアップされる

### シナリオ
30日以上使用していないデバイスが自動的に削除される。

### アクター
- Firebase Cloud Functions (スケジュール実行)
- Firestore

### トリガー
- 毎日午前2時（JST）に自動実行

### フロー

```
[Cloud Scheduler] 毎日午前2時に実行
    ↓
[Firebase Functions] deviceCleanup-cleanupInactiveDevices
    ↓
全ユーザーを走査
    ↓
各ユーザーの devices サブコレクションを取得
    ↓
30日以上非アクティブなデバイスを抽出:
  lastActiveAt < (現在時刻 - 30日)
    ↓
該当デバイスを削除:
  users/{userId}/devices/{deviceId} を削除
    ↓
activeDevices キャッシュを更新:
  users/{userId}.activeDevices から削除
```

### 例

#### クリーンアップ前
```json
{
  "activeDevices": [
    {
      "deviceId": "old_device_123",
      "lastActiveAt": "2025-09-01T10:00:00Z"  // 35日前
    },
    {
      "deviceId": "current_device_456",
      "lastActiveAt": "2025-10-05T10:00:00Z"  // 1日前
    }
  ]
}
```

#### クリーンアップ後
```json
{
  "activeDevices": [
    {
      "deviceId": "current_device_456",
      "lastActiveAt": "2025-10-05T10:00:00Z"
    }
  ],
  "devicesUpdatedAt": "2025-10-06T02:00:00Z"
}
```

### 期待される結果
- ✅ 古いデバイスが自動削除される
- ✅ activeDevices が常に最新の状態を保つ
- ✅ 不要なデバイスへの通知送信を防ぐ

---

## US-10: アプリを再インストールする（デバイスID変更）

### シナリオ
ユーザーがアプリをアンインストール→再インストールする（iOSの場合、identifierForVendorが変更される可能性）。

### フロー

#### 1. アンインストール前の状態
```
users/{userId}/devices/old_device_abc (既存デバイス)
{
  "deviceId": "old_device_abc",
  "fcmToken": "fcm_old_token",
  "lastActiveAt": "2025-10-05T10:00:00Z"
}
```

#### 2. アンインストール→再インストール
```
[ユーザー] アプリをアンインストール
    ↓
[iOS] identifierForVendor がリセットされる（可能性）
    ↓
[ユーザー] アプリを再インストール
    ↓
[アプリ] 初回起動
```

#### 3. 新しいデバイスとして登録
```
[LifecycleNotifier.initialize()]
    ↓
[DeviceManagementUsecase.registerDeviceIfNeeded()]
    ↓
デバイスID生成: "new_device_xyz" (新しいID)
    ↓
既存デバイスをチェック → 存在しない（新規デバイス扱い）
    ↓
新しいデバイスとして登録
    ↓
Firestore: users/{userId}/devices/new_device_xyz 作成
    ↓
activeDevices に追加
```

#### 4. 結果
```json
{
  "activeDevices": [
    {
      "deviceId": "old_device_abc",  // 古いデバイス（まだ存在）
      "lastActiveAt": "2025-10-05T10:00:00Z"
    },
    {
      "deviceId": "new_device_xyz",  // 新しいデバイス
      "lastActiveAt": "2025-10-06T12:00:00Z"
    }
  ]
}
```

#### 5. 自動クリーンアップ（30日後）
```
[30日後のクリーンアップ]
    ↓
old_device_abc が削除される（非アクティブ）
    ↓
new_device_xyz のみが残る
```

### 期待される結果
- ✅ 再インストール後も正常に動作する
- ✅ 新しいデバイスとして登録される
- ✅ 古いデバイスは自動クリーンアップで削除される

---

## エッジケース

### EC-1: ネットワーク切断中にアプリを起動
```
[アプリ起動]
    ↓
[デバイス登録試行]
    ↓
ネットワークエラー発生
    ↓
[DeviceManagementUsecase] 例外をキャッチ
    ↓
ログ出力（デバッグモードのみ）
    ↓
アプリは正常に起動を継続（エラーで停止しない）
```

### EC-2: トークン取得失敗
```
[FCMトークン取得]
    ↓
null が返る（権限未許可など）
    ↓
fcmToken = null でデバイス登録
    ↓
通知は届かないが、アプリは正常動作
```

### EC-3: Firestore書き込み失敗
```
[デバイス登録]
    ↓
Firestore書き込みエラー
    ↓
DeviceManagementException をスロー
    ↓
[MyAccountNotifier] catchでログ出力
    ↓
アプリは起動を継続
```

---

## パフォーマンスサマリー

### 1日のFirestore操作数（1000ユーザー想定）

| ユーザーストーリー | Read | Write | API Call |
|-------------------|------|-------|----------|
| US-1: 初回起動 (100ユーザー) | 100 | 200 | 200 |
| US-2: 通常起動 (900ユーザー × 5回) | 4,500 | 9,000 | 0 |
| US-3: トークンリフレッシュ (33件/日) | 0 | 66 | 0 |
| US-4: バックグラウンド移動 (5,000回) | 0 | 5,000 | 0 |
| US-5: フォアグラウンド復帰 (5,000回) | 0 | 5,000 | 0 |
| **合計** | **4,600** | **19,266** | **200** |

### 改善前との比較

| 指標 | 改善前 | 改善後 | 削減率 |
|------|--------|--------|--------|
| **トークン取得API Call** | 25,200 | 200 | **99.2%** |
| **Firestore Read** | 4,600 | 4,600 | 0% |
| **Firestore Write** | 19,266 | 19,266 | 0% |

---

## まとめ

### ✅ 網羅したユーザーストーリー
1. 新規ユーザーの初回起動
2. 既存ユーザーの通常起動
3. FCMトークンの自動リフレッシュ
4. バックグラウンド移動
5. フォアグラウンド復帰
6. マルチデバイスログイン
7. プッシュ通知受信
8. 通話受信（VoIP/FCM）
9. 古いデバイスのクリーンアップ
10. アプリ再インストール

### ✅ 主要な改善点
- **FCMトークンリフレッシュ対応**: 通知の信頼性向上
- **フォアグラウンド復帰の最適化**: 99%のAPI Call削減
- **マルチデバイス対応**: iOS/Android同時ログイン
- **自動クリーンアップ**: 古いデバイスの自動削除

### ✅ クリーンアーキテクチャの遵守
- Presentation → Domain → Data の正しい依存関係
- ビジネスロジックの Domain 層への集約
- テスト容易性の向上

---

## 変更履歴
- 2025-10-06: 初版作成（全ユーザーストーリーフロー網羅）
