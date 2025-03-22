# Git 運用ガイドライン

このガイドラインは、プロジェクトでの効率的なGit運用方法について説明します。

## 目次

1. [基本的なワークフロー](#基本的なワークフロー)
2. [ブランチ戦略](#ブランチ戦略)
3. [コミットメッセージのルール](#コミットメッセージのルール)
4. [プルリクエスト（PR）の活用](#プルリクエストPRの活用)
5. [コンフリクト解決方法](#コンフリクト解決方法)
6. [よくあるトラブルと解決策](#よくあるトラブルと解決策)

## 基本的なワークフロー

### 1. 個人開発・小規模プロジェクトの場合

小規模な個人プロジェクトであれば、mainブランチに直接コミットする方法でも問題ありません：

```bash
git add .
git commit -m "変更内容の説明"
git push origin main
```

ただし、以下の点に注意してください：
- コミットは論理的な単位で行う
- 定期的にコミットとプッシュを行い、作業を失わないようにする
- コミットメッセージは具体的に記述する

### 2. チーム開発・中〜大規模プロジェクトの場合

チーム開発や大規模プロジェクトでは、フィーチャーブランチワークフローを採用することをお勧めします：

```bash
# 最新のmainブランチを取得
git checkout main
git pull origin main

# 新しい機能用のブランチを作成
git checkout -b feature/新機能名

# 変更を加える
...

# 変更をコミット
git add .
git commit -m "新機能: 機能の説明"

# リモートにプッシュ
git push origin feature/新機能名

# GitHub/GitLabなどでプルリクエスト/マージリクエストを作成
```

## ブランチ戦略

効率的な開発のために、以下のブランチ命名規則を採用することをお勧めします：

- `main` (または `master`): 本番環境にデプロイ可能な安定したコード
- `develop`: 開発環境の最新コード（オプション）
- `feature/機能名`: 新機能の開発
- `bugfix/問題名`: バグ修正
- `hotfix/問題名`: 緊急のバグ修正（本番環境向け）
- `release/バージョン`: リリース準備（オプション）

## コミットメッセージのルール

良いコミットメッセージは以下の特徴を持ちます：

1. 先頭は以下のプレフィックスで始める
   - `feat:` - 新機能
   - `fix:` - バグ修正
   - `docs:` - ドキュメント更新
   - `style:` - フォーマットの変更（コードの動作に影響しない）
   - `refactor:` - リファクタリング
   - `test:` - テスト関連
   - `chore:` - ビルドプロセスやツールの変更

2. 短く明確な要約（50文字以内が理想）
3. 必要に応じて詳細な説明を空行の後に追加

例：
```
feat: ユーザー認証機能の実装

- メールアドレスとパスワードによるログイン機能
- パスワードリセット機能
- アカウントロック機能
```

## プルリクエスト（PR）の活用

プルリクエストは以下のメリットがあります：

1. コードレビューの促進
2. 自動テストの実行
3. 変更の可視化
4. ナレッジの共有

### PRの作成手順

1. 機能ブランチをリモートにプッシュ
   ```bash
   git push origin feature/機能名
   ```

2. GitHubなどのウェブインターフェースでPRを作成
   - タイトルと説明を明確に記述
   - レビュアーを指定
   - 関連するIssueをリンク

3. レビュー後にマージ
   - レビューコメントに対応
   - 必要に応じて変更を追加
   - すべての自動テストがパスしていることを確認
   - マージ（必要に応じてSquashマージを使用）

## コンフリクト解決方法

コンフリクトが発生した場合の解決手順：

1. 最新のmainブランチを取得
   ```bash
   git checkout main
   git pull origin main
   ```

2. 作業ブランチに戻ってリベースまたはマージ
   ```bash
   # リベースを使用する場合（推奨）
   git checkout feature/機能名
   git rebase main
   
   # または、マージを使用する場合
   git checkout feature/機能名
   git merge main
   ```

3. コンフリクトを解決
   - エディタでコンフリクトマーカー（`<<<<<<<`, `=======`, `>>>>>>>`)を探す
   - コードを適切に統合
   - 変更をステージング
   ```bash
   git add <コンフリクトしたファイル>
   ```

4. リベースを続行またはマージを完了
   ```bash
   # リベースの場合
   git rebase --continue
   
   # マージの場合
   git commit
   ```

## よくあるトラブルと解決策

### 1. リモートブランチが先行している場合のエラー
```
error: failed to push some refs... updates were rejected because the remote contains work that you do not have locally
```

解決策：
```bash
git pull origin <ブランチ名>
# または
git pull --rebase origin <ブランチ名>
```

### 2. Detached HEADの状態になった場合

解決策：
```bash
# 変更を保存したい場合は新しいブランチを作成
git branch 新しいブランチ名

# mainブランチに戻る
git checkout main
```

### 3. 直前のコミットを修正したい場合

解決策：
```bash
# 最後のコミットメッセージを変更
git commit --amend -m "新しいコミットメッセージ"

# 最後のコミットに変更を追加
git add <ファイル>
git commit --amend --no-edit
```

### 4. コミットを取り消したい場合

解決策：
```bash
# 直前のコミットを取り消し（変更は保持）
git reset --soft HEAD^

# 直前のコミットを完全に取り消し（変更も削除）
git reset --hard HEAD^
```

## 最後に

このガイドラインは、プロジェクトの規模や要件に応じて適宜調整してください。小規模なプロジェクトでは簡略化したワークフローを、大規模なプロジェクトではより厳格なワークフローを採用することをお勧めします。

Git運用に関する質問や問題がある場合は、チームメンバーに相談するか、このREADMEを更新してナレッジを共有してください。



構成図


lib/
│
├── main.dart
│
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── date_formatter.dart
│   │   └── firebase_helpers.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── domain/
│   ├── entities/
│   │   ├── user/
│   │   │   ├── user.dart
│   │   │   └── user_stats.dart
│   │   ├── post/
│   │   │   ├── post.dart
│   │   │   ├── comment.dart
│   │   │   └── like.dart
│   │   ├── story/
│   │   │   ├── story.dart
│   │   │   └── story_view.dart
│   │   ├── chat/
│   │   │   ├── message.dart
│   │   │   ├── chat_room.dart
│   │   │   ├── group_chat.dart
│   │   │   └── community_chat.dart
│   │   └── relation/
│   │       ├── follow.dart
│   │       └── block.dart
│   │
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   ├── post_repository.dart
│   │   ├── story_repository.dart
│   │   ├── chat_repository.dart
│   │   └── relation_repository.dart
│   │
│   └── usecases/
│       ├── user/
│       │   ├── get_user_profile.dart
│       │   ├── update_user_profile.dart
│       │   ├── register_user.dart
│       │   ├── login_user.dart
│       │   ├── logout_user.dart
│       │   └── search_users.dart
│       ├── post/
│       │   ├── create_post.dart
│       │   ├── delete_post.dart
│       │   ├── get_feed_posts.dart
│       │   ├── like_post.dart
│       │   ├── unlike_post.dart
│       │   ├── add_comment.dart
│       │   └── get_post_comments.dart
│       ├── story/
│       │   ├── create_story.dart
│       │   ├── get_stories.dart
│       │   ├── delete_story.dart
│       │   └── view_story.dart
│       ├── chat/
│       │   ├── send_message.dart
│       │   ├── get_messages.dart
│       │   ├── create_chat.dart
│       │   ├── create_group_chat.dart
│       │   ├── create_community_chat.dart
│       │   ├── add_member_to_chat.dart
│       │   └── leave_chat.dart
│       └── relation/
│           ├── follow_user.dart
│           ├── unfollow_user.dart
│           ├── get_followers.dart
│           ├── get_following.dart
│           ├── block_user.dart
│           └── unblock_user.dart
│
├── data/
│   ├── datasources/
│   │   ├── user_data_source.dart
│   │   ├── post_data_source.dart
│   │   ├── story_data_source.dart
│   │   ├── chat_data_source.dart
│   │   └── relation_data_source.dart
│   │
│   ├── models/
│   │   ├── user/
│   │   │   ├── user_model.dart
│   │   │   └── user_stats_model.dart
│   │   ├── post/
│   │   │   ├── post_model.dart
│   │   │   ├── comment_model.dart
│   │   │   └── like_model.dart
│   │   ├── story/
│   │   │   ├── story_model.dart
│   │   │   └── story_view_model.dart
│   │   ├── chat/
│   │   │   ├── message_model.dart
│   │   │   ├── chat_room_model.dart
│   │   │   ├── group_chat_model.dart
│   │   │   └── community_chat_model.dart
│   │   └── relation/
│   │       ├── follow_model.dart
│   │       └── block_model.dart
│   │
│   └── repositories/
│       ├── user_repository_impl.dart
│       ├── post_repository_impl.dart
│       ├── story_repository_impl.dart
│       ├── chat_repository_impl.dart
│       └── relation_repository_impl.dart
│
└── presentation/
    ├── providers/
    │   ├── auth/
    │   │   ├── auth_provider.dart
    │   │   ├── auth_state.dart
    │   │   └── auth_notifier.dart
    │   │
    │   ├── user/
    │   │   ├── user_provider.dart
    │   │   ├── user_state.dart
    │   │   └── user_notifier.dart
    │   │
    │   ├── post/
    │   │   ├── post_provider.dart
    │   │   ├── post_state.dart
    │   │   └── post_notifier.dart
    │   │
    │   ├── story/
    │   │   ├── story_provider.dart
    │   │   ├── story_state.dart
    │   │   └── story_notifier.dart
    │   │
    │   ├── chat/
    │   │   ├── chat_provider.dart
    │   │   ├── chat_state.dart
    │   │   └── chat_notifier.dart
    │   │
    │   └── relation/
    │       ├── relation_provider.dart
    │       ├── relation_state.dart
    │       └── relation_notifier.dart
    │
    ├── pages/
    │   ├── auth/
    │   │   ├── login_page.dart
    │   │   └── register_page.dart
    │   │
    │   ├── home/
    │   │   ├── home_page.dart
    │   │   └── feed_page.dart
    │   │
    │   ├── profile/
    │   │   ├── profile_page.dart
    │   │   └── edit_profile_page.dart
    │   │
    │   ├── post/
    │   │   ├── create_post_page.dart
    │   │   └── post_detail_page.dart
    │   │
    │   ├── story/
    │   │   ├── create_story_page.dart
    │   │   └── story_view_page.dart
    │   │
    │   └── chat/
    │       ├── chat_list_page.dart
    │       ├── chat_detail_page.dart
    │       ├── create_group_page.dart
    │       └── community_chat_page.dart
    │
    └── widgets/
        ├── common/
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   └── loading_indicator.dart
        │
        ├── user/
        │   ├── user_avatar.dart
        │   ├── user_list_item.dart
        │   └── follow_button.dart
        │
        ├── post/
        │   ├── post_card.dart
        │   ├── post_list.dart
        │   ├── comment_list.dart
        │   └── like_button.dart
        │
        ├── story/
        │   ├── story_circle.dart
        │   └── story_list.dart
        │
        └── chat/
            ├── message_bubble.dart
            ├── chat_input.dart
            ├── chat_list_item.dart
            └── member_list.dart