# Footprint機能 技術仕様書

## 目次
1. [概要](#概要)
2. [システムアーキテクチャ](#システムアーキテクチャ)
3. [データ構造](#データ構造)
4. [機能仕様](#機能仕様)
5. [API仕様](#api仕様)
6. [UI/UX仕様](#uiux仕様)
7. [エラーハンドリング](#エラーハンドリング)
8. [パフォーマンス最適化](#パフォーマンス最適化)
9. [セキュリティ](#セキュリティ)
10. [将来の拡張](#将来の拡張)

---

## 概要

### 機能の目的
ユーザーが他のユーザーのプロフィールを訪問した際に、その訪問履歴（足あと）を記録し、双方が確認できる機能。SNSにおけるユーザー間のインタラクションを促進する。

### 主要機能
- プロフィール訪問時の自動足あと記録
- 訪問者リストの表示（自分を訪問したユーザー）
- 訪問先リストの表示（自分が訪問したユーザー）
- 未読足あと数の表示
- 足あとの既読管理
- 足あとの削除
- 統計情報の表示（24時間/1週間/1ヶ月の訪問者数など）

---

## システムアーキテクチャ

### クリーンアーキテクチャの適用

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │   Screen    │→ │   Provider   │→ │    Manager     │ │
│  │ (UI/Widget) │  │  (State)     │  │  (Composite)   │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────┐
│                      Domain Layer                        │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │  Use Case   │→ │ IRepository  │  │    Entity      │ │
│  │  (Logic)    │  │ (Interface)  │  │    (Model)     │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────┐
│                       Data Layer                         │
│  ┌─────────────┐  ┌──────────────┐                      │
│  │ Repository  │→ │  Datasource  │→ Firebase Firestore  │
│  │    Impl     │  │  (Firebase)  │                      │
│  └─────────────┘  └──────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

### レイヤー間の責務

#### Presentation Layer
- **Screen**: UI表示、ユーザーインタラクション処理
- **Provider**: 状態管理（Riverpod）、ストリームデータのバインディング
- **Manager**: 複数のプロバイダーを統合した操作インターフェース

#### Domain Layer
- **UseCase**: ビジネスロジックの実装、単一責任の原則
- **IRepository**: データアクセスの抽象インターフェース
- **Entity**: ドメインモデル、ビジネスルール

#### Data Layer
- **Repository Impl**: IRepositoryの具体的実装
- **Datasource**: Firebase Firestoreへの直接アクセス

---

## データ構造

### Entity構成

```
domain/entity/footprint/
  ├── footprint.dart              # 個別の足あと記録Entity
  └── footprint_statistics.dart   # 統計情報Entity
```

### Firestore データベーススキーマ

**設計変更（v1.2.0）: ドキュメントIDをランダムIDに変更**

```
users/{userId}/
  ├── footprinteds/        # 自分を訪問したユーザー（訪問者）
  │   └── {randomDocId}    # Firestoreの自動生成ID（訪問ごとにユニーク）
  │       ├── visitorId: string      # 訪問者のユーザーID
  │       ├── visitedUserId: string  # 訪問されたユーザーID
  │       ├── visitedAt: timestamp   # 訪問日時
  │       └── isSeen: boolean        # 既読フラグ
  │
  └── footprints/          # 自分が訪問したユーザー（訪問先）
      └── {randomDocId}    # Firestoreの自動生成ID（訪問ごとにユニーク）
          ├── visitorId: string      # 訪問者のユーザーID（自分）
          ├── visitedUserId: string  # 訪問先のユーザーID
          ├── visitedAt: timestamp   # 訪問日時
          └── isSeen: boolean        # 既読フラグ（訪問履歴は常にtrue）
```

**設計変更の理由:**
- 従来: ドキュメントID = userId → 同じユーザーの訪問は更新のみ
- 新設計: ドキュメントID = ランダムID → 訪問ごとに新規記録
- メリット: 正確な訪問回数、時間帯分布、訪問履歴の完全性が保証される

### Entityモデル

#### Footprint Entity

**設計変更（v1.2.0）:**

```dart
class Footprint {
  final String id;               // ドキュメントID（Firestoreの自動生成ID）
  final String visitorId;        // 足あとを残したユーザーID
  final String visitedUserId;    // 足あとをつけられたユーザーID
  final Timestamp visitedAt;     // 訪問日時
  final bool isSeen;             // 既読状態（デフォルト: false）

  factory Footprint.fromFirestore(String docId, Map<String, dynamic> json);
}
```

**変更点:**
- `userId` → `visitorId` / `visitedUserId`（明確化）
- `count`フィールドを削除（訪問回数はドキュメント数でカウント）
- `updatedAt` → `visitedAt`（より正確な命名）
- `id`フィールド追加（ドキュメントIDを明示的に保持）
- `fromFirestore`メソッドでドキュメントIDを受け取る

#### FootprintStatistics Entity
```dart
class FootprintStatistics {
  final int last24Hours;                    // 過去24時間の訪問者数
  final int lastWeek;                       // 過去1週間の訪問者数
  final int lastMonth;                      // 過去1ヶ月の訪問者数
  final int unseenCount;                    // 未読の訪問者数
  final Map<int, int> hourlyDistribution;   // 時間帯別分布 (hour: count)
  final List<String> frequentVisitors;      // 頻繁な訪問者（上位5人）

  // ビジネスロジック
  bool get hasNewVisitors;                  // 新しい訪問者がいるか
  bool get hasRecentActivity;               // 最近のアクティビティがあるか
  bool get isPopular;                       // 人気があるか（24時間で10人以上）
  int? get peakHour;                        // ピークの時間帯
  double get weeklyGrowthRate;              // 週次成長率（%）
  double get monthlyGrowthRate;             // 月次成長率（%）
  VisitorTrend get trend;                   // 訪問者の傾向
}

enum VisitorTrend {
  rising,   // 増加傾向
  stable,   // 安定
  falling,  // 減少傾向
}
```

---

## 機能仕様

### 1. プロフィール訪問時の足あと記録

#### トリガー
- ユーザーが他のユーザーのプロフィールページを表示した時

#### 処理フロー（v1.2.0更新）
```
1. VisitProfileUsecase.leaveFootprint(UserAccount) を呼び出し
   ↓
2. Repository.visitProfile(targetUserId) を実行
   ↓
3. Datasource.addFootprint(userId) でFirestoreに記録
   ↓
4. バッチ処理で以下を同時実行（アトミック）:
   - 訪問者側: users/{myUserId}/footprints/{自動生成ID} に新規作成
     * visitorId: myUserId
     * visitedUserId: targetUserId
     * visitedAt: 現在時刻
     * isSeen: true（自分の訪問履歴は常に既読）

   - 訪問先側: users/{targetUserId}/footprinteds/{自動生成ID} に新規作成
     * visitorId: myUserId
     * visitedUserId: targetUserId
     * visitedAt: 現在時刻
     * isSeen: false（相手への通知は未読）
```

**重要な設計変更:**
- ドキュメントIDが自動生成されるため、同じユーザーが複数回訪問しても全て記録される
- `FieldValue.increment(1)`を使わず、訪問回数はドキュメント数でカウント
- `SetOptions(merge: true)`を使わず、常に新規作成

#### バリデーション
- 自分自身のプロフィールは記録しない（`myUserId == targetUserId`）
- ログインユーザーIDが空の場合は記録しない

#### Firestoreバッチ処理（v1.2.0更新）
```dart
final batch = _firestore.batch();
final ts = Timestamp.now();

// 自分の訪問履歴（自動生成IDで新規作成）
final myFootprintRef = _firestore
  .collection("users")
  .doc(myUid)
  .collection(footprints)
  .doc(); // 自動生成ID

batch.set(myFootprintRef, {
  "visitorId": myUid,
  "visitedUserId": userId,
  "visitedAt": ts,
  "isSeen": true,
});

// 相手の訪問者履歴（自動生成IDで新規作成）
final theirFootprintedRef = _firestore
  .collection("users")
  .doc(userId)
  .collection(footprinteds)
  .doc(); // 自動生成ID

batch.set(theirFootprintedRef, {
  "visitorId": myUid,
  "visitedUserId": userId,
  "visitedAt": ts,
  "isSeen": false,
});

await batch.commit();
```

---

### 2. 訪問者リスト取得（自分を訪問したユーザー）

#### データソース
- `users/{myUserId}/footprinteds`コレクション

#### 取得方法

##### 全期間の訪問者（getVisitorsStream）v1.2.0更新
```dart
Stream<List<Footprint>> getVisitorsStream() {
  return _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .orderBy("visitedAt", descending: true)  // visitedAtに変更
    .snapshots()
    .map((snapshot) =>
      snapshot.docs.map((doc) =>
        Footprint.fromFirestore(doc.id, doc.data())  // fromFirestoreに変更
      ).toList()
    );
}
```

##### 過去24時間の訪問者（getRecentVisitorsStream）v1.2.0更新
```dart
Stream<List<Footprint>> getRecentVisitorsStream() {
  final twentyFourHoursAgo = Timestamp.fromDate(
    DateTime.now().subtract(const Duration(hours: 24))
  );

  return _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .where("visitedAt", isGreaterThan: twentyFourHoursAgo)  // visitedAtに変更
    .orderBy("visitedAt", descending: true)                  // visitedAtに変更
    .snapshots()
    .map((snapshot) =>
      snapshot.docs.map((doc) =>
        Footprint.fromFirestore(doc.id, doc.data())          // fromFirestoreに変更
      ).toList()
    );
}
```

#### ソート順
- `visitedAt`降順（最新の訪問が先頭）

**重要:** 同じユーザーの複数回訪問も全て表示される

---

### 3. 訪問先リスト取得（自分が訪問したユーザー）

#### データソース
- `users/{myUserId}/footprints`コレクション

#### 取得方法
```dart
Stream<List<Footprint>> getVisitedStream() {
  return _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprints")
    .orderBy("updatedAt", descending: true)
    .snapshots()
    .map((snapshot) =>
      snapshot.docs.map((doc) =>
        Footprint.fromJson(doc.data())
      ).toList()
    );
}
```

---

### 4. 未読足あと数の取得

#### 計算方法
過去24時間以内かつ未読（`isSeen == false`）の足あと数をカウント

```dart
Future<int> getRecentUnseenCount() async {
  final twentyFourHoursAgo = Timestamp.fromDate(
    DateTime.now().subtract(const Duration(hours: 24))
  );

  final snapshot = await _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .where("updatedAt", isGreaterThan: twentyFourHoursAgo)
    .where("isSeen", isEqualTo: false)
    .count()
    .get();

  return snapshot.count ?? 0;
}
```

#### 使用箇所
- タイムラインのヘッダーバッジ
- 足あと画面への遷移ボタン

---

### 5. 足あとの既読処理

#### 個別既読（markMultipleAsSeen）
```dart
Future<void> markMultipleAsSeen(List<String> userIds) async {
  final batch = _firestore.batch();

  for (final userId in userIds) {
    final docRef = _firestore
      .collection("users")
      .doc(myUserId)
      .collection("footprinteds")
      .doc(userId);

    batch.update(docRef, {"isSeen": true});
  }

  await batch.commit();
}
```

#### 全件既読（markAllFootprintsSeen）
```dart
Future<void> markAllFootprintsSeen() async {
  final batch = _firestore.batch();

  final snapshot = await _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .where("isSeen", isEqualTo: false)
    .get();

  for (var doc in snapshot.docs) {
    batch.update(doc.reference, {"isSeen": true});
  }

  await batch.commit();
}
```

#### 実行タイミング
- 足あと画面を開いた時（`useEffect`で自動実行）
```dart
useEffect(() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(footprintManagerProvider).markAllFootprintsSeen();
  });
  return null;
}, const []);
```

---

### 6. 足あとの削除

#### 削除処理
双方のデータを削除（バッチ処理でアトミック）

```dart
Future<void> deleteFootprint(String userId) async {
  final batch = _firestore.batch();

  // 自分の履歴から削除
  final myRef = _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprints")
    .doc(userId);

  // 相手の履歴から削除
  final theirRef = _firestore
    .collection("users")
    .doc(userId)
    .collection("footprinteds")
    .doc(myUserId);

  batch.delete(myRef);
  batch.delete(theirRef);

  await batch.commit();
}
```

#### UI操作
- 訪問先タブで削除ボタンをタップ
- スワイプで削除（グリッドカードの×ボタン）

---

### 7. 統計情報の取得

#### 取得データ
```dart
Future<FootprintStatistics> getStatistics() async {
  final now = DateTime.now();

  // 並列実行で効率化
  final results = await Future.wait([
    _getCountForPeriod(now - 24時間),
    _getCountForPeriod(now - 7日),
    _getCountForPeriod(now - 30日),
    _getUnseenCount(),
    _getHourlyDistribution(),
    _getFrequentVisitors(),
  ]);

  return FootprintStatistics(
    last24Hours: results[0],
    lastWeek: results[1],
    lastMonth: results[2],
    unseenCount: results[3],
    hourlyDistribution: results[4],
    frequentVisitors: results[5],
  );
}
```

#### 時間帯別分布
```dart
Future<Map<int, int>> _getHourlyDistribution() async {
  final distribution = <int, int>{};
  final twentyFourHoursAgo = DateTime.now() - Duration(hours: 24);

  final snapshot = await _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .where("updatedAt", isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
    .get();

  for (final doc in snapshot.docs) {
    final footprint = Footprint.fromJson(doc.data());
    final hour = footprint.updatedAt.toDate().hour;
    distribution[hour] = (distribution[hour] ?? 0) + 1;
  }

  return distribution;
}
```

#### 頻繁な訪問者（上位5人）
```dart
Future<List<String>> _getFrequentVisitors() async {
  final visitorCounts = <String, int>{};
  final oneWeekAgo = DateTime.now() - Duration(days: 7);

  final snapshot = await _firestore
    .collection("users")
    .doc(myUserId)
    .collection("footprinteds")
    .where("updatedAt", isGreaterThan: Timestamp.fromDate(oneWeekAgo))
    .get();

  for (final doc in snapshot.docs) {
    final footprint = Footprint.fromJson(doc.data());
    visitorCounts[footprint.userId] = footprint.count;
  }

  // カウント降順でソート
  final sorted = visitorCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(5).map((e) => e.key).toList();
}
```

---

## API仕様

### Repository Interface（IFootprintRepository）

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `getRecentVisitorsStream()` | `Stream<List<Footprint>>` | 過去24時間の訪問者リスト（リアルタイム） |
| `getVisitorsStream()` | `Stream<List<Footprint>>` | 全期間の訪問者リスト（リアルタイム） |
| `getVisitedStream()` | `Stream<List<Footprint>>` | 訪問先リスト（リアルタイム） |
| `visitProfile(String targetUserId)` | `Future<void>` | プロフィール訪問時に足あとを残す |
| `markMultipleAsSeen(List<String> userIds)` | `Future<void>` | 複数の足あとを既読にする |
| `markAllFootprintsSeen()` | `Future<void>` | 全ての足あとを既読にする |
| `removeFootprint(String userId)` | `Future<void>` | 特定の足あとを削除 |
| `getRecentUnseenCount()` | `Future<int>` | 未読の足あと数を取得（過去24時間） |
| `getStatistics()` | `Future<FootprintStatistics>` | 統計情報を取得 |

---

### UseCases

#### GetVisitorsUsecase
```dart
class GetVisitorsUsecase {
  final IFootprintRepository _repository;

  Stream<List<Footprint>> getProfileVisitors() {
    return _repository.getVisitorsStream();
  }
}
```

#### GetVisitedUsecase
```dart
class GetVisitedUsecase {
  final IFootprintRepository _repository;

  Stream<List<Footprint>> getVisitedProfiles() {
    return _repository.getVisitedStream();
  }
}
```

#### VisitProfileUsecase
```dart
class VisitProfileUsecase {
  final IFootprintRepository _repository;

  Future<void> leaveFootprint(UserAccount user) async {
    return _repository.visitProfile(user.userId);
  }
}
```

#### MarkFootprintsSeenUsecase
```dart
class MarkFootprintsSeenUsecase {
  final IFootprintRepository _repository;

  Future<void> markAllFootprintsSeen() async {
    return _repository.markAllFootprintsSeen();
  }
}
```

#### RemoveFootprintUsecase
```dart
class RemoveFootprintUsecase {
  final IFootprintRepository _repository;

  Future<void> deleteFootprint(String userId) {
    return _repository.removeFootprint(userId);
  }
}
```

#### GetUnreadCountUsecase
```dart
class GetUnreadCountUsecase {
  final IFootprintRepository _repository;

  Future<int> getUnreadFootprintCount() {
    return _repository.getRecentUnseenCount();
  }
}
```

#### GetFootprintStatisticsUseCase
```dart
class GetFootprintStatisticsUseCase {
  final IFootprintRepository repository;

  Future<FootprintStatistics> execute() async {
    try {
      return await repository.getStatistics();
    } catch (e) {
      return FootprintStatistics.empty();
    }
  }

  Stream<FootprintStatistics> watch() {
    return Stream.periodic(const Duration(minutes: 1), (_) async {
      return await execute();
    }).asyncMap((event) => event);
  }
}
```

---

### Providers（State Management）

#### visitorsProvider
```dart
final visitorsProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitorsUsecaseProvider);
  return usecase.getProfileVisitors();
});
```

#### visitedProvider
```dart
final visitedProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitedUsecaseProvider);
  return usecase.getVisitedProfiles();
});
```

#### unreadFootprintCountProvider
```dart
final unreadFootprintCountProvider = FutureProvider.autoDispose<int>((ref) {
  final usecase = ref.watch(getUnreadCountUsecaseProvider);
  return usecase.getUnreadFootprintCount();
});
```

#### footprintManagerProvider（複合操作プロバイダ）
```dart
final footprintManagerProvider = Provider((ref) => FootprintManager(
  ref.watch(visitProfileProvider),
  ref.watch(markFootprintsSeenProvider),
  ref.watch(removeFootprintProvider),
  ref,
));

class FootprintManager {
  Future<void> visitUserProfile(UserAccount user) async {...}
  Future<void> markAllFootprintsSeen() async {...}
  Future<void> removeFootprint(String userId) async {...}
  int getUnreadCount() {...}
}
```

---

## UI/UX仕様

### 足あと画面（FootprintScreen）

#### レイアウト構成
```
┌────────────────────────────────────┐
│         AppBar: "足あと"            │
├────────────────────────────────────┤
│  TabBar                            │
│  ┌─────────┬─────────────┐        │
│  │ 訪問者  │ つけた足あと │        │
│  └─────────┴─────────────┘        │
├────────────────────────────────────┤
│  TabBarView                        │
│  ┌──────────────────────────────┐ │
│  │  日付ヘッダー: 2025-10-06    │ │
│  ├──────────────────────────────┤ │
│  │  ┌─────┐  ┌─────┐           │ │
│  │  │Card │  │Card │  (2列)    │ │
│  │  │User1│  │User2│           │ │
│  │  └─────┘  └─────┘           │ │
│  │  ┌─────┐  ┌─────┐           │ │
│  │  │Card │  │Card │           │ │
│  │  │User3│  │User4│           │ │
│  │  └─────┘  └─────┘           │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

#### タブ構成
1. **訪問者タブ**: 自分を訪問したユーザー一覧
2. **つけた足あとタブ**: 自分が訪問したユーザー一覧

#### カード表示（GridView 2列）
- ユーザーのプロフィール画像
- ユーザー名
- 削除ボタン（つけた足あとタブのみ）

#### アニメーション
```dart
// フェードイン + スライドイン
final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
  .animate(CurvedAnimation(
    parent: animationController,
    curve: Curves.easeOut,
  ));

final slideAnimation = Tween<Offset>(
  begin: const Offset(0, 0.5),
  end: Offset.zero
).animate(CurvedAnimation(
  parent: animationController,
  curve: Curves.easeOutCubic,
));

// 遅延アニメーション（カード毎に50ms遅延）
delay: Duration(milliseconds: index * 50)
```

#### 状態表示

##### ローディング状態
```dart
class FootprintLoadingState extends StatelessWidget {
  // Shimmerエフェクト付きのスケルトンカード
  // 2列グリッド × 6枚のプレースホルダー
}
```

##### エラー状態
```dart
class FootprintErrorState extends StatelessWidget {
  // エラーアイコン
  // エラーメッセージ
  // 再試行ボタン
}
```

##### 空状態
```dart
class EmptyFootprintState extends ConsumerWidget {
  // 空アイコン（person_off / travel_explore）
  // メッセージ: "まだ誰も訪問していません"
  // 更新ボタン
}
```

#### 操作
- **カードタップ**: ユーザープロフィールへ遷移
- **削除ボタン**: 足あとを削除（確認なし）
- **プルトゥリフレッシュ**: データを再取得

---

### タイムライン統合

#### 未読バッジ表示
```dart
// timeline_logo_header.dart
final unreadCount = ref.watch(unreadFootprintCountProvider);

Badge(
  label: Text('${unreadCount.value ?? 0}'),
  isLabelVisible: (unreadCount.value ?? 0) > 0,
  child: IconButton(
    icon: Icon(Icons.footprint),
    onPressed: () {
      ref.read(navigationRouterProvider(context)).goToFootprint();
    },
  ),
)
```

---

## エラーハンドリング

### カスタム例外
```dart
class FootprintException implements Exception {
  final String message;
  FootprintException(this.message);

  @override
  String toString() => 'FootprintException: $message';
}
```

### エラーケース

| エラー | 原因 | 処理 |
|--------|------|------|
| `Failed to visit profile` | Firestore書き込み失敗 | FootprintExceptionをスロー |
| `Failed to mark footprints as seen` | バッチ処理失敗 | FootprintExceptionをスロー |
| `Failed to remove footprint` | 削除処理失敗 | FootprintExceptionをスロー |
| `Failed to get unseen count` | カウント取得失敗 | FootprintExceptionをスロー |
| `Failed to get statistics` | 統計情報取得失敗 | 空の統計情報を返す |

### ストリームエラーハンドリング
```dart
return _firestore
  .collection("users")
  .doc(myUserId)
  .collection("footprinteds")
  .snapshots()
  .handleError((error) {
    return <Footprint>[];  // 空リストを返す
  });
```

---

## パフォーマンス最適化

### 1. Firestoreクエリ最適化

#### インデックス
```
Collection: users/{userId}/footprinteds
Fields: updatedAt (Descending)

Collection: users/{userId}/footprinteds
Composite Index:
  - updatedAt (Descending)
  - isSeen (Ascending)
```

#### クエリ効率化
```dart
// 過去24時間のデータのみ取得（フルスキャン回避）
.where("updatedAt", isGreaterThan: twentyFourHoursAgo)
.orderBy("updatedAt", descending: true)
```

### 2. バッチ処理
- 複数の書き込み操作をバッチでアトミックに実行
- ネットワークラウンドトリップの削減

```dart
final batch = _firestore.batch();
batch.update(...);
batch.update(...);
await batch.commit();  // 1回のネットワークコール
```

### 3. 並列処理
```dart
// 統計情報取得時に6つのクエリを並列実行
final results = await Future.wait([
  _getCountForPeriod(twentyFourHoursAgo),
  _getCountForPeriod(oneWeekAgo),
  _getCountForPeriod(oneMonthAgo),
  _getUnseenCount(),
  _getHourlyDistribution(),
  _getFrequentVisitors(),
]);
```

### 4. プロバイダー最適化
```dart
// autoDisposeで未使用時にリソースを自動解放
final visitorsProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  ...
});
```

### 5. UI最適化
- Shimmerローディング効果でUX向上
- 遅延アニメーション（カード毎に50ms差）
- GridViewで効率的なスクロール

---

## セキュリティ

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 足あと関連のルール
    match /users/{userId}/footprinteds/{visitorId} {
      // 自分の訪問者リストは読み取り可能
      allow read: if request.auth.uid == userId;

      // 訪問者本人のみが書き込み可能（訪問時）
      allow write: if request.auth.uid == visitorId;

      // 既読更新は所有者のみ
      allow update: if request.auth.uid == userId
                    && request.resource.data.diff(resource.data).affectedKeys()
                       .hasOnly(['isSeen']);

      // 削除は双方が可能
      allow delete: if request.auth.uid == userId
                    || request.auth.uid == visitorId;
    }

    match /users/{userId}/footprints/{targetId} {
      // 自分の訪問履歴は読み取り可能
      allow read: if request.auth.uid == userId;

      // 本人のみが書き込み可能
      allow write: if request.auth.uid == userId;

      // 削除は本人のみ
      allow delete: if request.auth.uid == userId;
    }
  }
}
```

### データバリデーション
```dart
// 自分自身への訪問は記録しない
if (myUserId.isEmpty || myUserId == targetUserId) {
  return;
}

// userIdの検証
if (myUserId.isEmpty) {
  return;
}
```

---

## 将来の拡張

### 実装予定機能

#### 1. 通知設定
```dart
// 新しい訪問者の通知ON/OFF
Future<void> updateNotificationSetting(bool enabled);
```

#### 2. プライバシー設定
- 足あと機能の有効/無効
- 訪問記録の公開範囲設定（全員/友達のみ）

#### 3. 足あとフィルタリング
- 日付範囲でフィルタ
- 訪問回数でフィルタ
- ユーザー名検索

#### 4. 足あと詳細表示
- 訪問時刻の履歴
- 訪問回数のグラフ
- 滞在時間（将来的にトラッキング）

#### 5. 統計ダッシュボード
```dart
class FootprintDashboard {
  final FootprintStatistics stats;
  final Chart hourlyChart;        // 時間帯別グラフ
  final List<User> topVisitors;   // トップ訪問者
  final TrendData weeklyTrend;    // 週次トレンド
}
```

#### 6. Entity設計の強化
```dart
// ビジネスロジックの拡張例
class FootprintStatistics {
  // 現在実装済み
  bool get hasNewVisitors;
  bool get hasRecentActivity;
  bool get isPopular;
  int? get peakHour;
  double get weeklyGrowthRate;
  double get monthlyGrowthRate;
  VisitorTrend get trend;

  // 将来的な拡張
  Duration get averageVisitInterval;  // 平均訪問間隔
  List<int> get activeHours;          // アクティブな時間帯
  bool get hasRegularVisitors;        // 定期的な訪問者がいるか
}
```

#### 7. ブロック機能との統合
- ブロックしたユーザーの足あとを非表示
- ブロックされたユーザーには足あとを残さない

---

## テスト仕様

### ユニットテスト

#### Repository Test
```dart
test('visitProfile should record footprint for both users', () async {
  await repository.visitProfile('targetUserId');

  verify(datasource.addFootprint('targetUserId')).called(1);
});

test('visitProfile should not record for self', () async {
  await repository.visitProfile(myUserId);

  verifyNever(datasource.addFootprint(any));
});
```

#### UseCase Test
```dart
test('getVisitors should return stream of footprints', () async {
  when(repository.getVisitorsStream())
    .thenAnswer((_) => Stream.value([mockFootprint]));

  final result = usecase.getProfileVisitors();

  expect(await result.first, [mockFootprint]);
});
```

### 統合テスト

#### E2E Scenario
```
1. ユーザーAがユーザーBのプロフィールを訪問
2. ユーザーBの足あと画面で訪問者リストを確認
3. ユーザーAが表示されることを検証
4. 未読バッジが表示されることを検証
5. 足あと画面を開いて既読処理
6. 未読バッジが消えることを検証
```

---

## パフォーマンスベンチマーク

### 目標値
- 訪問者リスト取得: < 500ms
- 足あと記録処理: < 300ms
- 既読処理: < 200ms
- 統計情報取得: < 1000ms

### 最適化指標
- Firestoreクエリ数: 最小化
- バッチサイズ: 500件以下（Firestore制限）
- リアルタイムリスナー: 必要最小限

---

## 依存関係

### パッケージ
```yaml
dependencies:
  cloud_firestore: ^4.x.x
  hooks_riverpod: ^2.x.x
  flutter_hooks: ^0.x.x
  shimmer: ^3.x.x
```

### 内部依存
```
Presentation Layer
  ↓
Domain Layer
  ├── entity/footprint/
  │   ├── footprint.dart
  │   └── footprint_statistics.dart
  ├── repository/
  │   └── footprint_repository_interface.dart
  └── usecases/footprint/
  ↓
Data Layer (FootprintRepositoryImpl, FootprintDatasource)
  ↓
Firebase Firestore
```

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| 1.0.0 | 2025-10-06 | 初版リリース |
| 1.1.0 | 2025-10-06 | Entity構造の改善（ディレクトリ分割）、FootprintPrivacy削除、FootprintStatisticsにビジネスロジック追加 |
| 1.2.0 | 2025-10-06 | **重要な設計変更**: ドキュメントIDをランダムIDに変更、訪問ごとに新規記録、正確な統計情報を実現 |
| 1.3.0 | 未定 | プライバシー設定実装予定 |
| 1.4.0 | 未定 | 統計ダッシュボード実装予定 |

### v1.2.0の詳細な変更内容

#### 設計変更の背景
従来の実装では、ドキュメントIDをuserIdにしていたため、同じユーザーが複数回訪問してもupdateされるだけで訪問回数が正確にカウントできない問題がありました。

#### 主な変更点

1. **Footprint Entity構造変更**
   - `userId` → `visitorId` / `visitedUserId`
   - `count`フィールドを削除
   - `updatedAt` → `visitedAt`
   - `id`フィールドを追加
   - `fromFirestore(docId, json)`メソッドを導入

2. **Firestore データ構造変更**
   - ドキュメントID: `{userId}` → `{randomDocId}`（自動生成）
   - フィールド: `userId`, `count`, `updatedAt` → `visitorId`, `visitedUserId`, `visitedAt`
   - 訪問ごとに新規ドキュメントを作成（`SetOptions(merge: true)`を使用しない）

3. **Datasource層の更新**
   - `addFootprint()`: `FieldValue.increment(1)`を使わず、新規作成
   - `deleteFootprint()`: visitorIdでクエリして全ドキュメント削除
   - 全ストリームメソッド: `fromFirestore()`を使用、`visitedAt`でソート
   - `getFrequentVisitors()`: 実際の訪問回数をカウント

4. **Repository層の更新**
   - `markMultipleAsSeen()`: パラメータを`footprintIds`（ドキュメントID）に変更

5. **Presentation層の更新**
   - `footprint.userId` → `footprint.visitorId` / `footprint.visitedUserId`
   - `footprint.updatedAt` → `footprint.visitedAt`

#### 設計変更のメリット
- ✅ 正確な訪問回数のカウント（同じユーザーの複数訪問も記録）
- ✅ 時間帯別分布の正確性（各訪問のタイムスタンプが保存）
- ✅ 頻繁な訪問者の正確な特定（訪問回数でソート可能）
- ✅ 訪問履歴の完全性（全ての訪問イベントが記録）

#### 考慮事項
- データ量の増加（訪問ごとにドキュメントが増える）
- 定期的なクリーンアップが必要（古い足あとの削除機能を将来実装）
- UIでの同じユーザーの複数訪問表示（現状: 全て表示）

---

## 用語集

| 用語 | 説明 |
|-----|------|
| Footprint | ユーザーがプロフィールを訪問した記録 |
| Footprinteds | 自分を訪問したユーザーのコレクション（訪問者） |
| Footprints | 自分が訪問したユーザーのコレクション（訪問先） |
| isSeen | 足あとの既読状態フラグ |
| UseCase | ビジネスロジックを実装する単一責任のクラス |
| Repository | データアクセスの抽象インターフェース |
| Datasource | Firestoreへの直接アクセス層 |
| Provider | Riverpodによる状態管理クラス |

---

## 参考資料

### クリーンアーキテクチャ
- Domain層でインターフェースを定義
- Data層で具体的実装を提供
- 依存性の逆転原則（DIP）を適用

### Riverpod
- StreamProvider: リアルタイムデータ監視
- FutureProvider: 非同期データ取得
- autoDispose: 自動リソース解放

### Firestore Best Practices
- バッチ処理でアトミック操作
- インデックス最適化
- クエリフィルタリング
- count()集計でデータ転送量削減

---

## まとめ

Footprint機能は、クリーンアーキテクチャに基づき、以下の特徴を持つ：

1. **レイヤー分離**: Presentation / Domain / Data の明確な分離
2. **依存性の逆転**: Domain層がData層の詳細を知らない
3. **テスタビリティ**: 各レイヤーが独立してテスト可能
4. **拡張性**: 新機能追加時に既存コードへの影響を最小化
5. **パフォーマンス**: バッチ処理・並列実行・クエリ最適化
6. **セキュリティ**: Firestore Security Rulesによるアクセス制御

この仕様書に従うことで、保守性・拡張性の高いFootprint機能を実現できる。
