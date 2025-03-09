# BLANK

![BLANK Logo](assets/images/icons/icon.png)

## 主な機能

### ユーザー管理
- ユーザー登録と認証
- プロフィールのカスタマイズと閲覧
- フォロー/フォロワーシステム
- ユーザー検索機能
- プロフィール訪問履歴（足跡機能）

### 投稿とコンテンツ
- テキスト投稿
- 複数画像のアップロード
- いいね・コメントシステム
- タイムラインフィード
- 現在のステータス共有（「今何してる？」機能）
- 24時間限定ストーリー

### コミュニケーション
- ダイレクトメッセージ (DM)
- グループチャット
- ボイスチャットとビデオ通話

### コミュニティ
- コミュニティ作成と参加
- トピック作成と参加
- ハッシュタグシステム

### その他の機能
- 招待コードシステム
- プッシュ通知
- ミュートとブロック機能
- プライバシー設定
- 足跡（訪問履歴）追跡

## テックスタック

### フロントエンド
- **Flutter**: クロスプラットフォームUIフレームワーク
  - **flutter_hooks** / **hooks_riverpod**: Hooks と Riverpod の統合
  - **flutter_image_compress**: 画像圧縮ライブラリ
  - **permission_handler**: 権限管理

### 状態管理
- **Riverpod**: 予測可能で制御可能な状態管理ライブラリ
  - Provider パターンを使用した依存性注入
  - StateNotifier/StateProvider による状態管理
  - AsyncValue を使用した非同期処理の状態表現

### ローカルストレージ
- **Hive**: 高速なNoSQLデータベース
  - ユーザーアカウント情報のキャッシュ
  - オフライン対応のためのデータ永続化
  - TypeAdapter によるカスタムオブジェクトのシリアライズ

### バックエンド (Firebase)
- **Firebase Authentication**: ユーザー認証システム
  - メール/パスワード認証
  - ソーシャルログイン連携
  
- **Cloud Firestore**: リアルタイムNoSQLデータベース
  - リアルタイムデータ同期
  - クエリとフィルタリング
  - トランザクションとバッチ処理
  
- **Firebase Storage**: メディアファイル保存
  - 画像アップロード/ダウンロード
  - セキュリティルールによるアクセス制御
  
- **Firebase Cloud Functions**: サーバーレス関数
  - プッシュ通知送信
  - バックグラウンド処理
  - Firestore トリガー
  
- **Firebase Cloud Messaging (FCM)**: プッシュ通知
  - トークン管理
  - 通知カスタマイズ
  - バックグラウンド/フォアグラウンド処理

### 外部サービス統合
- **Agora.io**: リアルタイムボイスとビデオ通信
  - ボイスチャット
  - ビデオ通話
  
- **Algolia**: 高速検索機能
  - 投稿検索
  - ユーザー検索

## アーキテクチャ

BLANKアプリはクリーンアーキテクチャの原則に従って設計されており、以下の3つの主要レイヤーで構成されています：

### ドメイン層 (Domain Layer)
ビジネスロジックと業務ルールを含む、アプリケーションの中核となる層です。

- **エンティティ (Entity)**: アプリケーションのコアデータモデル
  - `User`, `Post`, `Message`, `Story` など
  - ビジネスルールを含む

- **リポジトリインターフェース (Repository Interfaces)**: データアクセスの抽象化
  - `UserRepository`, `PostRepository` など
  - 具体的な実装の詳細から独立

- **ユースケース (Usecases)**: 特定のビジネスロジックを実装
  - `UserUsecase`, `PostUsecase`, `FollowUsecase` など
  - 複数のリポジトリを組み合わせた複雑な操作

- **値オブジェクト (Value Objects)**: 不変のデータ構造
  - `Gender`, `ServerType` など

### データ層 (Data Layer)
ドメイン層のリポジトリインターフェースを実装し、データの取得と永続化を担当します。

- **データソース (Datasources)**: 外部データソースとの通信
  - `UserDatasource`, `PostDatasource` など
  - Firebase との直接通信

- **リポジトリ実装 (Repository Implementations)**: リポジトリインターフェースの具体的な実装
  - `UserRepositoryImpl`, `PostRepositoryImpl` など
  - 複数のデータソースを調整

- **サービス (Services)**: 特定の機能を提供するヘルパークラス
  - `ImageCompressor`, `StorageService` など

- **プロバイダー (Providers)**: Riverpod を使用した依存性注入
  - リポジトリやユースケースのインスタンス提供

### プレゼンテーション層 (Presentation Layer)
ユーザーインターフェースとユーザーとのインタラクションを担当します。

- **画面 (Screens)**: アプリの各画面
  - ホーム画面、プロフィール画面、など

- **コンポーネント (Components)**: 再利用可能なUI要素
  - カスタムボタン、カード、リストアイテムなど

- **プロバイダー (UI Providers)**: UI状態の管理
  - 画面固有の状態管理
  - ユーザー入力の処理

## プロジェクト構造

```
lib/
├── core/                # コアユーティリティ、拡張機能、定数
├── data/
│   ├── datasource/      # Firebase通信
│   │   ├── local/       # ローカルデータソース
│   │   └── post/        # 投稿関連データソース
│   ├── providers/       # Riverpodプロバイダー
│   ├── repository/      # リポジトリ実装
│   │   └── posts/       # 投稿関連リポジトリ
│   └── services/        # 共通サービス
├── domain/
│   ├── entity/          # ドメインモデル
│   │   ├── follow/      # フォロー関連エンティティ
│   │   ├── posts/       # 投稿関連エンティティ
│   │   ├── story/       # ストーリー関連エンティティ
│   │   └── tag/         # タグ関連エンティティ
│   ├── repository_interface/  # リポジトリインターフェース
│   ├── usecases/        # ビジネスロジック
│   │   ├── follow/      # フォロー関連ユースケース
│   │   ├── footprint/   # 足跡関連ユースケース
│   │   ├── posts/       # 投稿関連ユースケース
│   │   └── story/       # ストーリー関連ユースケース
│   └── value/           # 値オブジェクト
│       ├── server/      # サーバー関連値オブジェクト
│       └── user/        # ユーザー関連値オブジェクト
└── presentation/
    ├── components/      # 再利用可能なUIコンポーネント
    ├── providers/       # UI状態管理
    ├── screens/         # アプリ画面
    └── UNUSED/          # 現在使用されていないコード
```

## データベース構造

BLANKアプリはFirestoreを使用して、以下の主要なコレクションとスキーマを実装しています：

### users コレクション
ユーザー情報とプロフィールを保存します。

```
users/(:userId)
├── userId: string                   # ユーザーID
├── createdAt: timestamp            # 作成日時
├── lastOpenedAt: timestamp         # 最終アクセス日時
├── isOnline: boolean               # オンライン状態
├── name: string                    # 表示名
├── username: string                # ユーザー名(@username)
├── imageUrl: string?               # プロフィール画像URL
├── fcmToken: string?               # プッシュ通知用トークン
├── voipToken: string?              # VoIP通知用トークン
├── usedCode: string?               # 使用した招待コード
├── followingCount: int             # フォロー数
├── followerCount: int              # フォロワー数
├── accountStatus: string           # アカウント状態(active/banned等)
├── privateMode: boolean            # プライベートモード設定
├── gender: string                  # 性別
├── deviceInfo: {                   # デバイス情報
│   ├── updatedAt: timestamp        # 更新日時
│   ├── version: string             # アプリバージョン
│   ├── buildNumber: string         # ビルド番号
│   ├── device: string              # デバイス名
│   ├── osVersion: string           # OS バージョン
│   └── platform: string            # プラットフォーム
│  }
├── links: {                        # ソーシャルリンク
│   ├── line: {
│   │   ├── isShown: boolean        # 表示設定
│   │   ├── path: string?           # アカウントパス
│   │   ├── urlScheme: string       # URL スキーム
│   │   ├── assetString: string     # アイコン画像パス
│   │   └── title: string           # タイトル
│   │  }
│   ├── instagram: {...}            # Instagram 設定
│   └── x: {...}                    # X (旧Twitter) 設定
│  }
├── profile: {                      # プロフィール情報
│   ├── bio: {                      # 自己紹介
│   │   ├── age: int?               # 年齢
│   │   ├── birthday: timestamp?    # 誕生日
│   │   ├── gender: string?         # 性別
│   │   └── interestedIn: string?   # 興味
│   │  }
│   ├── aboutMe: string             # 自己紹介文
│   ├── currentStatus: {            # 現在のステータス
│   │   ├── tags: string[]          # タグ
│   │   ├── doing: string           # 今していること
│   │   ├── eating: string          # 食べているもの
│   │   ├── mood: string            # 気分
│   │   ├── nowAt: string           # 現在地
│   │   ├── nextAt: string          # 次の予定
│   │   ├── nowWith: string[]       # 一緒にいる人
│   │   └── updatedAt: timestamp    # 更新日時
│   │  }
│   ├── topFriends: string[]        # トップフレンド
│   ├── wishList: string[]          # ウィッシュリスト
│   ├── tags: string[]              # 関連タグ
│   ├── location: string            # 場所
│   └── job: string                 # 職業
│  }
├── canvasTheme: {                  # UI設定
│   ├── bgColor: color              # 背景色
│   ├── profileTextColor: color     # プロフィールテキスト色
│   ├── profileSecondaryTextColor: color  # 二次テキスト色
│   └── ...                         # その他のテーマ設定
│  }
├── notificationData: {             # 通知設定
│   ├── isActive: boolean           # 通知が有効か
│   ├── directMessage: boolean      # DM通知
│   ├── currentStatusPost: boolean  # ステータス投稿通知
│   ├── post: boolean               # 投稿通知
│   ├── voiceChat: boolean          # ボイスチャット通知
│   └── friendRequest: boolean      # 友達リクエスト通知
│  }
└── privacy: {                      # プライバシー設定
    ├── privateMode: boolean        # プライベートモード
    ├── contentRange: string        # コンテンツ公開範囲
    └── requestRange: string        # リクエスト許可範囲
   }
```

**サブコレクション:**
```
users/(:userId)/footprints/(:visitedUserId)        # 訪問したユーザー
users/(:userId)/footprinteds/(:visitorUserId)      # 訪問されたユーザー
users/(:userId)/mutes/(:mutedUserId)               # ミュートしたユーザー
users/(:userId)/muteds/(:muterUserId)              # ミュートされたユーザー
users/(:userId)/blocks/(:blockedUserId)            # ブロックしたユーザー
users/(:userId)/blockeds/(:blockerUserId)          # ブロックされたユーザー
users/(:userId)/friendRequests/(:requesterId)      # 友達リクエスト
users/(:userId)/friendRequesteds/(:requesteeId)    # リクエスト済み
users/(:userId)/joinedCommunities/(:communityId)   # 参加コミュニティ
users/(:userId)/images/(:imageId)                  # 画像
users/(:userId)/timeline/(:id)                     # タイムライン
users/(:userId)/notices/(:id)                      # 通知
users/(:userId)/notice_logs/(:id)                  # 通知ログ
users/(:userId)/activites/(:id)                    # アクティビティ
```

### direct_messages コレクション
ユーザー間のダイレクトメッセージを保存します。

```
direct_messages/(:userId1_userId2)
├── id: string                      # メッセージルームID
├── lastMessage: {                  # 最後のメッセージ
│   ├── id: string                  # メッセージID
│   ├── text: string                # テキスト
│   ├── createdAt: timestamp        # 作成日時
│   ├── senderId: string            # 送信者ID
│   └── type: string                # メッセージタイプ
│  }
├── updatedAt: timestamp            # 更新日時
├── users: {                        # 参加ユーザー
│   └── [userId]: boolean           # ユーザーID: 参加状態
│  }
└── userInfoList: [{                # ユーザー情報
    ├── userId: string              # ユーザーID
    ├── lastOpenedAt: timestamp     # 最終閲覧時間
    └── unseenCount: int            # 未読数
   }]
```

**サブコレクション:**
```
direct_messages/(:userId1_userId2)/messages/(:messageId)
├── id: string                      # メッセージID
├── createdAt: timestamp            # 作成日時
├── senderId: string                # 送信者ID
├── text: string                    # テキスト
└── type: string                    # メッセージタイプ (text/image/currentStatus_reply)
```

### posts コレクション
ユーザーの投稿を保存します。

```
posts/(:id)
├── id: string                      # 投稿ID
├── userId: string                  # 投稿者ID
├── title: string                   # タイトル
├── text: string?                   # テキスト
├── aspectRatios: double[]          # 画像アスペクト比
├── communityId: string?            # コミュニティID
├── createdAt: timestamp            # 作成日時
├── updatedAt: timestamp            # 更新日時
├── mediaUrls: string[]             # メディアURL
├── hashtags: string[]              # ハッシュタグ
├── mentions: string[]              # メンション
├── isDeletedByAdmin: boolean       # 管理者による削除
├── isDeletedByModerator: boolean   # モデレーターによる削除
├── isDeletedByUser: boolean        # ユーザーによる削除
├── isPublic: boolean               # 公開設定
├── likeCount: int                  # いいね数
└── replyCount: int                 # 返信数
```

**サブコレクション:**
```
posts/(:id)/replies/(:id)
├── id: string                      # 返信ID
├── createdAt: timestamp            # 作成日時
├── likeCount: int                  # いいね数
├── text: string                    # テキスト
├── userId: string                  # ユーザーID
├── isDeletedByAdmin: boolean       # 管理者による削除
├── isDeletedByModerator: boolean   # モデレーターによる削除
└── isDeletedByUser: boolean        # ユーザーによる削除
```

### currentStatusPosts コレクション
ユーザーの現在のステータス投稿を保存します。

```
currentStatusPosts/(:id)
├── id: string                      # 投稿ID
├── userId: string                  # ユーザーID
├── createdAt: timestamp            # 作成日時
├── updatedAt: timestamp            # 更新日時
├── before: {                       # 変更前ステータス
│   ├── tags: string[]              # タグ
│   ├── doing: string               # していること
│   ├── eating: string              # 食べているもの
│   ├── mood: string                # 気分
│   ├── nowAt: string               # 現在地
│   ├── nextAt: string              # 次の予定
│   ├── nowWith: string[]           # 一緒にいる人
│   └── updatedAt: timestamp        # 更新日時
│  }
├── after: {                        # 変更後ステータス
│   ├── tags: string[]              # タグ
│   ├── doing: string               # していること
│   ├── eating: string              # 食べているもの
│   ├── mood: string                # 気分
│   ├── nowAt: string               # 現在地
│   ├── nextAt: string              # 次の予定
│   ├── nowWith: string[]           # 一緒にいる人
│   └── updatedAt: timestamp        # 更新日時
│  }
├── seenUserIds: string[]           # 閲覧ユーザーID
├── likeCount: int                  # いいね数
└── replyCount: int                 # 返信数
```

### stories コレクション
24時間限定のストーリーを保存します。

```
stories/(:id)
├── id: string                      # ストーリーID
├── userId: string                  # ユーザーID
├── mediaUrl: string                # メディアURL
├── caption: string?                # キャプション
├── mediaType: string               # メディアタイプ(image/video)
├── visibility: string              # 公開範囲(public/followers/closeFriends)
├── createdAt: timestamp            # 作成日時
├── expiresAt: timestamp            # 有効期限
├── viewCount: int                  # 閲覧数
├── likeCount: int                  # いいね数
├── isHighlighted: boolean          # ハイライト設定
├── tags: string[]                  # タグ
├── location: string?               # 場所
└── isSensitiveContent: boolean     # センシティブコンテンツ
```

### hashtags コレクション
タグ情報を保存します。

```
hashtags/(:id)
├── id: string                      # タグID
├── text: string                    # タグテキスト
├── count: int                      # 使用数
├── imageUrl: string                # イメージURL
├── createdAt: timestamp            # 作成日時
└── updatedAt: timestamp            # 更新日時
```

### communities コレクション
コミュニティ情報を保存します。

```
communities/(:id)
├── id: string                      # コミュニティID
├── name: string                    # コミュニティ名
├── description: string             # 説明
├── createdAt: timestamp            # 作成日時
├── updatedAt: timestamp            # 更新日時
├── memberCount: int                # メンバー数
├── dailyActiveUsers: int           # 日間アクティブユーザー
├── weeklyActiveUsers: int          # 週間アクティブユーザー
├── monthlyActiveUsers: int         # 月間アクティブユーザー
├── totalPosts: int                 # 投稿総数
├── dailyPosts: int                 # 日間投稿数
├── activeVoiceRooms: int           # アクティブボイスルーム
├── rules: string[]                 # ルール
└── moderators: string[]            # モデレーター
```

**サブコレクション:**
```
communities/(:id)/members/(:userId)
└── joinedAt: timestamp             # 参加日時

communities/(:id)/messages/(:messageId)
├── id: string                      # メッセージID
├── userId: string                  # ユーザーID
├── createdAt: timestamp            # 作成日時
├── type: string                    # メッセージタイプ
└── ...                             # 他のメッセージデータ
```

### followings/followers コレクション
フォロー関係を保存します。

```
followings/(:userId)
└── data: [{                        # フォロー情報
    ├── userId: string              # ユーザーID
    └── createdAt: timestamp        # 作成日時
   }]

followers/(:userId)
└── data: [{                        # フォロワー情報
    ├── userId: string              # ユーザーID
    └── createdAt: timestamp        # 作成日時
   }]
```

### voice_chats コレクション
ボイスチャットセッションを保存します。

```
voice_chats/(:id)
├── id: string                      # ボイスチャットID
├── title: string                   # タイトル
├── joinedUsers: string[]           # 参加ユーザー
├── adminUsers: string[]            # 管理者
├── userMap: {                      # ユーザー情報
│   └── [userId]: {
│       ├── agoraUid: int           # Agora UID
│       └── isMuted: boolean        # ミュート状態
│      }
│  }
├── createdAt: timestamp            # 作成日時
├── createdBy: string               # 作成者
├── endAt: timestamp                # 終了時間
└── maxCount: int                   # 最大参加人数
```

## 主要なユースケース実装

### ユーザー関連
- **UserUsecase**: ユーザーの検索、作成、更新
- **FootprintUsecase**: プロフィール訪問履歴の管理
- **FriendsUsecase**: 友達関係の管理
- **FollowUsecase**: フォロー関係の管理
- **BlockUsecase**: ブロック機能
- **MuteUsecase**: ミュート機能

### 投稿関連
- **PostUsecase**: 通常投稿の作成、取得、更新
- **CurrentStatusPostUsecase**: 現在のステータス投稿
- **BlogUsecase**: ブログ形式の長文投稿
- **StoryUsecase**: 24時間限定ストーリー投稿

### メッセージング関連
- **DirectMessageUsecase**: ダイレクトメッセージの送受信
- **VoiceChatUsecase**: ボイスチャット機能
- **VoipUsecase**: ビデオ通話機能

### コミュニティ関連
- **CommunityUsecase**: コミュニティ管理
- **TopicsUsecase**: トピック管理

### その他
- **TagUsecase**: タグ管理
- **PushNotificationUsecase**: プッシュ通知処理
- **ImageUploadUsecase**: 画像アップロード処理
- **InviteCodeUsecase**: 招待コード機能

## セットアップ手順

### 前提条件
- Flutter SDK
- Firebase アカウント
- IDE (VS Code, Android Studio など)

### インストール
1. リポジトリをクローン
   ```
   git clone https://github.com/yourusername/blank-app.git
   ```

2. プロジェクトディレクトリに移動
   ```
   cd blank-app
   ```

3. 依存関係をインストール
   ```
   flutter pub get
   ```

4. Firebase の設定
   - Firebase プロジェクトを作成
   - Android および iOS アプリを Firebase プロジェクトに追加
   - 設定ファイルをダウンロードして追加 (Android: google-services.json, iOS: GoogleService-Info.plist)
   - Firebase コンソールで Authentication, Firestore, Storage, FCM を有効化

5. アプリを実行
   ```
   flutter run
   ```

## 今後の改善計画

### パフォーマンス
- クエリ最適化とページネーション
- 効率的なデータキャッシング
- 画像の最適化

### セキュリティ
- Firebaseセキュリティルールの強化
- センシティブデータの保護

### ユーザーエクスペリエンス
- オフライン対応の強化
- UI/UXの改善
- 多言語対応
- アクセシビリティの向上

### 新機能
- AI推薦システム
- 高度な分析ダッシュボード
- イベント機能
- タイムラインの最適化

## 貢献について
貢献は歓迎します！プルリクエストを自由に提出してください。

## ライセンス
[ライセンス情報をここに記載]

## 連絡先
[連絡先情報をここに記載]
