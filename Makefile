.PHONY: dev prod clean dev-debug dev-profile dev-release prod-debug prod-profile prod-release build-dev build-prod

FLUTTER = flutter
DART_DEFINE_DEV = --dart-define-from-file=dart_defines/dev.env
DART_DEFINE_PROD = --dart-define-from-file=dart_defines/prod.env
DART_DEFINE_APPSTORE = --dart-define-from-file=dart_defines/appstore.env


#build runner
build-runner:
	@echo "Activating build runner..."
	flutter pub run build_runner build --delete-conflicting-outputs

.PHONY: prepare-ios
prepare-ios:
	@echo "Copying xcconfig file to Flutter directory..."
	@mkdir -p ios/Flutter
	@touch ios/Flutter/DartDefines.xcconfig
	@echo "Cleaning DartDefines.xcconfig..."
	@: > ios/Flutter/DartDefines.xcconfig

#dev-ios
dev-profile: 
	@echo "Starting dev profile build..."
	$(FLUTTER) run --profile $(DART_DEFINE_DEV)

dev-release:
	@echo "Starting dev release build..."
	$(FLUTTER) run --release $(DART_DEFINE_DEV)

#dev-android
dev-android-release:
	@echo "Starting Android dev release build..."
	$(FLUTTER) run --flavor dev --release $(DART_DEFINE_DEV)

dev-android-release-verbose:
	@echo "Starting Android dev release build..."
	$(FLUTTER) run --verbose --flavor dev --release $(DART_DEFINE_DEV)

#prod-ios
prod-profile:
	@echo "Starting prod profile build..."
	$(FLUTTER) run --profile $(DART_DEFINE_PROD)

prod-release:
	@echo "Starting prod release build..."
	$(FLUTTER) run --release $(DART_DEFINE_PROD)

prod-android-release:
	@echo "Starting Android prod release build..."
	$(FLUTTER) run --flavor prod --release $(DART_DEFINE_PROD)

appstore-release:
	@echo "Starting appstore release build..."
	$(FLUTTER) run --release $(DART_DEFINE_APPSTORE)

#build-ios
build-dev:
	@echo "Building dev IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_DEV)

build-prod:
	@echo "Building prod IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_PROD)

build-appstore:
	@echo "Building appstore IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_APPSTORE)

#build-android
build-android-dev:
	@echo "Building Android dev App Bundle..."
	$(FLUTTER) build appbundle --flavor dev --release $(DART_DEFINE_DEV)


build-android-prod:
	@echo "Building Android prod App Bundle..."
	$(FLUTTER) build appbundle --flavor prod --release $(DART_DEFINE_PROD)

dev: dev-debug
prod: prod-debug

.PHONY: clean-ios
clean-ios:
	@echo "Cleaning project..."
	$(FLUTTER) clean
	cd ios && rm -rf Pods Podfile.lock
	cd ios && pod install



# Firebase Functionsデプロイ用Makefile

# プロジェクトID定義
DEV_PROJECT := chat-sns-project
PROD_PROJECT := blank-project-prod

# デフォルトターゲット
.PHONY: help
functions-help:
	@echo "使用可能なコマンド:"
	@echo "  make deploy-dev        - 開発環境(chat-sns-project)にFunctionsをデプロイ"
	@echo "  make deploy-prod       - 本番環境(blank-project-prod)にFunctionsをデプロイ"
	@echo "  make deploy-dev-only X - 開発環境の特定のFunction(X)のみデプロイ"
	@echo "  make deploy-prod-only X - 本番環境の特定のFunction(X)のみデプロイ"
	@echo "  make serve             - Functionsをローカルでエミュレート"
	@echo "  make use-dev           - 開発環境を使用するよう.firebasercを更新"
	@echo "  make use-prod          - 本番環境を使用するよう.firebasercを更新"

# 開発環境へのデプロイ
.PHONY: deploy-dev
deploy-dev:
	@echo "開発環境($(DEV_PROJECT))にFunctionsをデプロイします..."
	firebase use development
	firebase deploy --only functions --project=$(DEV_PROJECT)

# 本番環境へのデプロイ
.PHONY: deploy-prod
deploy-prod:
	@echo "本番環境($(PROD_PROJECT))にFunctionsをデプロイします..."
	firebase use production
	firebase deploy --only functions --project=$(PROD_PROJECT)

# 開発環境の特定のFunctionのみデプロイ
.PHONY: deploy-dev-only
deploy-dev-only:
	@if [ -z "$(FUNCTION)" ]; then \
		echo "関数名を指定してください: make deploy-dev-only FUNCTION=funcName"; \
		exit 1; \
	fi
	@echo "開発環境($(DEV_PROJECT))にFunction $(FUNCTION)をデプロイします..."
	firebase use development
	firebase deploy --only functions:$(FUNCTION) --project=$(DEV_PROJECT)

# 本番環境の特定のFunctionのみデプロイ
.PHONY: deploy-prod-only
deploy-prod-only:
	@if [ -z "$(FUNCTION)" ]; then \
		echo "関数名を指定してください: make deploy-prod-only FUNCTION=funcName"; \
		exit 1; \
	fi
	@echo "本番環境($(PROD_PROJECT))にFunction $(FUNCTION)をデプロイします..."
	firebase use production
	firebase deploy --only functions:$(FUNCTION) --project=$(PROD_PROJECT)

# Functionsのローカルエミュレーション
.PHONY: serve
serve:
	@echo "Functionsをローカルでエミュレートします..."
	firebase emulators:start --only functions

# 開発環境を使用するよう設定
.PHONY: use-dev
use-dev:
	@echo "開発環境($(DEV_PROJECT))を使用するよう設定します..."
	firebase use development
	@echo "現在のプロジェクト: $(DEV_PROJECT)"

# 本番環境を使用するよう設定
.PHONY: use-prod
use-prod:
	@echo "本番環境($(PROD_PROJECT))を使用するよう設定します..."
	firebase use production
	@echo "現在のプロジェクト: $(PROD_PROJECT)"