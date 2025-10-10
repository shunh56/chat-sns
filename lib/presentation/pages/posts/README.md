# Posts Module

投稿関連機能のモジュール群です。ドメイン駆動設計とClean Architectureに基づいて設計されています。

## 📁 ディレクトリ構造

```
posts/
├── core/                          # 共通機能
│   ├── components/               # 再利用可能UIコンポーネント
│   │   ├── animations/          # アニメーション関連
│   │   ├── media/               # メディア表示関連
│   │   ├── post_card/           # 投稿カード関連
│   │   ├── reply_input.dart     # リプライ入力
│   │   └── reply_list.dart      # リプライ一覧
│   ├── models/                  # 共通データモデル
│   ├── constants/               # 共通定数
│   └── utils/                   # ユーティリティ関数
├── features/                     # 機能別モジュール
│   ├── timeline/                # タイムライン機能
│   │   ├── timeline_page.dart   # メインページ
│   │   ├── components/          # 専用コンポーネント
│   │   ├── providers/           # 状態管理
│   │   └── constants/           # 定数
│   ├── post_detail/             # 投稿詳細機能
│   │   ├── post_detail_page.dart # 詳細ページ
│   │   └── components/          # 専用コンポーネント
│   ├── post_creation/           # 投稿作成機能
│   │   ├── post_creation_page.dart # 作成ページ
│   │   └── components/          # 専用コンポーネント
│   └── reactions/               # リアクション機能
│       ├── components/          # リアクション関連UI
│       └── models/              # リアクション用モデル
└── README.md                    # このファイル
```

## 🎯 設計原則

### 1. **ドメイン駆動設計 (DDD)**
- **Core**: 複数機能で共有される汎用的なコンポーネント
- **Features**: 機能ごとに独立したモジュール

### 2. **単一責任原則**
- 各ファイルは明確な単一の責任を持つ
- 変更理由が1つになるよう設計

### 3. **依存関係の方向**
```
Features → Core (OK)
Core → Features (NG)
Feature A → Feature B (NG)
```

### 4. **変更の局所化**
- 機能追加時は該当featureディレクトリのみ変更
- UI変更時は対応するcomponentのみ変更
- 共通部品変更時はcore/componentsのみ変更

## 🧩 機能モジュール詳細

### Timeline（タイムライン）
**責任**: 投稿一覧の表示とタブ切り替え
**主要ファイル**:
- `timeline_page.dart`: メインページ
- `providers/timeline_posts_provider.dart`: データ管理
- `constants/timeline_constants.dart`: 設定値

### Post Detail（投稿詳細）
**責任**: 個別投稿の詳細表示とリプライ管理
**主要ファイル**:
- `post_detail_page.dart`: 詳細ページ
- `components/reply_section.dart`: リプライエリア

### Post Creation（投稿作成）
**責任**: 新規投稿の作成とメディア添付
**主要ファイル**:
- `post_creation_page.dart`: 作成ページ
- `components/post_text_input.dart`: テキスト入力
- `components/post_media_picker.dart`: メディア選択

### Reactions（リアクション）
**責任**: 投稿に対するリアクション機能
**主要ファイル**:
- `components/reaction_button.dart`: リアクションボタン
- `components/reaction_picker.dart`: リアクション選択UI

## 📱 使用例

### タイムライン表示
```dart
import 'features/timeline/timeline_page.dart';

Widget build() => TimelinePage();
```

### 投稿詳細表示
```dart
import 'features/post_detail/post_detail_page.dart';

Widget build() => PostDetailPage(postId: 'post123');
```

### 投稿作成
```dart
import 'features/post_creation/post_creation_page.dart';

Widget build() => PostCreationPage();
```

### 共通コンポーネント使用
```dart
import 'core/components/reply_input.dart';
import 'core/components/reply_list.dart';

Widget build() => Column(
  children: [
    ReplyList(postId: 'post123'),
    ReplyInput(onSubmit: handleReply),
  ],
);
```

## 🔧 開発ガイドライン

### 新機能追加時
1. `features/` 下に新しいディレクトリを作成
2. 機能専用のページとコンポーネントを実装
3. 他の機能で再利用可能な部品は `core/components/` に配置

### 既存機能修正時
1. 変更対象の機能ディレクトリを特定
2. 該当するファイルのみを変更
3. 共通部品に変更が必要な場合は影響範囲を確認

### コンポーネント設計時
1. 単一責任の原則を守る
2. プロパティでカスタマイズ可能にする
3. 適切なドキュメントコメントを付ける

## ⚠️ 注意事項

- **循環依存禁止**: Feature間で直接importしない
- **命名規則**: 一貫した命名パターンを使用
- **インポートパス**: 相対パスで適切に参照
- **テスト**: 各機能ごとにテストファイルを作成

## 🚀 今後の拡張

この構成により、以下が容易になります：

- **新機能追加**: featuresディレクトリに追加するだけ
- **A/Bテスト**: 機能ごとに独立して実装・切り替え
- **チーム開発**: 機能ごとに担当者を分けられる
- **メンテナンス**: 変更影響範囲が明確で安全