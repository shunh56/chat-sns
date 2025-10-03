# アプリ初期化とルーティングのリファクタリング計画

## 目的
main.dartからホームページまでの処理をクリーンアーキテクチャに基づいて再構築し、保守性・可読性・テスタビリティを向上させる

## 現状の問題点

### 1. 責務の分離不足
- main.dartに初期化、ルーティング、UI構成が混在
- SplashScreenがルーティングロジックを担当
- ビジネスロジックがpresentation層に混入

### 2. 初期化処理の問題
- 順序依存性が不明確
- エラーハンドリングが不十分
- テスト困難

### 3. 状態管理の一貫性欠如
- グローバル変数の使用
- 複数の状態管理パターンの混在

## リファクタリング方針

### 1. アーキテクチャ構造

```
lib/
├── application/           # アプリケーション層（新規追加）
│   ├── bootstrap/
│   │   ├── app_bootstrap.dart
│   │   └── app_initializer.dart
│   ├── navigation/
│   │   ├── app_router.dart
│   │   └── route_guard.dart
│   └── services/
│       └── app_lifecycle_service.dart
│
├── core/                 # 既存のcoreを拡張
│   ├── di/              # 依存性注入（新規）
│   │   └── injection_container.dart
│   └── config/          # 設定管理（新規）
│       └── app_config.dart
│
├── domain/              # 既存構造を維持
│   └── usecases/        # ユースケース層を追加
│       ├── auth/
│       └── initialization/
│
├── data/                # 既存構造を維持
│
└── presentation/        # 既存を整理
    ├── app/
    │   ├── app.dart
    │   └── app_providers.dart
    └── router/
        └── app_router.dart
```

### 2. 実装ステップ

#### Phase 1: 基盤整備
1. 依存性注入コンテナの設定
2. アプリケーション設定クラスの作成
3. 初期化サービスの分離

#### Phase 2: Bootstrap層の実装
1. AppBootstrapクラスの実装
2. 初期化手順の明確化
3. エラーハンドリングの強化

#### Phase 3: ルーティングの再構築
1. AppRouterの実装（go_router使用）
2. RouteGuardの実装
3. ナビゲーション状態管理の統一

#### Phase 4: Presentation層の整理
1. MyAppウィジェットの簡素化
2. SplashScreenロジックの分離
3. 状態管理の統一

#### Phase 5: テストの追加
1. 単体テストの追加
2. 統合テストの実装
3. ウィジェットテストの充実

## 新しい初期化フロー

```dart
// main.dart (簡素化)
void main() async {
  runZonedGuarded(
    () async {
      final bootstrap = AppBootstrap();
      final app = await bootstrap.initialize();
      runApp(app);
    },
    (error, stack) => CrashReporter.report(error, stack),
  );
}
```

## 期待される効果

1. **保守性の向上**
   - 責務が明確に分離される
   - 変更の影響範囲が限定される

2. **テスタビリティの向上**
   - 各層が独立してテスト可能
   - モックの注入が容易

3. **可読性の向上**
   - コードの流れが明確
   - 各クラスの責務が単一

4. **拡張性の向上**
   - 新機能の追加が容易
   - 既存コードへの影響が最小限

## タイムライン

- Phase 1-2: 基盤とBootstrap層（2日）
- Phase 3: ルーティング再構築（1日）
- Phase 4: Presentation層整理（1日）
- Phase 5: テスト追加（2日）

合計: 約6日間の作業