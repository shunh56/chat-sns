# エンゲージメント向上施策 MVP設計書

## 作成日
2025-10-06

## 概要
ユーザーのアクティブ率を向上させるための自動通知施策。MVPとして、**過度にならず、効果的に**ユーザーを再訪させるシステムを設計。

---

## 📊 現状分析

### 既存のシステム

#### ✅ 実装済みの機能
- **足あとシステム**: プロフィール訪問を記録（`footprints` コレクション）
- **通知システム**: FCM/VoIP対応、マルチデバイス対応
- **ユーザーデータ**: `lastOpenedAt`, `isOnline`, `activeDevices`

#### 📈 利用可能なデータ

| データ | 保存場所 | 活用可能性 |
|--------|----------|------------|
| `lastOpenedAt` | `users/{userId}` | 最終ログイン時刻 → 非アクティブ検知 |
| `isOnline` | `users/{userId}` | オンライン状態 |
| `footprints` | `footprints/` | 訪問履歴 → 「誰かが訪問」通知 |
| `followingCount` | `users/{userId}` | フォロワー数 |
| `friendIds` | `users/{userId}` | 友達リスト |
| `currentStatus` | `users/{userId}.profile` | ステータス更新日時 |

---

## 🎯 施策の設計原則

### 1. **適応的な頻度調整** (Adaptive Frequency) ★ 新規追加
- **アクティブユーザー**: 1日1回
- **やや非アクティブ**: 2〜3日に1回
- **非アクティブ**: 1週間に1回
- ユーザーの状態に応じて自動的に頻度を調整

### 2. **少ないが効果的** (Less is More)
- ユーザーが嫌がらない範囲で設計
- 過度な通知を避ける

### 3. **価値のある情報のみ** (Value-Driven)
- 「新しい足あと」「友達がオンライン」など、**ユーザーが気になる情報**
- 「無意味な通知」は絶対に避ける

### 4. **A/Bテスト可能** (Measurable)
- 通知の効果を測定できる仕組み
- 簡単にON/OFF切り替え可能

### 5. **オプトアウト可能** (User Control)
- 設定から通知をOFFにできる
- 通知の種類ごとに個別設定可能

---

## 📊 ユーザーアクティブ度の分類

### アクティブ度セグメント

ユーザーの `lastOpenedAt` に基づいて、4つのセグメントに自動分類します。

| セグメント | 最終ログイン | 通知頻度 | 戦略 |
|-----------|-------------|----------|------|
| **🟢 Very Active** | 24時間以内 | **1日1回** | エンゲージメント維持 |
| **🟡 Active** | 1〜3日前 | **2日に1回** | リエンゲージメント |
| **🟠 At Risk** | 3〜7日前 | **3日に1回** | 再アクティブ化 |
| **🔴 Churned** | 7日以上前 | **1週間に1回** | 復帰促進 |

### セグメント判定ロジック

```javascript
/**
 * ユーザーのアクティブ度セグメントを判定
 * @param {Timestamp} lastOpenedAt - 最終ログイン日時
 * @returns {'very_active' | 'active' | 'at_risk' | 'churned'}
 */
function getUserSegment(lastOpenedAt) {
  const now = Date.now();
  const lastOpened = lastOpenedAt.toDate().getTime();
  const hoursSinceLastOpened = (now - lastOpened) / (1000 * 60 * 60);

  if (hoursSinceLastOpened <= 24) {
    return 'very_active';  // 24時間以内
  } else if (hoursSinceLastOpened <= 72) {
    return 'active';  // 1〜3日前
  } else if (hoursSinceLastOpened <= 168) {
    return 'at_risk';  // 3〜7日前
  } else {
    return 'churned';  // 7日以上前
  }
}
```

### 通知頻度マトリックス

各施策の通知頻度を、セグメントごとに調整します。

#### 施策1: 足あとリマインダー

| セグメント | 最小間隔 | 条件 |
|-----------|----------|------|
| 🟢 Very Active | **1日** | 未読足あと 5件以上 |
| 🟡 Active | **2日** | 未読足あと 3件以上 |
| 🟠 At Risk | **3日** | 未読足あと 2件以上 |
| 🔴 Churned | **7日** | 未読足あと 1件以上 |

#### 施策2: 友達オンライン通知

| セグメント | 最大回数/日 | 条件 |
|-----------|-------------|------|
| 🟢 Very Active | **3回** | 親しい友達のみ |
| 🟡 Active | **2回** | 親しい友達のみ |
| 🟠 At Risk | **1回** | 全友達 |
| 🔴 Churned | **OFF** | 送信しない |

#### 施策3: 定期リマインダー

| セグメント | 頻度 | 送信タイミング |
|-----------|------|---------------|
| 🟢 Very Active | **OFF** | 送信不要 |
| 🟡 Active | **OFF** | 送信不要 |
| 🟠 At Risk | **3日に1回** | 午前10時 or 午後7時 |
| 🔴 Churned | **1週間に1回** | 毎週日曜 午前10時 |

---

## 🚀 MVP施策: 3つの自動通知

### 施策1: 「新しい足あとがあります」通知 ★ 適応的頻度対応

#### 概要
プロフィールに新しい訪問者がいることを通知。**ユーザーのセグメントに応じて頻度を調整**。

#### セグメント別トリガー

| セグメント | 最小間隔 | 未読足あと条件 | 送信タイミング |
|-----------|----------|----------------|---------------|
| 🟢 Very Active | **1日** | 5件以上 | 毎日 19:00 |
| 🟡 Active | **2日** | 3件以上 | 2日おき 19:00 |
| 🟠 At Risk | **3日** | 2件以上 | 3日おき 19:00 |
| 🔴 Churned | **7日** | 1件以上 | 毎週日曜 10:00 |

#### 通知内容（セグメント別）

```javascript
// 🟢 Very Active: エンゲージメント維持
{
  title: '新しい足あとが5件あります 👣',
  body: 'あなたのプロフィールに興味を持った人がいます！'
}

// 🟡 Active: リエンゲージメント
{
  title: 'あなたに興味がある人が3人います 👀',
  body: '誰が訪問したか確認しよう！'
}

// 🟠 At Risk: 再アクティブ化
{
  title: '最近、あなたのプロフィールが人気です 🔥',
  body: '2件の新しい足あとがあります。今すぐチェック！'
}

// 🔴 Churned: 復帰促進
{
  title: '久しぶり！新しい訪問者がいます 👋',
  body: 'あなたのことを気になっている人がいます'
}
```

#### 実装ロジック（適応的）

```javascript
// Firebase Functions (Cloud Scheduler)
exports.sendFootprintReminders = functions
  .region('asia-northeast1')
  .pubsub.schedule('0 19 * * *') // 毎日 19:00
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    const users = await admin.firestore().collection('users').get();

    for (const userDoc of users.docs) {
      const user = userDoc.data();
      const userId = userDoc.id;

      // ★ セグメント判定
      const segment = getUserSegment(user.lastOpenedAt);

      // ★ 通知設定チェック
      if (!user.notificationData?.footprintReminders) continue;

      // ★ 最後の通知送信日時をチェック
      const lastSent = user.lastNotificationSent?.footprintReminder;
      if (!shouldSendBasedOnSegment(segment, lastSent)) continue;

      // ★ セグメント別の未読足あと条件
      const minFootprints = getMinFootprintsForSegment(segment);
      const unseenFootprints = await admin.firestore()
        .collection('footprints')
        .where('visitedUserId', '==', userId)
        .where('isSeen', '==', false)
        .get();

      if (unseenFootprints.size >= minFootprints) {
        // ★ セグメント別の通知内容
        const notification = getNotificationForSegment(segment, unseenFootprints.size);
        await sendNotification(userId, notification);

        // 送信日時を記録
        await userDoc.ref.update({
          'lastNotificationSent.footprintReminder': admin.firestore.Timestamp.now()
        });
      }
    }
  });

/**
 * セグメントに基づいて通知を送信すべきかチェック
 */
function shouldSendBasedOnSegment(segment, lastSent) {
  if (!lastSent) return true;

  const hoursSinceLastSent = (Date.now() - lastSent.toDate().getTime()) / (1000 * 60 * 60);

  const intervals = {
    'very_active': 24,   // 1日
    'active': 48,        // 2日
    'at_risk': 72,       // 3日
    'churned': 168       // 7日
  };

  return hoursSinceLastSent >= intervals[segment];
}

/**
 * セグメント別の最小足あと件数
 */
function getMinFootprintsForSegment(segment) {
  const thresholds = {
    'very_active': 5,
    'active': 3,
    'at_risk': 2,
    'churned': 1
  };
  return thresholds[segment];
}

/**
 * セグメント別の通知内容
 */
function getNotificationForSegment(segment, count) {
  const notifications = {
    'very_active': {
      title: `新しい足あとが${count}件あります 👣`,
      body: 'あなたのプロフィールに興味を持った人がいます！'
    },
    'active': {
      title: `あなたに興味がある人が${count}人います 👀`,
      body: '誰が訪問したか確認しよう！'
    },
    'at_risk': {
      title: '最近、あなたのプロフィールが人気です 🔥',
      body: `${count}件の新しい足あとがあります。今すぐチェック！`
    },
    'churned': {
      title: '久しぶり！新しい訪問者がいます 👋',
      body: 'あなたのことを気になっている人がいます'
    }
  };
  return notifications[segment];
}
```

#### 設定項目
- `notificationData.footprintReminders` (デフォルト: `true`)

---

### 施策2: 「友達がオンラインです」通知 ★ 適応的頻度対応

#### 概要
友達やフォローしているユーザーがオンラインになったことを通知。**セグメントに応じて頻度と対象を調整**。

#### セグメント別トリガー

| セグメント | 最大回数/日 | 通知対象 | 送信条件 |
|-----------|-------------|----------|----------|
| 🟢 Very Active | **3回** | 親しい友達のみ | リアルタイム |
| 🟡 Active | **2回** | 親しい友達のみ | リアルタイム |
| 🟠 At Risk | **1回** | 全友達 | リアルタイム |
| 🔴 Churned | **OFF** | - | 送信しない |

**親しい友達**: `topFriends` リストまたは相互フォロー

#### 通知内容（セグメント別）

```javascript
// 🟢 Very Active: エンゲージメント維持
{
  title: '〇〇さんがオンラインです 🟢',
  body: '今なら通話できるかも！タップして話しかけよう'
}

// 🟡 Active: リエンゲージメント
{
  title: '〇〇さんがアプリを開きました',
  body: '久しぶりに話してみる？'
}

// 🟠 At Risk: 再アクティブ化
{
  title: '〇〇さんがオンラインです',
  body: '友達と繋がるチャンス！'
}
```

#### 実装ロジック（適応的）

```javascript
// Firebase Functions (Firestore Trigger)
exports.notifyFriendsOnline = functions
  .region('asia-northeast1')
  .firestore.document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // オフライン → オンラインになった場合のみ
    if (!before.isOnline && after.isOnline) {
      const userId = context.params.userId;
      const user = after;
      const friendIds = user.friendIds || [];

      for (const friendId of friendIds) {
        const friend = await admin.firestore().doc(`users/${friendId}`).get();
        const friendData = friend.data();

        // ★ 友達のセグメントを判定
        const friendSegment = getUserSegment(friendData.lastOpenedAt);

        // ★ Churned ユーザーには送らない
        if (friendSegment === 'churned') continue;

        // ★ 通知設定チェック
        if (!friendData.notificationData?.friendOnline) continue;

        // ★ 今日の通知回数をチェック
        const todayCount = await getTodayNotificationCount(friendId, 'friend_online');
        const maxCount = getMaxFriendOnlineCount(friendSegment);

        if (todayCount >= maxCount) continue;

        // ★ 親しい友達チェック（Very Active / Active のみ）
        if (['very_active', 'active'].includes(friendSegment)) {
          const isCloseFriend = friendData.topFriends?.includes(userId) ||
                                user.topFriends?.includes(friendId);
          if (!isCloseFriend) continue;
        }

        // ★ セグメント別の通知内容
        const notification = getFriendOnlineNotification(friendSegment, user.name);
        await sendNotification(friendId, notification);

        // 通知カウント記録
        await incrementNotificationCount(friendId, 'friend_online');
      }
    }
  });

/**
 * セグメント別の最大通知回数（1日あたり）
 */
function getMaxFriendOnlineCount(segment) {
  const limits = {
    'very_active': 3,
    'active': 2,
    'at_risk': 1,
    'churned': 0
  };
  return limits[segment];
}

/**
 * 今日の通知回数を取得
 */
async function getTodayNotificationCount(userId, notificationType) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const count = await admin.firestore()
    .collection('engagement_metrics')
    .where('userId', '==', userId)
    .where('notificationType', '==', notificationType)
    .where('sentAt', '>=', admin.firestore.Timestamp.fromDate(today))
    .get();

  return count.size;
}

/**
 * セグメント別の通知内容
 */
function getFriendOnlineNotification(segment, friendName) {
  const notifications = {
    'very_active': {
      title: `${friendName}さんがオンラインです 🟢`,
      body: '今なら通話できるかも！タップして話しかけよう',
      notificationType: 'friend_online'
    },
    'active': {
      title: `${friendName}さんがアプリを開きました`,
      body: '久しぶりに話してみる？',
      notificationType: 'friend_online'
    },
    'at_risk': {
      title: `${friendName}さんがオンラインです`,
      body: '友達と繋がるチャンス！',
      notificationType: 'friend_online'
    }
  };
  return notifications[segment];
}
```

#### 設定項目
- `notificationData.friendOnline` (デフォルト: `true`)

---

### 施策3: 「定期リマインダー」通知 ★ 適応的頻度対応

#### 概要
非アクティブユーザーに対して、アプリの価値を再認識させる通知。**At Risk と Churned セグメントのみ対象**。

#### セグメント別トリガー

| セグメント | 頻度 | 送信タイミング | 通知内容 |
|-----------|------|---------------|----------|
| 🟢 Very Active | **OFF** | - | 不要 |
| 🟡 Active | **OFF** | - | 不要 |
| 🟠 At Risk | **3日に1回** | 10:00 or 19:00 | 軽い誘導 |
| 🔴 Churned | **7日に1回** | 毎週日曜 10:00 | 強い訴求 |

#### 通知内容（セグメント別）

```javascript
// 🟠 At Risk: 再アクティブ化（軽めの誘導）
{
  title: '友達の近況をチェックしよう 👀',
  body: '最近の投稿やステータスをチェック！'
}
{
  title: '今日の気分をシェアしよう ✨',
  body: 'あなたの近況を待っている人がいます'
}

// 🔴 Churned: 復帰促進（強い訴求）
{
  title: '久しぶり！元気？ 👋',
  body: 'あなたを待っている人がいます。今週の予定をシェアしよう！'
}
{
  title: '最近どうしてる？',
  body: '友達の近況をチェックして、つながりを保とう！'
}
{
  title: '新しい出会いがあるかも 💫',
  body: 'あなたと趣味が合う人が見つかるかもしれません！'
}
```

#### 実装ロジック（適応的）

```javascript
// Firebase Functions (Cloud Scheduler)
// At Risk 向け: 毎日 10:00 と 19:00 に実行
exports.sendAtRiskReminders = functions
  .region('asia-northeast1')
  .pubsub.schedule('0 10,19 * * *')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    const users = await admin.firestore().collection('users').get();

    for (const userDoc of users.docs) {
      const user = userDoc.data();
      const userId = userDoc.id;

      // ★ セグメント判定
      const segment = getUserSegment(user.lastOpenedAt);

      // At Risk のみ対象
      if (segment !== 'at_risk') continue;

      // 通知設定チェック
      if (!user.notificationData?.weeklyReminders) continue;

      // 最後の通知から3日以上経過しているかチェック
      const lastSent = user.lastNotificationSent?.weeklyReminder;
      if (!shouldSendAtRiskReminder(lastSent)) continue;

      // At Risk 向け通知
      const notification = getAtRiskReminderNotification();
      await sendNotification(userId, notification);

      // 送信日時を記録
      await userDoc.ref.update({
        'lastNotificationSent.weeklyReminder': admin.firestore.Timestamp.now()
      });
    }
  });

// Churned 向け: 毎週日曜 10:00 に実行
exports.sendChurnedReminders = functions
  .region('asia-northeast1')
  .pubsub.schedule('0 10 * * 0') // 毎週日曜日 10:00
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    const users = await admin.firestore().collection('users').get();

    for (const userDoc of users.docs) {
      const user = userDoc.data();
      const userId = userDoc.id;

      // ★ セグメント判定
      const segment = getUserSegment(user.lastOpenedAt);

      // Churned のみ対象
      if (segment !== 'churned') continue;

      // 通知設定チェック
      if (!user.notificationData?.weeklyReminders) continue;

      // 最後の通知から7日以上経過しているかチェック
      const lastSent = user.lastNotificationSent?.weeklyReminder;
      if (!shouldSendChurnedReminder(lastSent)) continue;

      // Churned 向け通知（ランダム）
      const notification = getChurnedReminderNotification();
      await sendNotification(userId, notification);

      // 送信日時を記録
      await userDoc.ref.update({
        'lastNotificationSent.weeklyReminder': admin.firestore.Timestamp.now()
      });
    }
  });

/**
 * At Risk 向けリマインダーを送信すべきかチェック（3日に1回）
 */
function shouldSendAtRiskReminder(lastSent) {
  if (!lastSent) return true;

  const hoursSinceLastSent = (Date.now() - lastSent.toDate().getTime()) / (1000 * 60 * 60);
  return hoursSinceLastSent >= 72; // 3日
}

/**
 * Churned 向けリマインダーを送信すべきかチェック（7日に1回）
 */
function shouldSendChurnedReminder(lastSent) {
  if (!lastSent) return true;

  const hoursSinceLastSent = (Date.now() - lastSent.toDate().getTime()) / (1000 * 60 * 60);
  return hoursSinceLastSent >= 168; // 7日
}

/**
 * At Risk 向け通知（ランダム）
 */
function getAtRiskReminderNotification() {
  const messages = [
    {
      title: '友達の近況をチェックしよう 👀',
      body: '最近の投稿やステータスをチェック！',
      notificationType: 'weekly_reminder'
    },
    {
      title: '今日の気分をシェアしよう ✨',
      body: 'あなたの近況を待っている人がいます',
      notificationType: 'weekly_reminder'
    }
  ];
  return messages[Math.floor(Math.random() * messages.length)];
}

/**
 * Churned 向け通知（ランダム）
 */
function getChurnedReminderNotification() {
  const messages = [
    {
      title: '久しぶり！元気？ 👋',
      body: 'あなたを待っている人がいます。今週の予定をシェアしよう！',
      notificationType: 'weekly_reminder'
    },
    {
      title: '最近どうしてる？',
      body: '友達の近況をチェックして、つながりを保とう！',
      notificationType: 'weekly_reminder'
    },
    {
      title: '新しい出会いがあるかも 💫',
      body: 'あなたと趣味が合う人が見つかるかもしれません！',
      notificationType: 'weekly_reminder'
    }
  ];
  return messages[Math.floor(Math.random() * messages.length)];
}
```

#### 設定項目
- `notificationData.weeklyReminders` (デフォルト: `true`)

---

## 📐 システム設計

### 1. Firestore データモデル拡張

#### `users/{userId}` に追加するフィールド

```typescript
interface UserAccount {
  // ... 既存フィールド

  // ★ 新規追加: エンゲージメント通知設定
  notificationData: {
    isActive: boolean;
    directMessage: boolean;
    currentStatusPost: boolean;
    post: boolean;
    voiceChat: boolean;
    friendRequest: boolean;

    // ★ 新規追加
    footprintReminders: boolean;    // 足あと通知 (デフォルト: true)
    friendOnline: boolean;           // 友達オンライン通知 (デフォルト: true)
    weeklyReminders: boolean;        // 定期リマインダー (デフォルト: true)
  };

  // ★ 新規追加: 通知履歴
  lastNotificationSent?: {
    footprintReminder?: Timestamp;
    friendOnline?: Timestamp;
    weeklyReminder?: Timestamp;
  };
}
```

### 2. Firebase Functions 構成

```
functions/
├─ index.js
├─ engagement_notifications.js  ★ 新規追加
│   ├─ sendFootprintReminders()      // 施策1
│   ├─ notifyFriendsOnline()         // 施策2 (Firestore Trigger)
│   └─ sendWeeklyReminders()         // 施策3
└─ cleanup_inactive_devices.js
```

#### `engagement_notifications.js` 構造

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * 施策1: 新しい足あとがあることを通知
 * スケジュール: 毎日 19:00〜21:00 (ランダム)
 */
exports.sendFootprintReminders = functions
  .region('asia-northeast1')
  .pubsub.schedule('0 19 * * *')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    // 実装
  });

/**
 * 施策2: 友達がオンラインになったことを通知
 * トリガー: users/{userId} の isOnline が false → true
 */
exports.notifyFriendsOnline = functions
  .region('asia-northeast1')
  .firestore.document('users/{userId}')
  .onUpdate(async (change, context) => {
    // 実装
  });

/**
 * 施策3: 定期リマインダー通知
 * スケジュール: 毎週日曜日 10:00
 */
exports.sendWeeklyReminders = functions
  .region('asia-northeast1')
  .pubsub.schedule('0 10 * * 0')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    // 実装
  });
```

### 3. Flutter アプリ側の設定UI

#### `lib/presentation/pages/settings/notification_settings_page.dart`

```dart
class NotificationSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationData = ref.watch(myAccountNotifierProvider)
        .asData?.value.notificationData;

    return ListView(
      children: [
        // 既存の設定
        SwitchListTile(
          title: Text('ダイレクトメッセージ'),
          value: notificationData?.directMessage ?? true,
          onChanged: (value) => _updateNotificationData(ref, directMessage: value),
        ),

        // ... 既存の設定

        Divider(),
        Text('エンゲージメント通知', style: TextStyle(fontWeight: FontWeight.bold)),

        // ★ 新規追加
        SwitchListTile(
          title: Text('新しい足あと通知'),
          subtitle: Text('3日以上ログインしていない場合、新しい足あとをお知らせ'),
          value: notificationData?.footprintReminders ?? true,
          onChanged: (value) => _updateNotificationData(ref, footprintReminders: value),
        ),

        SwitchListTile(
          title: Text('友達オンライン通知'),
          subtitle: Text('友達がアプリを起動したときにお知らせ'),
          value: notificationData?.friendOnline ?? true,
          onChanged: (value) => _updateNotificationData(ref, friendOnline: value),
        ),

        SwitchListTile(
          title: Text('定期リマインダー'),
          subtitle: Text('7日以上ログインしていない場合、週1回お知らせ'),
          value: notificationData?.weeklyReminders ?? true,
          onChanged: (value) => _updateNotificationData(ref, weeklyReminders: value),
        ),
      ],
    );
  }
}
```

---

## 📊 効果測定

### KPI (Key Performance Indicators)

| 指標 | 測定方法 | 目標値 |
|------|----------|--------|
| **DAU (Daily Active Users)** | Firestore: `isOnline` カウント | +15% |
| **通知開封率** | 通知送信 → アプリ起動 | 30% 以上 |
| **リテンション率 (D7)** | 7日後も継続使用 | 40% 以上 |
| **オプトアウト率** | 通知OFF設定率 | 10% 未満 |

### 測定用のデータ収集

#### Firestore: `engagement_metrics/` コレクション

```typescript
interface EngagementMetric {
  userId: string;
  notificationType: 'footprint_reminder' | 'friend_online' | 'weekly_reminder';
  sentAt: Timestamp;
  openedAt?: Timestamp;  // アプリを開いた時刻
  opened: boolean;       // 開封したか
}
```

#### 通知送信時
```javascript
await admin.firestore().collection('engagement_metrics').add({
  userId: userId,
  notificationType: 'footprint_reminder',
  sentAt: admin.firestore.Timestamp.now(),
  opened: false,
});
```

#### アプリ起動時
```dart
// lib/presentation/pages/main_page/providers/lifecycle_notifier.dart
Future<void> initialize() async {
  // ★ 通知経由でアプリを開いたかチェック
  final notificationData = await FirebaseMessaging.instance.getInitialMessage();
  if (notificationData != null) {
    await _trackNotificationOpen(notificationData);
  }

  // ... 既存の処理
}

Future<void> _trackNotificationOpen(RemoteMessage message) async {
  final notificationType = message.data['notificationType'];
  if (notificationType != null) {
    await FirebaseFirestore.instance.collection('engagement_metrics')
        .where('userId', '==', currentUserId)
        .where('notificationType', '==', notificationType)
        .where('opened', '==', false)
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.first.reference.update({
          'openedAt': Timestamp.now(),
          'opened': true,
        });
      }
    });
  }
}
```

---

## 🛡️ 安全対策

### 1. 通知頻度制限

```javascript
// 同じ種類の通知を24時間以内に複数送らない
async function shouldSendNotification(userId, notificationType) {
  const user = await admin.firestore().doc(`users/${userId}`).get();
  const lastSent = user.data().lastNotificationSent?.[notificationType];

  if (!lastSent) return true;

  const hoursSinceLastSent = (Date.now() - lastSent.toDate().getTime()) / (1000 * 60 * 60);
  return hoursSinceLastSent >= 24;
}
```

### 2. 通知設定チェック

```javascript
async function canSendNotification(userId, notificationType) {
  const user = await admin.firestore().doc(`users/${userId}`).get();
  const notificationData = user.data().notificationData;

  // 全体がOFFの場合
  if (!notificationData?.isActive) return false;

  // 個別設定がOFFの場合
  const settingKey = {
    'footprint_reminder': 'footprintReminders',
    'friend_online': 'friendOnline',
    'weekly_reminder': 'weeklyReminders',
  }[notificationType];

  return notificationData?.[settingKey] !== false;
}
```

### 3. バッチサイズ制限

```javascript
// 一度に送信する通知数を制限（FCMのレート制限対策）
const BATCH_SIZE = 500;
const DELAY_BETWEEN_BATCHES = 1000; // 1秒

for (let i = 0; i < users.length; i += BATCH_SIZE) {
  const batch = users.slice(i, i + BATCH_SIZE);
  await sendNotificationBatch(batch);

  if (i + BATCH_SIZE < users.length) {
    await new Promise(resolve => setTimeout(resolve, DELAY_BETWEEN_BATCHES));
  }
}
```

---

## 🚀 MVP実装ステップ

### Phase 1: データモデル拡張 (1日)
1. ✅ `NotificationData` エンティティに新フィールド追加
2. ✅ Firestore セキュリティルール更新
3. ✅ Flutter アプリの設定UI作成

### Phase 2: 施策1実装 (2日)
1. ✅ Firebase Functions: `sendFootprintReminders()` 実装
2. ✅ スケジューラー設定（毎日19:00）
3. ✅ テスト実行

### Phase 3: 施策2実装 (2日)
1. ✅ Firebase Functions: `notifyFriendsOnline()` 実装
2. ✅ Firestore Trigger 設定
3. ✅ 頻度制限ロジック実装

### Phase 4: 施策3実装 (1日)
1. ✅ Firebase Functions: `sendWeeklyReminders()` 実装
2. ✅ スケジューラー設定（毎週日曜10:00）
3. ✅ テスト実行

### Phase 5: 効果測定実装 (2日)
1. ✅ `engagement_metrics` コレクション作成
2. ✅ アプリ起動時の追跡ロジック実装
3. ✅ 分析ダッシュボード作成（Firestore Query）

### Phase 6: デプロイ & モニタリング (1日)
1. ✅ Functions デプロイ
2. ✅ 初日〜1週間のモニタリング
3. ✅ KPI測定 & 改善

---

## 💡 今後の拡張案（Phase 2以降）

### 1. パーソナライズド通知
- ユーザーの行動履歴に基づいた通知
- 「あなたが興味を持ちそうなユーザー」

### 2. スマート通知タイミング
- ユーザーの過去のアクティブ時間帯を学習
- 最も開封率が高い時間に送信

### 3. 通知内容の動的生成
- A/Bテストで最も効果的な文言を特定
- ユーザーの状況に応じた文言調整

### 4. リワード連動
- 「7日連続ログインでバッジ獲得！」
- ゲーミフィケーション要素の追加

---

## 📝 まとめ

### MVP の特徴
- ✅ **少ないが効果的**: 週1〜2回の通知に限定
- ✅ **価値のある情報**: 足あと、友達オンライン、定期リマインダー
- ✅ **測定可能**: KPIを設定し、効果を数値化
- ✅ **ユーザー制御**: 設定でON/OFF可能

### 期待される効果
- DAU: **+15%**
- 通知開封率: **30%以上**
- リテンション率 (D7): **40%以上**

### 次のアクション
1. ✅ データモデル拡張の実装
2. ✅ Firebase Functions の実装
3. ✅ Flutter アプリ設定UI の実装
4. ✅ デプロイ & モニタリング

---

## 変更履歴
- 2025-10-06: 初版作成（MVP設計完了）
