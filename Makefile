# ==============================================================================
# Flutter App Build Makefile
# ==============================================================================

.PHONY: help setup clean \
        run-dev-debug run-dev-profile run-dev-release \
        run-prod-debug run-prod-profile run-prod-release \
        run-appstore-debug run-appstore-profile run-appstore-release \
        run-android-dev-debug run-android-dev-profile run-android-dev-release \
        run-android-prod-debug run-android-prod-profile run-android-prod-release \
        build-ios-dev build-ios-prod build-ios-appstore \
        build-android-dev build-android-prod

# Variables
FLUTTER = flutter
DART_DEFINE_DEV = --dart-define=FLAVOR=dev --dart-define-from-file=dart_defines/dev.json
DART_DEFINE_PROD = --dart-define=FLAVOR=prod --dart-define-from-file=dart_defines/prod.json
DART_DEFINE_APPSTORE = --dart-define=FLAVOR=appstore --dart-define-from-file=dart_defines/appstore.json

# Default target
help:
	@echo "=== Flutter App Build Commands ==="
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup           - Setup project dependencies and prepare iOS"
	@echo "  make clean           - Clean project and reinstall dependencies"
	@echo ""
	@echo "Development Run Commands (iOS):"
	@echo "  make run-dev-debug   - Run dev environment in debug mode"
	@echo "  make run-dev-profile - Run dev environment in profile mode"
	@echo "  make run-dev-release - Run dev environment in release mode"
	@echo ""
	@echo "Production Run Commands (iOS):"
	@echo "  make run-prod-debug   - Run prod environment in debug mode"
	@echo "  make run-prod-profile - Run prod environment in profile mode"
	@echo "  make run-prod-release - Run prod environment in release mode"
	@echo ""
	@echo "App Store Run Commands (iOS):"
	@echo "  make run-appstore-debug   - Run appstore environment in debug mode"
	@echo "  make run-appstore-profile - Run appstore environment in profile mode"
	@echo "  make run-appstore-release - Run appstore environment in release mode"
	@echo ""
	@echo "Android Run Commands:"
	@echo "  make run-android-dev-debug   - Run Android dev in debug mode"
	@echo "  make run-android-dev-profile - Run Android dev in profile mode"
	@echo "  make run-android-dev-release - Run Android dev in release mode"
	@echo "  make run-android-prod-debug  - Run Android prod in debug mode"
	@echo "  make run-android-prod-profile- Run Android prod in profile mode"
	@echo "  make run-android-prod-release- Run Android prod in release mode"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build-ios-dev      - Build iOS dev IPA"
	@echo "  make build-ios-prod     - Build iOS prod IPA"
	@echo "  make build-ios-appstore - Build iOS appstore IPA"
	@echo "  make build-android-dev  - Build Android dev App Bundle"
	@echo "  make build-android-prod - Build Android prod App Bundle"

# ==============================================================================
# Setup Commands
# ==============================================================================

setup: setup-build-runner setup-ios
	@echo "Setup completed successfully"

setup-build-runner:
	@echo "Setting up build runner..."
	$(FLUTTER) pub get
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

setup-ios:
	@echo "Preparing iOS configuration..."
	@mkdir -p ios/Flutter
	@touch ios/Flutter/DartDefines.xcconfig
	@: > ios/Flutter/DartDefines.xcconfig

clean:
	@echo "Cleaning project..."
	$(FLUTTER) clean
	cd ios && rm -rf Pods Podfile.lock
	cd ios && pod install

# ==============================================================================
# iOS Run Commands - Development Environment
# ==============================================================================

run-dev-debug:
	@echo "Running dev environment in debug mode..."
	$(FLUTTER) run --debug $(DART_DEFINE_DEV)

run-dev-profile:
	@echo "Running dev environment in profile mode..."
	$(FLUTTER) run --profile $(DART_DEFINE_DEV)

run-dev-release:
	@echo "Running dev environment in release mode..."
	$(FLUTTER) run --release $(DART_DEFINE_DEV) --verbose

# ==============================================================================
# iOS Run Commands - Production Environment
# ==============================================================================

run-prod-debug:
	@echo "Running prod environment in debug mode..."
	$(FLUTTER) run --debug $(DART_DEFINE_PROD)

run-prod-profile:
	@echo "Running prod environment in profile mode..."
	$(FLUTTER) run --profile $(DART_DEFINE_PROD)

run-prod-release:
	@echo "Running prod environment in release mode..."
	$(FLUTTER) run --release $(DART_DEFINE_PROD)

# ==============================================================================
# iOS Run Commands - App Store Environment
# ==============================================================================

run-appstore-debug:
	@echo "Running appstore environment in debug mode..."
	$(FLUTTER) run --debug $(DART_DEFINE_APPSTORE)

run-appstore-profile:
	@echo "Running appstore environment in profile mode..."
	$(FLUTTER) run --profile $(DART_DEFINE_APPSTORE)

run-appstore-release:
	@echo "Running appstore environment in release mode..."
	$(FLUTTER) run --release $(DART_DEFINE_APPSTORE)

# ==============================================================================
# Android Run Commands - Development Environment
# ==============================================================================

run-android-dev-debug:
	@echo "Running Android dev environment in debug mode..."
	$(FLUTTER) run --debug --flavor dev $(DART_DEFINE_DEV)

run-android-dev-profile:
	@echo "Running Android dev environment in profile mode..."
	$(FLUTTER) run --profile --flavor dev $(DART_DEFINE_DEV)

run-android-dev-release:
	@echo "Running Android dev environment in release mode..."
	$(FLUTTER) run --release --flavor dev $(DART_DEFINE_DEV)

run-android-dev-release-verbose:
	@echo "Running Android dev environment in release mode (verbose)..."
	$(FLUTTER) run --verbose --release --flavor dev $(DART_DEFINE_DEV)

# ==============================================================================
# Android Run Commands - Production Environment
# ==============================================================================

run-android-prod-debug:
	@echo "Running Android prod environment in debug mode..."
	$(FLUTTER) run --debug --flavor prod $(DART_DEFINE_PROD)

run-android-prod-profile:
	@echo "Running Android prod environment in profile mode..."
	$(FLUTTER) run --profile --flavor prod $(DART_DEFINE_PROD)

run-android-prod-release:
	@echo "Running Android prod environment in release mode..."
	$(FLUTTER) run --release --flavor prod $(DART_DEFINE_PROD)

# ==============================================================================
# iOS Build Commands
# ==============================================================================

build-ios-dev:
	@echo "Building iOS dev IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_DEV)

build-ios-prod:
	@echo "Building iOS prod IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_PROD)

build-ios-appstore:
	@echo "Building iOS appstore IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_APPSTORE)

# ==============================================================================
# Android Build Commands
# ==============================================================================

build-android-dev:
	@echo "Building Android dev App Bundle..."
	$(FLUTTER) build appbundle --flavor dev --release $(DART_DEFINE_DEV)

build-android-prod:
	@echo "Building Android prod App Bundle..."
	$(FLUTTER) build appbundle --flavor prod --release $(DART_DEFINE_PROD)

# ==============================================================================
# Legacy Aliases (for backward compatibility)
# ==============================================================================

dev: run-dev-debug
prod: run-prod-debug




# ==============================================================================
# Firebase Functions Deploy Commands
# ==============================================================================

.PHONY: firebase-help firebase-serve firebase-use-dev firebase-use-prod \
        firebase-deploy-dev firebase-deploy-prod \
        firebase-deploy-dev-function firebase-deploy-prod-function

# Firebase project IDs
FIREBASE_DEV_PROJECT := chat-sns-project
FIREBASE_PROD_PROJECT := blank-project-prod

firebase-help:
	@echo "=== Firebase Functions Commands ==="
	@echo ""
	@echo "Environment Commands:"
	@echo "  make firebase-use-dev           - Switch to development environment"
	@echo "  make firebase-use-prod          - Switch to production environment"
	@echo ""
	@echo "Deploy Commands:"
	@echo "  make firebase-deploy-dev        - Deploy all functions to development"
	@echo "  make firebase-deploy-prod       - Deploy all functions to production"
	@echo ""
	@echo "Selective Deploy Commands:"
	@echo "  make firebase-deploy-dev-function FUNCTION=funcName   - Deploy specific function to dev"
	@echo "  make firebase-deploy-prod-function FUNCTION=funcName  - Deploy specific function to prod"
	@echo ""
	@echo "Local Development:"
	@echo "  make firebase-serve             - Start local Firebase emulator"

firebase-use-dev:
	@echo "Switching to development environment ($(FIREBASE_DEV_PROJECT))..."
	firebase use development
	@echo "Current project: $(FIREBASE_DEV_PROJECT)"

firebase-use-prod:
	@echo "Switching to production environment ($(FIREBASE_PROD_PROJECT))..."
	firebase use production
	@echo "Current project: $(FIREBASE_PROD_PROJECT)"

firebase-deploy-dev:
	@echo "Deploying all functions to development environment ($(FIREBASE_DEV_PROJECT))..."
	firebase use development
	firebase deploy --only functions --project=$(FIREBASE_DEV_PROJECT)

firebase-deploy-prod:
	@echo "Deploying all functions to production environment ($(FIREBASE_PROD_PROJECT))..."
	firebase use production
	firebase deploy --only functions --project=$(FIREBASE_PROD_PROJECT)

firebase-deploy-dev-function:
	@if [ -z "$(FUNCTION)" ]; then \
		echo "Error: Function name required. Usage: make firebase-deploy-dev-function FUNCTION=funcName"; \
		exit 1; \
	fi
	@echo "Deploying function $(FUNCTION) to development environment ($(FIREBASE_DEV_PROJECT))..."
	firebase use development
	firebase deploy --only functions:$(FUNCTION) --project=$(FIREBASE_DEV_PROJECT)

firebase-deploy-prod-function:
	@if [ -z "$(FUNCTION)" ]; then \
		echo "Error: Function name required. Usage: make firebase-deploy-prod-function FUNCTION=funcName"; \
		exit 1; \
	fi
	@echo "Deploying function $(FUNCTION) to production environment ($(FIREBASE_PROD_PROJECT))..."
	firebase use production
	firebase deploy --only functions:$(FUNCTION) --project=$(FIREBASE_PROD_PROJECT)

firebase-serve:
	@echo "Starting Firebase Functions local emulator..."
	firebase emulators:start --only functions

# ==============================================================================
# Legacy Aliases (for backward compatibility)
# ==============================================================================

functions-help: firebase-help
deploy-dev: firebase-deploy-dev
deploy-prod: firebase-deploy-prod
deploy-dev-only: firebase-deploy-dev-function
deploy-prod-only: firebase-deploy-prod-function
serve: firebase-serve
use-dev: firebase-use-dev
use-prod: firebase-use-prod