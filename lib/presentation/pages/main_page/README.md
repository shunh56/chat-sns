# Main Page Architecture

メインページのクリーンアーキテクチャ実装ドキュメント

## 📁 ディレクトリ構造

```
main_page/
├── main_page.dart                    # メインエントリーポイント
├── main_page_wrapper.dart           # ライフサイクル管理
├── README.md                         # このドキュメント
├── components/                       # UIコンポーネント
│   ├── drawer.dart                   # サイドドロワー
│   ├── main_content.dart             # メインコンテンツ表示
│   ├── navigation/                   # ナビゲーション関連
│   │   ├── bottom_navigation_bar.dart
│   │   └── floating_action_buttons.dart
│   └── overlays/                     # オーバーレイコンポーネント
│       └── heart_animation_overlay.dart
├── constants/                        # 定数定義
│   └── tab_constants.dart            # タブ関連定数
├── providers/                        # 状態管理
│   ├── lifecycle_notifier.dart       # ライフサイクル状態
│   └── main_page_state_notifier.dart # メインページ状態
└── services/                         # サービス層
    └── voip_service.dart             # VoIP関連処理
```

## 🏗️ アーキテクチャ設計

### 責務分離

1. **MainPageWrapper** - ライフサイクル管理専用
2. **MainPage** - UI構成とレイアウト
3. **MainPageStateNotifier** - 統合状態管理
4. **VoIPService** - VoIP通話処理
5. **各コンポーネント** - 単一責任の原則

### 状態管理フロー

```
MainPageStateNotifier
├── currentIndex: タブインデックス
├── isLoading: ローディング状態
└── error: エラー状態

↓ 状態変更

BottomNavigationBar → changeTab() → 画面切り替え
FloatingActionButtons → currentIndex監視 → FAB表示制御
```

## 🔧 使用方法

### タブ追加

1. `tab_constants.dart`に新しいタブ定数を追加
2. `NavigationItems.items`にアイテム設定を追加
3. `main_content.dart`のIndexedStackに画面を追加

### 状態監視

```dart
// 現在のタブインデックスを監視
final currentIndex = ref.watch(
  mainPageStateProvider.select((state) => state.currentIndex)
);

// エラー状態を監視
final error = ref.watch(
  mainPageStateProvider.select((state) => state.error)
);
```

### タブ切り替え

```dart
ref.read(mainPageStateProvider.notifier).changeTab(context, newIndex);
```

## 📊 パフォーマンス最適化

- **IndexedStack**: 画面の状態保持
- **プロバイダーキープ**: 重要な状態の保持
- **定数化**: マジックナンバーの排除
- **コンポーネント分割**: レンダリングの最適化

## 🧪 テスト戦略

- **単体テスト**: 各StateNotifierのロジック
- **ウィジェットテスト**: コンポーネントの動作
- **統合テスト**: ページ遷移の動作

## 🔄 リファクタリング履歴

- **Before**: 495行のモノリシック構造
- **After**: 51行のメインページ + 分離されたコンポーネント
- **削減率**: 89%のコード削減
- **品質向上**: 責務分離、型安全性、保守性向上

## 📝 注意事項

- `MainPageTabIndex`の定数を使用してマジックナンバーを避ける
- 新しい機能追加時は適切なコンポーネントに分割する
- 状態変更は必ずStateNotifierを経由する
- VoIP関連の処理は`VoIPService`に集約する