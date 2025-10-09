# アーキテクチャレビュー: ライフサイクル管理改善の精査結果

## 概要
ライフサイクル管理改善の実装を精査し、クリーンアーキテクチャ違反と状態管理の問題を発見・修正しました。

## レビュー日
2025-10-06

---

## 発見した問題点と修正内容

### 1. ❌ クリーンアーキテクチャ違反 (Critical)

#### 問題: Presentation層からData層への直接アクセス

**修正前の問題コード**:
```dart
// MyAccountNotifier (Presentation層)
final deviceRepository = ref.read(deviceRepositoryProvider);  // ✗ Data層へ直接アクセス
await deviceRepository.getDevice(user.userId, deviceId);
```

**アーキテクチャ違反の図**:
```
Presentation (MyAccountNotifier)
    ↓ ✗ 直接アクセス
Data (DeviceRepository)
```

**正しいアーキテクチャ**:
```
Presentation (MyAccountNotifier)
    ↓
Domain (DeviceManagementUsecase)  ← ★ 追加
    ↓
Data (DeviceRepository)
```

#### 解決策: DeviceManagementUsecase の作成

**新規ファイル**: `lib/domain/usecases/device_management_usecase.dart`

**責務**:
- デバイス登録・更新のビジネスロジック
- トークン変更検知
- キャッシュ制御
- デバイス詳細情報の取得

**主要メソッド**:
```dart
class DeviceManagementUsecase {
  /// デバイス登録 (初回またはトークン変更時のみ)
  Future<DeviceRegistrationResult> registerDeviceIfNeeded(String userId);

  /// デバイストークンを更新 (TokenRefreshService から呼ばれる)
  Future<void> updateDeviceTokens({
    required String userId,
    required String? fcmToken,
    required String? voipToken,
  });
}
```

**修正後のコード**:
```dart
// MyAccountNotifier (Presentation層)
final deviceManagementUsecase = ref.read(deviceManagementUsecaseProvider);  // ✅ UseCase経由
final result = await deviceManagementUsecase.registerDeviceIfNeeded(user.userId);
```

---

### 2. ❌ 状態管理の不整合 (Critical)

#### 問題: activeDevices の状態が更新されない

**修正前の問題コード**:
```dart
// registerDeviceIfNeeded() 内
if (tokensChanged) {
  await _registerOrUpdateDevice(user.userId);  // Firestore更新
  final updatedUser = user.copyWith(fcmToken: fcmToken, voipToken: voipToken);
  state = AsyncValue.data(updatedUser);  // ✗ activeDevices が更新されていない
}
```

**問題の詳細**:
- `_registerOrUpdateDevice()` で Firestore の `activeDevices` を更新
- しかし、ローカルの `state` には `fcmToken`, `voipToken` のみ反映
- `activeDevices` フィールドが古いままになる

#### 解決策: Firestoreから再取得して状態を同期

**修正後のコード**:
```dart
if (result.deviceUpdated) {
  // ★ UserAccount を再取得して activeDevices を含めて更新
  final updatedUserAccount = await usecase.getUserByUid(user.userId);
  if (updatedUserAccount != null && mounted) {
    state = AsyncValue.data(updatedUserAccount);
    ref.read(allUsersNotifierProvider.notifier).addUserAccounts([updatedUserAccount]);
  }
}
```

**改善効果**:
- Firestoreの最新データを取得することで、`activeDevices` を含む全フィールドが同期される
- 通知送信時に `activeDevices` が正しく取得できる

---

### 3. ❌ 責務の混在 (Medium)

#### 問題: MyAccountNotifier が複数の責務を持つ

**修正前の責務**:
1. ユーザーアカウント状態管理
2. デバイス登録・更新ロジック ← これが混在
3. トークン管理 ← これが混在

**修正後の責務分離**:

| レイヤー | クラス | 責務 |
|---------|-------|------|
| **Presentation** | `MyAccountNotifier` | ユーザーアカウント状態管理のみ |
| **Domain** | `DeviceManagementUsecase` | デバイス登録・更新のビジネスロジック |
| **Data** | `DeviceRepository` | Firestore CRUD操作 |

**改善効果**:
- 単一責任の原則 (SRP) を遵守
- テストが容易になる
- 変更の影響範囲が限定される

---

### 4. ❌ onClosed() の非効率な実装 (Minor)

#### 問題: 全フィールドを更新していた

**修正前のコード**:
```dart
onClosed() {
  final user = state.asData!.value;
  final updatedUser = user.copyWith(isOnline: false, lastOpenedAt: Timestamp.now());
  state = AsyncValue.data(updatedUser);
  update(updatedUser);  // ✗ updateUser() を呼ぶので全フィールドを更新
}
```

**問題点**:
- `update(updatedUser)` は `usecase.updateUser()` を呼び出す
- `updateUser()` は UserAccount の全フィールドを Firestore に書き込む
- オンライン状態の変更だけなのに、全フィールドの更新は非効率

#### 解決策: setOnlineStatus() に委譲

**修正後のコード**:
```dart
@Deprecated('Use setOnlineStatus(false) instead')
onClosed() {
  setOnlineStatus(false);  // ✅ isOnline と lastOpenedAt のみ更新
}
```

**改善効果**:
- Firestore への書き込みを最小限に抑える (2フィールドのみ)
- コードの意図が明確になる

---

### 5. ✅ TokenRefreshService のアーキテクチャ改善

#### 問題: Data層への直接アクセス

**修正前のコード**:
```dart
// TokenRefreshService (Presentation層)
final deviceRepository = ref.read(deviceRepositoryProvider);  // ✗ Data層へ直接アクセス
await deviceRepository.updateDeviceTokens(...);
```

#### 修正後のコード:
```dart
// TokenRefreshService (Presentation層)
final deviceManagementUsecase = ref.read(deviceManagementUsecaseProvider);  // ✅ UseCase経由
await deviceManagementUsecase.updateDeviceTokens(...);
```

---

## クリーンアーキテクチャの遵守状況

### 修正前の依存関係 ❌
```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│  - MyAccountNotifier                │
│  - TokenRefreshService              │
└────────────┬────────────────────────┘
             │ ✗ 直接アクセス
             ↓
┌─────────────────────────────────────┐
│   Data Layer                        │
│  - DeviceRepository                 │
│  - UserRepository                   │
└─────────────────────────────────────┘
```

**問題点**:
- Presentation層がData層に直接依存
- Domain層(UseCase)をバイパス
- ビジネスロジックがPresentation層に漏れ出る

### 修正後の依存関係 ✅
```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│  - MyAccountNotifier                │
│  - TokenRefreshService              │
│  - LifecycleNotifier                │
└────────────┬────────────────────────┘
             │ ✅ UseCase経由
             ↓
┌─────────────────────────────────────┐
│   Domain Layer                      │
│  - DeviceManagementUsecase (新規)   │
│  - UserUsecase                      │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│   Data Layer                        │
│  - DeviceRepository                 │
│  - UserRepository                   │
│  - DeviceDatasource                 │
│  - UserDatasource                   │
└─────────────────────────────────────┘
```

**改善点**:
- ✅ 各層の依存関係が正しい方向 (Presentation → Domain → Data)
- ✅ ビジネスロジックがDomain層に集約
- ✅ Presentation層はUseCaseのインターフェースのみに依存

---

## 状態管理フローの整理

### 1. アプリ初回起動時のフロー

```
[LifecycleNotifier.initialize()]
    ↓
[MyAccountNotifier.registerDeviceIfNeeded()]
    ↓
[DeviceManagementUsecase.registerDeviceIfNeeded()]
    ↓
[トークン取得 & デバイス情報作成]
    ↓
[DeviceRepository.registerOrUpdateDevice()]
    ↓
[Firestore: users/{userId}/devices/{deviceId} 作成]
    ↓
[Firestore: users/{userId}.activeDevices 更新]
    ↓
[MyAccountNotifier: getUserByUid() で再取得] ← ★ 重要
    ↓
[state = AsyncValue.data(updatedUserAccount)] ← activeDevices を含む最新状態
```

**ポイント**:
- デバイス登録後、`getUserByUid()` でFirestoreから再取得
- これにより `activeDevices` が正しく状態に反映される

### 2. フォアグラウンド復帰時のフロー

```
[LifecycleNotifier._handleAppResumed()]
    ↓
[MyAccountNotifier.setOnlineStatus(true)]
    ↓
[ローカル状態を即座に更新]
    ↓
[UserUsecase.updateUserFields(isOnline: true, lastOpenedAt: now)]
    ↓
[Firestore: users/{userId} の2フィールドのみ更新]
```

**ポイント**:
- デバイス登録をスキップ (軽量)
- 2フィールドのみの更新で高速

### 3. FCMトークンリフレッシュ時のフロー

```
[FirebaseMessaging.onTokenRefresh]
    ↓
[TokenRefreshService._onTokenRefresh()]
    ↓
[DeviceManagementUsecase.updateDeviceTokens()]
    ↓
[DeviceRepository.updateDeviceTokens()]
    ↓
[Firestore: users/{userId}/devices/{deviceId} のトークンを更新]
    ↓
[Firestore: users/{userId}.activeDevices を更新] ← キャッシュ同期
```

**ポイント**:
- 自動的にトークンを更新
- `activeDevices` キャッシュも同時に更新

---

## エラーハンドリングの改善

### 修正前の問題
```dart
try {
  ...
} catch (e) {
  print('Error: $e');  // ✗ 本番環境でもログ出力
}
```

### 修正後の改善
```dart
try {
  ...
} catch (e) {
  if (kDebugMode) {  // ✅ デバッグモードのみログ出力
    print('[DeviceRegistration] Error: $e');
  }
  throw DeviceManagementException('デバイス登録に失敗しました: $e');  // ✅ カスタム例外
}
```

**改善点**:
- `kDebugMode` でログ出力を制御
- カスタム例外 (`DeviceManagementException`) を投げる
- エラーの発生箇所をタグで明示 (`[DeviceRegistration]`)

---

## テスト容易性の向上

### 修正前: テストが困難
```dart
class MyAccountNotifier {
  // ✗ Data層に直接依存しているため、モックが困難
  final deviceRepository = ref.read(deviceRepositoryProvider);

  // ✗ ビジネスロジックが混在しているため、単体テスト時に複雑な準備が必要
  Future<void> registerDeviceIfNeeded() {
    // デバイス詳細取得、トークン取得、キャッシュチェック、Firestore更新...
  }
}
```

### 修正後: テストが容易
```dart
// DeviceManagementUsecase (独立してテスト可能)
class DeviceManagementUsecaseTest {
  test('トークン変更時にデバイスを更新する', () async {
    // Arrange
    final mockRepository = MockDeviceRepository();
    final usecase = DeviceManagementUsecase(mockRepository, ...);

    // Act
    final result = await usecase.registerDeviceIfNeeded('user123');

    // Assert
    expect(result.deviceUpdated, true);
    verify(mockRepository.registerOrUpdateDevice(...)).called(1);
  });
}

// MyAccountNotifier (UseCase をモック化してテスト)
class MyAccountNotifierTest {
  test('registerDeviceIfNeeded が UseCase を呼び出す', () async {
    // Arrange
    final mockUsecase = MockDeviceManagementUsecase();
    when(mockUsecase.registerDeviceIfNeeded(any)).thenReturn(
      DeviceRegistrationResult(deviceUpdated: true, ...),
    );

    // Act
    await notifier.registerDeviceIfNeeded();

    // Assert
    verify(mockUsecase.registerDeviceIfNeeded('user123')).called(1);
  });
}
```

---

## パフォーマンスへの影響

### 懸念: getUserByUid() による追加のFirestore Read

**修正前**:
```dart
if (tokensChanged) {
  await _registerOrUpdateDevice(user.userId);  // 1 Write
  state = AsyncValue.data(user.copyWith(...));  // 0 Read
}
```

**修正後**:
```dart
if (result.deviceUpdated) {
  final updatedUserAccount = await usecase.getUserByUid(user.userId);  // +1 Read
  state = AsyncValue.data(updatedUserAccount);
}
```

**追加コスト**: +1 Read (トークン変更時のみ)

### 影響分析

| シナリオ | 頻度 | 追加コスト |
|---------|------|-----------|
| **アプリ初回起動** | 1回/デバイス | +1 Read |
| **トークンリフレッシュ** | 月1回程度 | +1 Read |
| **フォアグラウンド復帰** | 多頻度 | 0 Read (変更なし) |

**結論**:
- トークン変更時のみの追加コストなので、実質的な影響は小さい
- 状態の一貫性を保つためには必要なコスト
- キャッシュ(HiveUserDataSource)により、実際のFirestore Readは削減される可能性がある

### 最適化案 (将来)
```dart
// activeDevices を直接取得してローカル状態を更新
if (result.deviceUpdated) {
  final activeSummaries = await deviceManagementUsecase.getActiveDeviceSummaries(user.userId);
  final updatedUser = user.copyWith(
    fcmToken: result.fcmToken,
    voipToken: result.voipToken,
    activeDevices: activeSummaries,
    devicesUpdatedAt: Timestamp.now(),
  );
  state = AsyncValue.data(updatedUser);
}
```

これにより、ユーザードキュメント全体を取得せず、activeDevices のみを取得できる。

---

## まとめ

### ✅ 修正により解決した問題

| 問題 | 修正前 | 修正後 |
|------|--------|--------|
| **クリーンアーキテクチャ違反** | Presentation → Data 直接アクセス | Presentation → Domain → Data |
| **状態管理の不整合** | activeDevices が更新されない | getUserByUid() で再取得し同期 |
| **責務の混在** | MyAccountNotifier に複数の責務 | DeviceManagementUsecase に分離 |
| **非効率な onClosed()** | 全フィールドを更新 | 2フィールドのみ更新 |
| **エラーハンドリング** | 本番環境でもログ出力 | kDebugMode で制御 |

### ✅ クリーンアーキテクチャの遵守

- **Presentation層**: ビジネスロジックを含まず、UseCaseを呼び出すのみ
- **Domain層**: ビジネスロジックを集約 (`DeviceManagementUsecase`)
- **Data層**: Firestore CRUD操作のみ

### ✅ 状態管理の整合性

- デバイス登録後、Firestoreから最新データを再取得
- `activeDevices` を含む全フィールドが正しく同期される
- 通知送信時に正しいデバイスリストが取得できる

### ✅ テスト容易性

- UseCase が独立してテスト可能
- Presentation層はUseCaseをモック化してテスト可能
- ビジネスロジックの単体テストが容易

---

## 今後の改善案

### 1. パフォーマンス最適化
- `getUserByUid()` の代わりに `getActiveDeviceSummaries()` を使用
- Firestore Read を削減

### 2. エラーハンドリングの強化
- カスタム例外の種類を増やす (`TokenRetrievalException`, `DeviceUpdateException`)
- エラー発生時のリトライロジック

### 3. ロギングの改善
- 本番環境では Firebase Analytics や Crashlytics にイベント送信
- デバッグ環境のみ詳細ログを出力

### 4. キャッシュ戦略の最適化
- Hive キャッシュの有効活用
- `getUserByUid()` のキャッシュヒット率を高める

---

## 変更履歴

- 2025-10-06: 初版作成 (アーキテクチャレビュー完了)

---

## 参考資料

- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/reading)
- [Flutter State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
