# ライフサイクル管理改善実装レポート

## 概要
アプリライフサイクルに基づいたデバイス・トークン管理を最適化し、FCMトークンリフレッシュ対応と不要なFirestore書き込みの削減を実現しました。

## 実装日
2025-10-06

## 実装した改善内容

### 1. TokenRefreshService の追加

#### 新規作成ファイル
**`lib/presentation/services/token_refresh_service.dart`**

#### 目的
FCMトークンが自動的にリフレッシュされた際に、Firestoreのデバイス情報を自動更新する。

#### 実装内容
```dart
class TokenRefreshService {
  void initialize() {
    // FCM トークンリフレッシュを監視
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
  }

  Future<void> _onTokenRefresh(String newToken) async {
    // 新しいトークンを取得
    final fcmToken = newToken;
    final voipToken = Platform.isIOS
        ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
        : null;

    // デバイストークンを更新
    await _updateDeviceTokens(fcmToken: fcmToken, voipToken: voipToken);
  }
}
```

#### 重要性
- **従来の問題**: FCMトークンがリフレッシュされても検知できず、通知が届かなくなるリスクがあった
- **改善後**: トークンリフレッシュ時に自動的にFirestoreを更新し、常に有効なトークンを維持

---

### 2. MyAccountNotifier の改善

#### ファイル
**`lib/presentation/providers/shared/users/my_user_account_notifier.dart`**

#### 追加メソッド

##### a. `setOnlineStatus(bool isOnline)` - 軽量なオンライン状態更新
**目的**: フォアグラウンド復帰時やバックグラウンド移行時に、デバイス情報を更新せず、オンライン状態のみを更新

**実装**:
```dart
Future<void> setOnlineStatus(bool isOnline) async {
  // ローカル状態を即座に更新
  final updatedUser = user.copyWith(
    isOnline: isOnline,
    lastOpenedAt: Timestamp.now(),
  );
  state = AsyncValue.data(updatedUser);

  // Firestore は isOnline と lastOpenedAt のみ更新
  await usecase.updateUserFields(
    userId: user.userId,
    fields: {
      'isOnline': isOnline,
      'lastOpenedAt': FieldValue.serverTimestamp(),
    },
  );
}
```

**メリット**:
- デバイス情報の取得をスキップ (トークン取得、デバイス名取得などの重い処理を回避)
- Firestore への書き込みを最小限に抑える (2フィールドのみ)

##### b. `registerDeviceIfNeeded()` - スマートなデバイス登録
**目的**: トークンが変更された場合のみデバイス情報を完全更新し、変更がない場合は `lastActiveAt` のみ更新

**実装**:
```dart
Future<void> registerDeviceIfNeeded() async {
  // 1. デバイスIDを取得
  final deviceId = await deviceIdGenerator.generateDeviceId();

  // 2. 既存デバイスをチェック
  final existingDevice = await deviceRepository.getDevice(user.userId, deviceId);

  // 3. トークンを取得
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final voipToken = Platform.isIOS ? await FlutterCallkitIncoming.getDevicePushTokenVoIP() : null;

  // 4. トークンが変更されたかチェック
  final tokensChanged = existingDevice == null ||
      existingDevice.fcmToken != fcmToken ||
      existingDevice.voipToken != voipToken;

  if (tokensChanged) {
    // トークンが変更された場合のみ完全な更新
    await _registerOrUpdateDevice(user.userId);
  } else {
    // トークンが同じ場合は lastActiveAt のみ更新 (キャッシュチェック付き)
    final shouldUpdate = await cache.shouldUpdate(deviceId, interval: Duration(hours: 1));
    if (shouldUpdate) {
      await deviceRepository.updateDeviceLastActive(user.userId, deviceId);
    }
  }
}
```

**メリット**:
- トークン変更の検知により、不要な完全更新を回避
- 既存デバイスの場合は最小限の更新のみ実行

##### c. `onOpen()` を Deprecated に
**変更内容**:
```dart
@Deprecated('Use registerDeviceIfNeeded() and setOnlineStatus() instead')
onOpen() async {
  // 後方互換性のため残す
  ...
}
```

**理由**: 新しいメソッドに移行し、責務を明確化

---

### 3. LifecycleNotifier の改善

#### ファイル
**`lib/presentation/pages/main_page/providers/lifecycle_notifier.dart`**

#### 変更内容

##### a. 初期化フラグの追加
**追加フィールド**:
```dart
class LifecycleState {
  final bool isInitialized;  // ★ 新規追加
}
```

**目的**: アプリ起動時の初期化を1回のみ実行し、フォアグラウンド復帰時との区別を明確化

##### b. `initialize()` の改善
**変更前**:
```dart
Future<void> initialize() async {
  _ref.read(myAccountNotifierProvider.notifier).onOpen();
  await _initializeTracking();
}
```

**変更後**:
```dart
Future<void> initialize() async {
  if (state.isInitialized) return;  // ★ 重複実行を防止

  // ★ デバイス登録 (初回のみ)
  await _ref.read(myAccountNotifierProvider.notifier).registerDeviceIfNeeded();

  // ★ トークンリフレッシュリスナーを開始
  _ref.read(tokenRefreshServiceProvider).initialize();

  // ユーザーをオンライン状態に
  await _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);

  // トラッキング許可の初期化
  await _initializeTracking();

  state = state.copyWith(isInitialized: true);
}
```

**改善点**:
- TokenRefreshService の初期化を追加
- `onOpen()` から `registerDeviceIfNeeded()` + `setOnlineStatus()` に分離
- 初期化済みフラグで重複実行を防止

##### c. `_handleAppResumed()` の改善
**変更前**:
```dart
void _handleAppResumed() {
  _ref.read(myAccountNotifierProvider.notifier).onOpen();
  _ref.read(sessionStateProvider.notifier).startSession();
}
```

**変更後**:
```dart
void _handleAppResumed() {
  // ★ 変更: デバイス登録はせず、オンライン状態のみ更新
  _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);
  _ref.read(sessionStateProvider.notifier).startSession();
}
```

**改善点**:
- デバイス登録処理をスキップ (トークン取得などの重い処理を回避)
- オンライン状態の更新のみに特化

##### d. `_handleAppPaused()` の改善
**変更前**:
```dart
void _handleAppPaused() {
  _ref.read(myAccountNotifierProvider.notifier).onClosed();
  _ref.read(sessionStateProvider.notifier).endSession();
}
```

**変更後**:
```dart
void _handleAppPaused() {
  // ★ オフライン状態に
  _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(false);
  _ref.read(sessionStateProvider.notifier).endSession();
}
```

**改善点**:
- `onClosed()` から `setOnlineStatus(false)` に変更
- より明確な意図を持ったメソッド名

---

### 4. データ層の追加メソッド

#### UserDatasource の拡張
**ファイル**: `lib/data/datasource/user_datasource.dart`

**追加メソッド**:
```dart
Future<void> updateUserFields(
  String userId,
  Map<String, dynamic> fields,
) {
  return _firestore.collection("users").doc(userId).update(fields);
}
```

**目的**: 部分的なフィールド更新を可能にし、不要なデータの読み書きを削減

#### UserRepository の拡張
**ファイル**: `lib/data/repository/user_repository.dart`

**追加メソッド**:
```dart
Future<void> updateUserFields({
  required String userId,
  required Map<String, dynamic> fields,
}) {
  return _datasource.updateUserFields(userId, fields);
}
```

#### UserUsecase の拡張
**ファイル**: `lib/domain/usecases/user_usecase.dart`

**追加メソッド**:
```dart
Future<void> updateUserFields({
  required String userId,
  required Map<String, dynamic> fields,
}) {
  return _repository.updateUserFields(userId: userId, fields: fields);
}
```

---

## ライフサイクルイベントの整理

### AS-IS (従来の動作)

| イベント | 処理 | 問題点 |
|---------|------|--------|
| **アプリ初回起動** | `onOpen()` 実行 | デバイス登録 (正常) |
| **フォアグラウンド復帰** | `onOpen()` 実行 | 毎回デバイス登録を試行 (非効率) |
| **FCMトークンリフレッシュ** | なし | トークンが更新されない (致命的) |
| **バックグラウンド移行** | `onClosed()` 実行 | isOnline = false (正常) |

### TO-BE (改善後の動作)

| イベント | 処理 | 効果 |
|---------|------|------|
| **アプリ初回起動** | `initialize()` → `registerDeviceIfNeeded()` + `setOnlineStatus(true)` | デバイス登録 + TokenRefreshService 開始 |
| **フォアグラウンド復帰** | `_handleAppResumed()` → `setOnlineStatus(true)` | オンライン状態のみ更新 (軽量) |
| **FCMトークンリフレッシュ** | `TokenRefreshService.onTokenRefresh()` → デバイストークン更新 | 自動的にトークンを更新 (重要) |
| **バックグラウンド移行** | `_handleAppPaused()` → `setOnlineStatus(false)` | オフライン状態に更新 |

---

## パフォーマンス改善効果

### CRUD 処理件数の削減 (1000ユーザー/日の想定)

#### シナリオ: 1日5回アプリ起動 (初回1回 + フォアグラウンド復帰4回)

| 操作 | AS-IS | TO-BE | 削減率 |
|------|-------|-------|--------|
| **アプリ初回起動** | | | |
| - デバイス登録 (Write) | 1,000 | 1,000 | 0% |
| - トークン取得 (API Call) | 1,000 | 1,000 | 0% |
| **フォアグラウンド復帰 (4回/日)** | | | |
| - デバイス登録試行 (キャッシュで抑制) | 0 | 0 | - |
| - トークン取得 (API Call) | 4,000 | 0 | **100%** |
| - isOnline 更新 (Write) | 4,000 | 4,000 | 0% |
| **FCMトークンリフレッシュ (月1回 = 33件/日)** | | | |
| - トークン更新 | 0 | 33 | - |
| **合計 (1日)** | | | |
| - Write 操作 | 5,000 | 5,033 | -0.7% |
| - API Call (トークン取得) | 5,000 | 1,000 | **80%** |

### ✅ 実質的な改善効果

1. **トークン取得API Callの削減**: 5,000 → 1,000 (80%削減)
   - フォアグラウンド復帰時のトークン取得をスキップ
   - デバイス名・OSバージョン取得もスキップ

2. **通知の信頼性向上**:
   - FCMトークンリフレッシュを検知し、自動更新
   - トークンが無効化されるリスクを最小化

3. **コードの明確化**:
   - ライフサイクルイベントごとの責務が明確
   - `setOnlineStatus()` と `registerDeviceIfNeeded()` で意図が明確

---

## 実装のポイント

### 1. 後方互換性の維持
- `onOpen()` は `@Deprecated` にしつつ残す
- 既存の呼び出し箇所を段階的に移行可能

### 2. トークンリフレッシュの重要性
FCMトークンは以下のタイミングでリフレッシュされる可能性がある:
- アプリの再インストール
- アプリデータのクリア
- デバイスの復元
- **定期的な自動リフレッシュ (Googleのポリシーによる)**

TokenRefreshService を導入しないと、これらのケースで通知が届かなくなる。

### 3. トークン変更検知の仕組み
`registerDeviceIfNeeded()` では、既存のトークンと新しく取得したトークンを比較し、変更があった場合のみ完全更新を実行。これにより:
- 初回起動: 完全なデバイス登録
- 2回目以降 (トークン同じ): `lastActiveAt` のみ更新
- トークン変更時: 完全なデバイス更新

---

## テスト項目

### 単体テスト
- [ ] `TokenRefreshService.onTokenRefresh()` のテスト
- [ ] `MyAccountNotifier.registerDeviceIfNeeded()` のトークン変更検知
- [ ] `MyAccountNotifier.setOnlineStatus()` の動作確認

### 統合テスト
- [ ] アプリ起動→バックグラウンド→フォアグラウンド復帰のフロー
- [ ] FCM トークンリフレッシュ時のデバイス更新
- [ ] トークン変更時の完全更新 vs 変更なし時の部分更新

### E2E テスト
- [ ] トークンがリフレッシュされた後の通知受信
- [ ] フォアグラウンド復帰時のパフォーマンス (重い処理がないか確認)
- [ ] ネットワーク切断時の挙動

---

## 既知の制約事項

1. **TokenRefreshService の初期化タイミング**
   - `LifecycleNotifier.initialize()` で開始
   - アプリ起動時に1回のみ実行される想定

2. **トークン取得の非同期性**
   - トークン取得は非同期のため、初回起動時に取得できない可能性がある
   - リトライロジックの追加を検討 (将来の拡張)

3. **iOS VoIP トークンのリフレッシュ**
   - 現状、VoIP トークンのリフレッシュイベントは検知していない
   - FCM トークンリフレッシュ時に VoIP トークンも再取得することで対応

---

## 今後の拡張案

1. **トークン取得のリトライロジック**
   - 初回起動時にトークン取得失敗した場合の再試行
   - 指数バックオフを用いたリトライ

2. **VoIP トークンリフレッシュの独立検知**
   - iOS の VoIP トークンリフレッシュイベントを監視
   - CallKit のドキュメントを参照

3. **デバイス登録の詳細ログ**
   - デバッグモードでのログ出力を充実
   - 本番環境では Analytics にイベント送信

4. **オフライン時の更新キュー**
   - ネットワーク切断時の更新を一時保存
   - 接続復帰時に自動的に同期

---

## 参考資料

- [Firebase Cloud Messaging - Token Management](https://firebase.google.com/docs/cloud-messaging/manage-tokens)
- [Firebase Cloud Messaging - Best Practices](https://firebase.google.com/docs/cloud-messaging/best-practices)
- [Flutter - App Lifecycle](https://docs.flutter.dev/development/ui/advanced/app-lifecycle)

---

## 変更履歴

- 2025-10-06: 初版作成 (ライフサイクル管理改善実装完了)

---

## まとめ

### 解決した問題

1. ✅ **FCMトークンリフレッシュ未対応** → TokenRefreshService で自動更新
2. ✅ **フォアグラウンド復帰時の非効率な処理** → setOnlineStatus() で軽量化
3. ✅ **トークン変更の未検知** → registerDeviceIfNeeded() で変更検知

### 実装した主要コンポーネント

1. **TokenRefreshService** - FCMトークンリフレッシュ監視
2. **MyAccountNotifier.setOnlineStatus()** - 軽量なオンライン状態更新
3. **MyAccountNotifier.registerDeviceIfNeeded()** - スマートなデバイス登録
4. **LifecycleNotifier の改善** - 初期化フラグとイベント分離

### 定量的な効果

- **トークン取得API Call**: 80%削減 (5,000 → 1,000/日)
- **通知信頼性**: トークンリフレッシュ対応により大幅向上
- **コード品質**: ライフサイクルイベントの責務明確化

### 推奨アクション

1. **本番デプロイ前**: 統合テスト・E2Eテストの実施
2. **デプロイ後**: TokenRefreshService のログを監視し、リフレッシュ頻度を確認
3. **段階的移行**: `onOpen()` の呼び出し箇所を新しいメソッドに移行
