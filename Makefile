# .PHONY は、実際のファイルではなくタスクであることを示す
.PHONY: dev prod clean

# 変数定義
FLUTTER = flutter
DART_DEFINE_DEV = --dart-define=FLAVOR=dev --dart-define-from-file=dart_defines/dev.env
DART_DEFINE_PROD = --dart-define=FLAVOR=prod --dart-define-from-file=dart_defines/prod.env

# デフォルトのターゲット（makeコマンドだけで実行される）
all: dev

# 開発環境用のタスク
dev:
	@echo "Starting development build..."
	$(FLUTTER) run $(DART_DEFINE_DEV)

# 本番環境用のタスク
prod:
	@echo "Starting production build..."
	$(FLUTTER) run $(DART_DEFINE_PROD)
# リリースビルド用のタスク
dev-release:
	@echo "Building release version of DEVELOPMENT MODE..."
	$(FLUTTER) run --release $(DART_DEFINE_DEV)

# リリースビルド用のタスク
prod-release:
	@echo "Building release version of RELEASE MODE..."
	$(FLUTTER) run --release $(DART_DEFINE_PROD)

# リリースビルド用のタスク
build-dev:
	@echo "Building release version of DEVELOPMENT MODE..."
	$(FLUTTER) build ios --release $(DART_DEFINE_DEV)

# リリースビルド用のタスク
build-prod:
	@echo "Building release version of RELEASE MODE..."
	$(FLUTTER) build ios --release $(DART_DEFINE_PROD)

# クリーンアップ用のタスク
clean:
	@echo "Cleaning the project..."
	$(FLUTTER) clean
	cd ios && rm -rf Pods Podfile.lock
	cd ios && pod install