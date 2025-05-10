.PHONY: dev prod clean dev-debug dev-profile dev-release prod-debug prod-profile prod-release build-dev build-prod

FLUTTER = flutter
DART_DEFINE_DEV = --dart-define=FLAVOR=dev --dart-define-from-file=dart_defines/dev.env
DART_DEFINE_PROD = --dart-define=FLAVOR=prod --dart-define-from-file=dart_defines/prod.env

build-runner:
	@echo "Activating build runner..."
	flutter pub run build_runner build --delete-conflicting-outputs

dev-debug:
	@echo "Starting dev debug build..."
	$(FLUTTER) run $(DART_DEFINE_DEV)

dev-profile:
	@echo "Starting dev profile build..."
	$(FLUTTER) run --profile $(DART_DEFINE_DEV)

dev-release:
	@echo "Starting dev release build..."
	$(FLUTTER) run --release $(DART_DEFINE_DEV)

dev-android-release:
	@echo "Starting Android dev release build..."
	$(FLUTTER) run --flavor dev --release $(DART_DEFINE_DEV)

dev-android-release-verbose:
	@echo "Starting Android dev release build..."
	$(FLUTTER) run --verbose --flavor dev --release $(DART_DEFINE_DEV)

build-dev:
	@echo "Building dev IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_DEV)

build-android-dev:
	@echo "Building Android dev App Bundle..."
	$(FLUTTER) build appbundle --flavor dev --release $(DART_DEFINE_DEV)

prod-debug:
	@echo "Starting prod debug build..."
	$(FLUTTER) run $(DART_DEFINE_PROD)

prod-profile:
	@echo "Starting prod profile build..."
	$(FLUTTER) run --profile $(DART_DEFINE_PROD)

prod-release:
	@echo "Starting prod release build..."
	$(FLUTTER) run --release $(DART_DEFINE_PROD)

prod-android-release:
	@echo "Starting Android prod release build..."
	$(FLUTTER) run --flavor prod --release $(DART_DEFINE_PROD)

build-prod:
	@echo "Building prod IPA..."
	$(FLUTTER) build ipa --release $(DART_DEFINE_PROD)


build-android-prod:
	@echo "Building Android prod App Bundle..."
	$(FLUTTER) build appbundle --flavor prod --release $(DART_DEFINE_PROD)

dev: dev-debug
prod: prod-debug

clean:
	@echo "Cleaning project..."
	$(FLUTTER) clean
	cd ios && rm -rf Pods Podfile.lock
	cd ios && pod install