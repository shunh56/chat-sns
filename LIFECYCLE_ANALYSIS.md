# アプリライフサイクルとデバイストークン管理の分析レポート

## 現状の問題点

### 1. デバイス情報登録のタイミング

#### 現在の実装
```dart
// lifecycle_notifier.dart:45
void initialize() {
  _ref.read(myAccountNotifierProvider.notifier).onOpen();
}

// lifecycle_notifier.dart:88
void _handleAppResumed() {
  _ref.read(myAccountNotifierProvider.notifier).onOpen();
}
```

**問題:**
- ✗ アプリ初回起動時のみ `initialize()` が呼ばれる
- ✗ バックグラウンド→フォアグラウンド復帰時も `onOpen()` が呼ばれる
- ✗ **毎回デバイス情報を登録しようとする** (キャッシュで抑制されているが非効率)

### 2. FCM トークンリフレッシュの未対応

#### 現在の実装
**FCM トークンリフレッシュのリスナーが存在しない**

```dart
// notification_service.dart には onTokenRefresh のリスナーがない
```

**問題:**
- ✗ FCM トークンが更新されても Firestore に反映されない
- ✗ iOS で VoIP トークンが変更されても検知できない
- ✗ トークンが無効化されると通知が届かなくなる

### 3. デバイス情報更新の頻度制御

#### 現在の実装
```dart
// my_user_account_notifier.dart:159
final shouldUpdate = await cache.shouldUpdate(deviceId, interval: Duration(hours: 1));
if (!shouldUpdate) return;
```

**良い点:**
- ✅ 1時間に1回のみ更新 (Firestore Write を削減)

**問題:**
- ✗ アプリがバックグラウンド→フォアグラウンドの度にチェック処理が走る
- ✗ 本当に必要なタイミング (トークンリフレッシュ時) に更新されない

### 4. トークン取得タイミングの問題

#### 現在の実装
```dart
// my_user_account_notifier.dart:171-174
final fcmToken = await FirebaseMessaging.instance.getToken();
final voipToken = Platform.isIOS
    ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
    : null;
```

**問題:**
- ✗ アプリ起動の度にトークンを取得 (重複処理)
- ✗ トークンが変更されたかどうかをチェックしていない
- ✗ トークン取得失敗時のリトライがない

---

## 改善案

### 1. ライフサイクルイベントの整理

#### 推奨されるタイミング

| イベント | 現状 | 推奨 | 理由 |
|---------|------|------|------|
| **アプリ初回起動** | デバイス登録 | ✅ デバイス登録 | 初回は必須 |
| **フォアグラウンド復帰** | デバイス登録 (キャッシュで抑制) | ❌ isOnline のみ更新 | デバイス情報は変わらない |
| **トークンリフレッシュ** | なし | ✅ デバイス情報更新 | トークン変更時は必須 |
| **アプリアップデート後** | なし | ✅ デバイス情報更新 | バージョン情報の更新 |
| **バックグラウンド移行** | isOnline = false | ✅ isOnline = false | オフライン状態に |

### 2. 改善後のフロー

```
[アプリ起動]
  ↓
[デバイスID確認]
  ↓
[既存デバイス?] → YES → [トークン変更チェック] → 変更なし → [isOnline = true のみ更新]
  ↓ NO                                          ↓ 変更あり
[新規デバイス登録]                               [デバイス情報更新]

[FCM トークンリフレッシュイベント]
  ↓
[新しいトークンを取得]
  ↓
[デバイス情報を更新]

[フォアグラウンド復帰]
  ↓
[isOnline = true のみ更新] (デバイス情報は更新しない)

[バックグラウンド移行]
  ↓
[isOnline = false のみ更新]
```

---

## 具体的な実装改善

### 1. FCM トークンリフレッシュリスナーの追加

#### 新規ファイル: `lib/presentation/services/token_refresh_service.dart`

```dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenRefreshServiceProvider = Provider((ref) => TokenRefreshService(ref));

class TokenRefreshService {
  final Ref _ref;

  TokenRefreshService(this._ref);

  /// トークンリフレッシュリスナーを初期化
  void initialize() {
    // FCM トークンリフレッシュを監視
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// トークンがリフレッシュされた時の処理
  Future<void> _onTokenRefresh(String newToken) async {
    print('[TokenRefresh] FCM token refreshed: $newToken');

    // VoIP トークンも取得 (iOS のみ)
    String? voipToken;
    if (Platform.isIOS) {
      voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    }

    // デバイス情報を更新
    await _updateDeviceTokens(
      fcmToken: newToken,
      voipToken: voipToken,
    );
  }

  /// デバイストークンを更新
  Future<void> _updateDeviceTokens({
    required String? fcmToken,
    required String? voipToken,
  }) async {
    try {
      final deviceIdGenerator = _ref.read(deviceIdGeneratorProvider);
      final deviceId = await deviceIdGenerator.generateDeviceId();

      final deviceRepository = _ref.read(deviceRepositoryProvider);
      final userId = _ref.read(authProvider).currentUser!.uid;

      // トークンのみを更新 (他のフィールドは変更しない)
      await deviceRepository.updateDeviceTokens(
        userId: userId,
        deviceId: deviceId,
        fcmToken: fcmToken,
        voipToken: voipToken,
      );

      print('[TokenRefresh] Device tokens updated successfully');
    } catch (e) {
      print('[TokenRefresh] Failed to update device tokens: $e');
    }
  }
}
```

### 2. LifecycleNotifier の改善

```dart
class LifecycleNotifier extends StateNotifier<LifecycleState> {
  final Ref _ref;
  bool _isInitialized = false;

  LifecycleNotifier(this._ref) : super(const LifecycleState());

  /// 初期化処理 (アプリ起動時のみ1回)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // ★ デバイス登録 (初回のみ)
    await _ref.read(myAccountNotifierProvider.notifier).registerDeviceIfNeeded();

    // ★ トークンリフレッシュリスナーを開始
    _ref.read(tokenRefreshServiceProvider).initialize();

    // ユーザーをオンライン状態に
    await _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);

    // トラッキング許可の初期化
    await _initializeTracking();

    _isInitialized = true;
  }

  /// アプリがフォアグラウンドに戻った時の処理
  void _handleAppResumed() {
    // ★ 変更: デバイス登録はせず、オンライン状態のみ更新
    _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(true);

    // セッションを開始
    _ref.read(sessionStateProvider.notifier).startSession();
  }

  /// アプリがバックグラウンドに移った時の処理
  void _handleAppPaused() {
    // ★ オフライン状態に
    _ref.read(myAccountNotifierProvider.notifier).setOnlineStatus(false);

    // セッションを終了
    _ref.read(sessionStateProvider.notifier).endSession();
  }
}
```

### 3. MyAccountNotifier の改善

```dart
class MyAccountNotifier extends StateNotifier<AsyncValue<UserAccount>> {

  /// デバイス登録 (初回またはトークン変更時のみ)
  Future<void> registerDeviceIfNeeded() async {
    final user = state.asData!.value;

    try {
      // 1. デバイスIDを取得
      final deviceIdGenerator = ref.read(deviceIdGeneratorProvider);
      final deviceId = await deviceIdGenerator.generateDeviceId();

      // 2. 既存デバイスをチェック
      final deviceRepository = ref.read(deviceRepositoryProvider);
      final existingDevice = await deviceRepository.getDevice(user.userId, deviceId);

      // 3. トークンを取得
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final voipToken = Platform.isIOS
          ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
          : null;

      // 4. トークンが変更されたかチェック
      final tokensChanged = existingDevice == null ||
          existingDevice.fcmToken != fcmToken ||
          existingDevice.voipToken != voipToken;

      if (tokensChanged) {
        // トークンが変更された場合のみ更新
        await _registerOrUpdateDevice(user.userId);
        print('[DeviceRegistration] Device registered/updated');
      } else {
        // トークンが同じ場合は lastActiveAt のみ更新 (キャッシュチェック付き)
        final cache = ref.read(deviceUpdateCacheProvider);
        final shouldUpdate = await cache.shouldUpdate(deviceId, interval: Duration(hours: 1));

        if (shouldUpdate) {
          await deviceRepository.updateDeviceLastActive(user.userId, deviceId);
          await cache.saveLastUpdateTime(deviceId, DateTime.now());
          print('[DeviceRegistration] LastActiveAt updated');
        }
      }
    } catch (e) {
      print('[DeviceRegistration] Error: $e');
    }
  }

  /// オンライン状態を設定 (軽量な更新)
  Future<void> setOnlineStatus(bool isOnline) async {
    final user = state.asData?.value;
    if (user == null) return;

    // ★ ローカル状態を即座に更新
    final updatedUser = user.copyWith(
      isOnline: isOnline,
      lastOpenedAt: Timestamp.now(),
    );
    state = AsyncValue.data(updatedUser);

    // ★ Firestore は isOnline と lastOpenedAt のみ更新
    try {
      await ref.read(firestoreProvider)
        .collection('users')
        .doc(user.userId)
        .update({
          'isOnline': isOnline,
          'lastOpenedAt': FieldValue.serverTimestamp(),
        });
    } catch (e) {
      print('[OnlineStatus] Failed to update: $e');
    }
  }

  // 既存の onOpen() は非推奨に
  @Deprecated('Use registerDeviceIfNeeded() and setOnlineStatus() instead')
  onOpen() async {
    // 後方互換性のため残す
  }

  // 既存の onClosed() も改善
  onClosed() async {
    await setOnlineStatus(false);
  }
}
```

### 4. 初期化フローの改善

```dart
// main_page_wrapper.dart
class MainPageWrapper extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycleNotifier = ref.read(lifecycleNotifierProvider.notifier);

    // ★ 初期化は1回のみ
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await lifecycleNotifier.initialize();
      });
      return null;
    }, const []);

    // アプリライフサイクル監視 (既存のまま)
    useEffect(() {
      void handleLifecycleChange() {
        final state = WidgetsBinding.instance.lifecycleState;
        if (state != null) {
          lifecycleNotifier.onLifecycleStateChanged(state);
        }
      }

      WidgetsBinding.instance.addObserver(_LifecycleObserver(handleLifecycleChange));
      return () {};
    }, const []);

    return Scaffold(...);
  }
}
```

---

## CRUD 処理件数の再計算

### シナリオ: 1000ユーザー、1日5回アプリ起動、トークンリフレッシュは月1回

| 操作 | 現状 | 改善後 | 削減率 |
|------|------|--------|--------|
| **アプリ起動時** | | | |
| - デバイス登録 (初回のみ) | 1,000 Write | 1,000 Write | 0% |
| - フォアグラウンド復帰 (2-5回目) | 0 Write (キャッシュ) | 0 Write | - |
| - isOnline 更新 | 4,000 Write | 4,000 Write | 0% |
| **トークンリフレッシュ** | | | |
| - 月1回 (1000ユーザー / 30日) | 0 Write | 33 Write/日 | - |
| **合計 (1日)** | 5,000 Write | 5,033 Write | -0.7% |

### ✅ 実質的な改善点

1. **正しいタイミングで更新**: トークンリフレッシュ時に確実に更新される
2. **通知の信頼性向上**: トークンが常に最新の状態に保たれる
3. **コードの明確化**: ライフサイクルイベントの責務が明確になる

---

## 実装優先度

### 🔴 高優先度 (即座に実装すべき)
1. **TokenRefreshService の追加** - FCM トークンリフレッシュ対応
2. **setOnlineStatus() の分離** - 軽量なオンライン状態更新

### 🟡 中優先度 (近日中に実装)
3. **registerDeviceIfNeeded() の改善** - トークン変更チェック
4. **LifecycleNotifier の改善** - 初期化フラグの追加

### 🟢 低優先度 (余裕があれば)
5. **トークン取得のリトライロジック** - 失敗時の再試行
6. **デバイス情報のバージョン管理** - アプリ更新時の自動更新

---

## テスト項目

### 単体テスト
- [ ] TokenRefreshService.onTokenRefresh() のテスト
- [ ] MyAccountNotifier.registerDeviceIfNeeded() のトークン変更検知
- [ ] キャッシュロジックの動作確認

### 統合テスト
- [ ] アプリ起動→バックグラウンド→フォアグラウンド復帰のフロー
- [ ] FCM トークンリフレッシュ時のデバイス更新
- [ ] 複数デバイスでの同時ログイン

### E2E テスト
- [ ] トークンが無効化された状態での通知受信
- [ ] アプリアップデート後のデバイス情報更新
- [ ] ネットワーク切断時の挙動

---

## まとめ

### 現状の問題
- ✗ FCM トークンリフレッシュに未対応 → 通知が届かなくなるリスク
- ✗ フォアグラウンド復帰の度にデバイス登録処理が走る → 非効率
- ✗ ライフサイクルイベントの責務が不明確

### 改善後
- ✅ FCM トークンリフレッシュを検知して自動更新
- ✅ フォアグラウンド復帰時は isOnline のみ更新
- ✅ ライフサイクルイベントの責務が明確

### 推奨アクション
1. **TokenRefreshService を追加** (最優先)
2. **setOnlineStatus() を分離** (高優先度)
3. **段階的にリファクタリング** (後方互換性を維持)
