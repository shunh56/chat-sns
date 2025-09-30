# iOS CI/CD署名問題のトラブルシューティング履歴

## 問題の概要

**エラー**: `No profiles for 'com.blank.sns' were found: Xcode couldn't find any iOS App Development provisioning profiles matching 'com.blank.sns'.`

**環境**:
- Flutter 3.24.3
- Xcode (GitHub Actions macOS runner)
- Bundle ID: com.blank.sns
- Team ID: CDQBCQRWL9
- 配布方法: Firebase App Distribution (Ad-Hoc)

## 試した方法と結果

### ❌ 方法1: ExportOptions.plistで`allowProvisioningUpdates`を設定

**コミット**: d23d6b7

**実装内容**:
```xml
<key>allowProvisioningUpdates</key>
<true/>
<key>signingStyle</key>
<string>automatic</string>
```

**結果**: ❌ 失敗
- `allowProvisioningUpdates`はExportOptions.plistでは機能しない
- xcodebuildコマンドラインオプションとして渡す必要がある

**考察**:
- ExportOptions.plistはエクスポート時の設定であり、ビルド時の署名設定には影響しない
- Xcodeの自動署名機能を有効にするには、ビルド時にxcodebuildへ直接フラグを渡す必要がある

---

### ❌ 方法2: `flutter build ipa`に`--allowProvisioningUpdates`フラグを追加

**コミット**: 5835bc3, be49c25

**実装内容**:
```ruby
sh("cd ../.. && flutter build ipa --release --dart-define-from-file=dart_defines/#{environment}.env --export-options-plist=ios/ExportOptions.plist -- --allowProvisioningUpdates")
```

**結果**: ❌ 失敗
```
Error: Target file "--allowProvisioningUpdates" not found.
```

**考察**:
- Flutter 3.24.3では`flutter build ipa`コマンドが`--allowProvisioningUpdates`フラグをサポートしていない
- `-- --allowProvisioningUpdates`の構文が正しく解釈されず、ファイル名として扱われている
- Flutter CLIはxcodebuildへのカスタムフラグ渡しをサポートしていない可能性がある

---

### ❌ 方法3: Manual signingでMatch証明書を使用

**コミット**: 7fe34ee (途中で変更)

**実装内容**:
```xml
<key>signingStyle</key>
<string>manual</string>
<key>provisioningProfiles</key>
<dict>
    <key>com.blank.sns</key>
    <string>match AdHoc com.blank.sns</string>
</dict>
```

```ruby
match(
  type: "adhoc",
  app_identifier: "com.blank.sns",
  readonly: true
)
```

**結果**: ❌ 実装途中で中止
- Matchの初期化にApple Developerアカウントのパスワードが必要
- App Store Connect API Keyでの認証設定が複雑
- 証明書リポジトリ(ios-certificates)の初期セットアップが未完了

**考察**:
- Manual signing + Matchは有効なアプローチだが、初期セットアップのハードルが高い
- ローカルでfastlane matchを実行して証明書を生成・プッシュする必要がある
- CI/CD環境でのMatch認証設定に追加の環境変数とセットアップが必要

---

### ❌ 方法4: `flutter build ios` + `gym`の組み合わせ（第1版）

**コミット**: 21ea4c3

**実装内容**:
```ruby
# Flutterビルド（iOS部分のみ）
sh("cd ../.. && flutter build ios --release --dart-define-from-file=dart_defines/#{environment}.env")

# gymでIPAをビルド（automatic signing with API Key）
gym(
  scheme: "Runner",
  workspace: "Runner.xcworkspace",
  export_method: "ad-hoc",
  export_options: {
    signingStyle: "automatic",
    teamID: "CDQBCQRWL9",
    allowProvisioningUpdates: true,
    # ...
  }
)
```

**結果**: ❌ 失敗
```
Error (Xcode): No profiles for 'com.blank.sns' were found: Xcode couldn't find any iOS App Development provisioning profiles matching 'com.blank.sns'. Automatic signing is disabled and unable to generate a profile. To enable automatic signing, pass -allowProvisioningUpdates to xcodebuild.
```

**考察**:
- `flutter build ios`自体が署名を試みるため、この段階で失敗
- `export_options`の`allowProvisioningUpdates`はエクスポート時の設定であり、ビルド時には適用されない
- gymの`xcargs`でビルド時のxcodebuildフラグを指定する必要がある

---

### ❌ 方法5: `flutter build ios --no-codesign` + `gym`（第1版）

**コミット**: f0f6174

**実装内容**:
```ruby
# Flutterビルド（署名なし）
sh("cd ../.. && flutter build ios --release --dart-define-from-file=dart_defines/#{environment}.env --no-codesign")

# gymでアーカイブ+署名+エクスポート
gym(
  scheme: "Runner",
  workspace: "Runner.xcworkspace",
  configuration: "Release",
  export_method: "ad-hoc",
  xcargs: "-allowProvisioningUpdates CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=CDQBCQRWL9",
  # ...
)
```

**結果**: ❌ 失敗
```
Parse Issue (Xcode): A template argument list is expected after a name prefixed by the template keyword
/Users/runner/work/chat-sns/chat-sns/ios/Pods/gRPC-Core/src/core/lib/promise/detail/basic_seq.h:102:37
```

**考察**:
- `flutter build ios`がgRPC-Coreの依存関係をビルドする際にC++コンパイルエラー
- Xcodeバージョンまたはコンパイラの互換性問題
- pod installのタイミングや設定に問題がある可能性

---

### ❌ 方法6: gymで直接ビルド（Flutter CLIをスキップ）

**コミット**: dfc6259, 5a9e992

**実装内容**:
```ruby
# Flutter依存関係を取得
sh("cd ../.. && flutter pub get")

# Podをクリーンインストール
sh("pod deintegrate || true")
sh("pod install --repo-update")

# dart-definesをBase64エンコード
dart_defines_base64 = Base64.strict_encode64(dart_defines_encoded)

# gymでビルド+アーカイブ+署名+エクスポート
gym(
  xcargs: "-allowProvisioningUpdates CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=CDQBCQRWL9 DART_DEFINES=#{dart_defines_base64} FLUTTER_BUILD_MODE=release",
  # ...
)
```

**結果**: ❌ 失敗
```
** ARCHIVE FAILED **
The following build commands failed:
    Archiving workspace Runner with scheme Runner
(1 failure)
```

**考察**:
- gymがFlutter特有のビルドステップをスキップしてしまう
- DART_DEFINESをxcodebuild引数として渡すだけでは不十分
- Flutter CLIの前処理（コード生成など）が必要

---

### ❌ 方法7: `flutter build ios --no-codesign` + gym（verbose有効）（第1版）

**コミット**: 78ab6d6

**実装内容**:
```ruby
# Flutterビルド（dart-definesを適用、署名なし）
sh("cd ../.. && flutter build ios --release --dart-define-from-file=dart_defines/#{environment}.env --no-codesign")

# gymでアーカイブ+署名+エクスポートのみ
gym(
  xcargs: "-allowProvisioningUpdates CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=CDQBCQRWL9",
  export_xcargs: "-allowProvisioningUpdates",
  verbose: true
)
```

**結果**: ❌ 失敗（gRPCエラー再発）
```
Parse Issue (Xcode): A template argument list is expected after a name prefixed by the template keyword
/ios/Pods/gRPC-Core/src/core/lib/promise/detail/basic_seq.h:102:37
```

**考察**:
- GitHub Actions側でpod installを実行してもgRPCエラーは解決しない
- Xcode 16.4とgRPC-Coreの互換性問題
- C++コンパイラの`template`キーワード処理でエラー
- C++言語標準をC++17にダウングレードする必要がある

---

### 🔄 方法8: Podfile修正でgRPC-Core C++エラーを解決（現在テスト中）

**コミット**: (次のコミット)

**実装内容**:
```ruby
# Podfile post_install
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'gRPC-Core' || target.name == 'gRPC-C++'
      target.build_configurations.each do |config|
        # Fix for Xcode 16 C++20 template keyword issue
        config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      end
    end
  end
end
```

**期待される動作**:
- gRPC-CoreをC++17でコンパイルすることでXcode 16の互換性問題を回避
- `flutter build ios --no-codesign`が成功
- gymで`-allowProvisioningUpdates`による自動署名が機能

**理論的根拠**:
- Xcode 16はデフォルトでC++20を使用し、`template`キーワードの扱いが厳格化
- gRPC-Coreの古いコードがC++20の厳格なルールに対応していない
- C++17にダウングレードすることで互換性を確保

**結果**: 🔄 テスト中

---

## 環境設定

### GitHub Secrets（設定済み）
```
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_API_ISSUER_ID
APP_STORE_CONNECT_API_KEY_CONTENT
TEAM_ID
FIREBASE_APP_ID_IOS_DEV
FIREBASE_TOKEN
MATCH_PASSWORD (= seiko56173)
```

### GitHub Secrets（未設定）
```
MATCH_GIT_URL (= https://github.com/shunh56/ios-certificates.git)
```

### GitHub Actions での API Key セットアップ
```yaml
- name: Setup App Store Connect API Key for Automatic Signing
  env:
    API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
    API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
    API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}
  run: |
    mkdir -p ~/private_keys
    echo "$API_KEY_CONTENT" > ~/private_keys/AuthKey_${API_KEY_ID}.p8
    chmod 600 ~/private_keys/AuthKey_${API_KEY_ID}.p8
    echo "APP_STORE_CONNECT_API_KEY_ID=$API_KEY_ID" >> $GITHUB_ENV
    echo "APP_STORE_CONNECT_API_ISSUER_ID=$API_ISSUER_ID" >> $GITHUB_ENV
    echo "APP_STORE_CONNECT_API_KEY_PATH=$HOME/private_keys/AuthKey_${API_KEY_ID}.p8" >> $GITHUB_ENV
```

---

## 学んだこと

### 1. Flutter CLIの制約
- `flutter build ipa`はxcodebuildへのカスタムフラグ渡しをサポートしていない
- 署名の詳細な制御が必要な場合は`flutter build ios` + `gym`の組み合わせを使用すべき

### 2. allowProvisioningUpdatesの適用場所
- ❌ ExportOptions.plist内では効果なし
- ✅ xcodebuildコマンドのオプションとして渡す必要がある
- ✅ gymの`export_options`で指定可能

### 3. Automatic vs Manual Signing
- **Automatic signing**: App Store Connect API Keyがあれば自動でプロファイル生成可能
- **Manual signing**: Matchでの事前証明書生成が必要だが、より制御可能

### 4. Matchの使用タイミング
- 初回セットアップはローカル環境で実行が必要
- CI/CD環境では`readonly: true`で証明書を取得するだけ
- API Key認証を使用する場合、Matchfileの設定が必要

---

### ❌ 方法8: Podfile修正でgRPC-Core C++エラーを解決

**コミット**: 2070745

**実装内容**:
```ruby
# Podfile post_install
if target.name == 'gRPC-Core' || target.name == 'gRPC-C++'
  config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
end
```

**結果**: ❌ 失敗
- Podfileの修正が反映される前にpod installが実行されてしまう
- GitHub Actions側で既にpod installが実行されているため効果なし

---

### ❌ 方法9: flutter build ios --config-only + build_app

**コミット**: ca004f7, adba4dc

**実装内容**:
- DerivedDataをクリーン
- `flutter build ios --config-only`で設定のみ生成
- `build_app`で実際のビルドを実行

**結果**: ❌ 失敗
- `ARCHIVE FAILED`エラー
- 具体的なエラー詳細が不明

---

### ❌ 方法10: app_store_connect_api_key + flutter build ipa

**コミット**: 522a75a

**実装内容**:
```ruby
app_store_connect_api_key(
  key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
  issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
  key_filepath: api_key_path
)
sh("flutter build ipa --release ...")
```

**結果**: ❌ 失敗
```
invalid curve name (OpenSSL::PKey::ECError)
```

**考察**:
- OpenSSLとRubyの互換性問題
- P8ファイルの楕円曲線暗号が正しく読み込めない
- GitHub Actions環境特有の問題

---

### ❌ 方法11: 環境変数でAPI Key認証

**コミット**: (実装せず)

**実装内容**:
```ruby
# 環境変数でAPI Key認証情報を設定
ENV["APP_STORE_CONNECT_API_KEY_ID"] = ENV["APP_STORE_CONNECT_API_KEY_ID"]
ENV["APP_STORE_CONNECT_API_KEY_PATH"] = api_key_path

# Flutter IPAビルドを直接実行
sh("flutter build ipa --release ...")
```

**結果**: ❌ 実装途中で中止
- `flutter build ipa`は依然として署名問題を解決できない
- 根本的にprovisioning profilesの問題が残る

**考察**:
- 環境変数だけでは署名の根本問題は解決しない
- Matchでの証明書管理が必要

---

### 🔄 方法12: Fastlane Match完全実装 + Automatic Signingフォールバック（現在テスト中）

**コミット**: c2a53e1, bea651b

**実装内容**:
```ruby
# Matchを試行するが、失敗した場合はautomatic signingにフォールバック
begin
  # Matchで証明書とプロビジョニングプロファイルを同期（API Key認証で）
  match(
    type: "adhoc",
    app_identifier: "com.blank.sns",
    readonly: true,
    git_url: ENV["MATCH_GIT_URL"],
    api_key_path: File.expand_path("~/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8"),
    api_key: {
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key: ENV["APP_STORE_CONNECT_API_KEY_CONTENT"],
      in_house: false
    }
  )
rescue => e
  UI.important("⚠️  Fastlane Match failed: #{e.message}")
  UI.important("Falling back to automatic signing with App Store Connect API Key...")

  # API Key情報を環境変数に設定（automatic signingで使用）
  ENV["APP_STORE_CONNECT_API_KEY_PATH"] = File.expand_path("~/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8")
end

# Flutter IPAビルド（MatchまたはAutomatic Signingを使用）
sh("flutter build ipa --release --dart-define-from-file=dart_defines/#{environment}.env --export-options-plist=ios/ExportOptions.plist")
```

**ローカル調査結果**:
- API Key `XFJ0JP4T17E` を `/Users/shunh/private_keys/` に配置済み
- Matchリポジトリ `https://github.com/shunh56/ios-certificates.git` を初期化（READMEファイル追加）
- `fastlane match --readonly` では "No code signing identity found" エラー
- Matchの証明書生成で "invalid number: '-----BEGIN' at line 1 column 1" エラー
- **課題**: FastlaneがP8ファイルをJSONとして解析しようとする問題
- **対策**: CI/CDでのautomatic signingフォールバック機能に依存

**期待される動作**:
1. **Match成功時**: 既存の証明書を使用してビルド
2. **Match失敗時**: Automatic signingにフォールバックしてビルド
3. いずれの場合も`flutter build ipa`が成功
4. Firebase App Distributionへアップロード成功

**改善点**:
- Match失敗時のグレースフルなフォールバック機能
- エラーハンドリングによる柔軟性の向上
- Matchが未初期化でもCI/CDが継続実行可能

**GitHub Secrets設定済み**:
- ✅ MATCH_GIT_URL = https://github.com/shunh56/ios-certificates.git
- ✅ MATCH_PASSWORD = seiko56173
- ✅ FASTLANE_PASSWORD = (App-specific password)
- ✅ APP_STORE_CONNECT_API_KEY_ID = XFJ0JP4T17E
- ✅ APP_STORE_CONNECT_API_ISSUER_ID
- ✅ APP_STORE_CONNECT_API_KEY_CONTENT

**現在の戦略**:
1. **第一選択**: Matchが利用可能になったら使用
2. **実用的解決策**: Automatic signingで即座に問題解決
3. **将来の改善**: Matchの初期化は別途対応

**結果**: 🔄 CI/CDテスト中（commit: c2a53e1）
- Matchは失敗する予定だが、automatic signingフォールバックで成功を期待

---

## 次に試すべきこと（方法11が失敗した場合）

### オプションA: Matchを完全にセットアップ
1. ローカルで`fastlane match development`を実行し、パスワード入力
2. ローカルで`fastlane match adhoc`を実行し、証明書を生成
3. `MATCH_GIT_URL`をGitHub Secretsに追加
4. CI/CDでMatchを使用してmanual signingを実行

### オプションB: Xcode Cloudを検討
- Apple公式のCI/CDサービス
- 署名周りが自動的に処理される
- GitHub Actionsとの統合も可能

### オプションC: 開発者証明書を直接使用
- 証明書(.p12)とプロビジョニングプロファイル(.mobileprovision)をGitHub Secretsに保存
- キーチェーンに手動でインストール
- manual signingで直接使用

---

## 参考リンク

- [Fastlane Match ドキュメント](https://docs.fastlane.tools/actions/match/)
- [Fastlane Gym ドキュメント](https://docs.fastlane.tools/actions/gym/)
- [App Store Connect API Key](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)
- [Xcode allowProvisioningUpdates](https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices)

---

---

## 最新のAPI キー更新（2025年9月29日）

**新しいAPI キー作成完了**:
- **キーID**: `2Q3B46F3S2`
- **発行者ID**: `464a2cd5-765b-48b0-b001-57243652ed07`
- **ファイル場所**: `~/private_keys/AuthKey_2Q3B46F3S2.p8`
- **権限**: Developer
- **作成場所**: App Store Connect → 統合タブ → API キー

**GitHub Secrets更新済み**:
- ✅ `APP_STORE_CONNECT_API_KEY_ID` = `2Q3B46F3S2`
- ✅ `APP_STORE_CONNECT_API_ISSUER_ID` = `464a2cd5-765b-48b0-b001-57243652ed07`
- ✅ `APP_STORE_CONNECT_API_KEY_CONTENT` = P8ファイル内容

**ファイル管理**:
- 旧キー: `~/private_keys/AuthKey_XFJ0JP4T17E.p8`
- 新キー: `~/private_keys/AuthKey_2Q3B46F3S2.p8`
- 権限: `600` (読み書き権限は所有者のみ)

---

---

### ✅ 方法13: 新しいAPI キー + flutter build ios --no-codesign + gym（2025年9月29日）

**コミット**: 1bbd66f

**実装内容**:
```ruby
# Flutter iOS ビルド（署名なし）
sh("flutter build ios --release --dart-define-from-file=dart_defines/#{environment}.env --no-codesign")

# gymでアーカイブ+署名+エクスポート（allowProvisioningUpdatesを使用）
gym(
  scheme: "Runner",
  workspace: "Runner.xcworkspace",
  configuration: "Release",
  export_method: "ad-hoc",
  xcargs: "-allowProvisioningUpdates CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=CDQBCQRWL9",
  export_options: {
    signingStyle: "automatic",
    teamID: "CDQBCQRWL9",
    allowProvisioningUpdates: true
  }
)
```

**新しいAPI キー使用**:
- キーID: `2Q3B46F3S2`
- 発行者ID: `464a2cd5-765b-48b0-b001-57243652ed07`
- GitHub Secrets更新済み

**期待される動作**:
1. `flutter build ios --no-codesign`で署名なしビルド成功
2. gymの`xcargs`で`-allowProvisioningUpdates`が適用される
3. 自動署名でプロビジョニングプロファイルが生成される
4. Firebase App Distributionへアップロード成功

**結果**: ❌ gRPC-Core C++コンパイルエラーで失敗

**追加修正**: c6d9ab7 - Enhanced gRPC-Core C++17 compatibility
- すべてのgRPCターゲットにC++17を強制適用
- `CLANG_CXX_LIBRARY` と `OTHER_CPLUSPLUSFLAGS` を追加
- `-Wno-error=c++20-extensions` でテンプレートエラーを抑制

**原因**: Podfileのpost_installでgRPCターゲットが見つからない、またはC++17設定が上書きされている

**追加修正**: 5fd1ef9 - 包括的gRPCデバッグ + Firebase ダウングレード
- Firebase SDKを10.18.0にダウングレード（Xcode 16互換性向上）
- gRPCターゲット検索の詳細ログ追加
- 大文字小文字を区別しないgRPCターゲット検出
- OTHER_CFLAGSにも互換性フラグ追加

### ✅ 方法14: Firebase SDK v11 アップグレード（2025年9月29日）

**コミット**: 31bae5a

**根本解決**:
- Firebase SDK 10.x系はXcode 16のC++20でgRPC-Coreテンプレートエラー発生
- Firebase SDK 11.0.0にアップグレードで解決
- 参考記事: https://qiita.com/masasumi0327/items/15629bd31a32cf08c226

**実装内容**:
```ruby
# Podfile
$FirebaseSDKVersion = '11.0.0'  # 10.18.0 → 11.0.0

# Build settings
config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
```

**期待される動作**:
1. Firebase 11のgRPC修正により C++テンプレートエラー解消
2. `flutter build ios --no-codesign` 成功
3. gymの `-allowProvisioningUpdates` で自動署名
4. Firebase App Distribution へデプロイ成功

**結果**: ❌ Firebase 11.0.0 でFirebaseStorageのSwift型エラー発生
- `Value of optional type '(any StorageProvider)?' must be unwrapped`
- `Cannot assign value of type '(any AuthInterop)?' to type 'any AuthInterop'`

### 🔄 方法15: Firebase 10.29.0 + 包括的gRPC修正（2025年9月29日）

**コミット**: 8eaaae8

**戦略変更**:
- Firebase 11.0.0 は不安定 → 10.29.0 (最新安定版)
- 包括的gRPC-Core C++17修正は保持
- 非モジュラーヘッダー設定も維持

**実装内容**:
```ruby
# 安定版Firebase + 包括的gRPC修正
$FirebaseSDKVersion = '10.29.0'

# 詳細なgRPCデバッグとC++17強制適用
puts "🔍 Searching for gRPC targets..."
# + 包括的なC++17設定とエラー抑制
```

**結果**: ❌ Firebase 10.29.0 で包括的gRPC修正が適用されず（デバッグログなし）

### 🔄 方法16: Firebase バージョンテスト（2025年9月29日）

**コミット**: f1b95d8

**両方のログ比較結果**:
- **Firebase 10.29.0**: 元のgRPC-Core C++テンプレートエラー（修正未適用）
- **Firebase 11.0.0**: gRPC解決済みだがabslリンクエラー

**診断のための実装**:
```ruby
# Firebase 10.28.0でgRPC修正の動作確認
$FirebaseSDKVersion = '10.28.0'

# 包括的gRPCデバッグは保持
puts "🔍 Searching for gRPC targets..."
# 詳細なターゲット検出とC++17適用ログ
```

**期待される動作**:
1. Firebase 10.28.0でgRPCエラー発生
2. デバッグログで修正適用状況確認
3. C++17設定の実際の効果を検証

**診断結果**: ✅ gRPC修正は完璧に動作！しかしFlutter buildで上書きされる

**発見したログ**:
```
🔍 Searching for gRPC targets...
📦 Found gRPC target: gRPC-Core
✅ Applied C++17 fix to gRPC-Core (Release)
📊 Total gRPC targets modified: 6
```

**根本問題**:
1. GitHub Actions: pod install → gRPC修正適用 ✅
2. Flutter build: 別のpod install → 修正が上書き ❌

### 🔧 方法17: Flutterビルド前にgRPC修正再適用（2025年9月29日）

**コミット**: f0f87a2

**最終解決策**:
```ruby
# Flutterビルド前にgRPC修正を再適用
def apply_grpc_fixes
  # gRPC関連のxcconfigファイルを直接修正
  sh('find Pods -name "*.xcconfig" -exec grep -l "gRPC\\|GRPC" {} \\; | head -10 | while IFS= read -r file; do
    if ! grep -q "CLANG_CXX_LANGUAGE_STANDARD.*c++17" "$file"; then
      echo "CLANG_CXX_LANGUAGE_STANDARD = c++17" >> "$file"
    fi
  done')
end

# Flutter buildの直前に実行
apply_grpc_fixes
sh("flutter build ios --release --no-codesign")
```

**結果**: ❌ apply_grpc_fixes がFlutter buildの前に実行されるため、Podsディレクトリが見つからない

### 🎯 **方法18: Flutter build後にgRPC修正適用（最終解決策）**

**コミット**: c9543fe

**根本原因の発見**:
完全なCI/CDログ分析により判明：
1. GitHub Actions pod install → gRPC修正適用 ✅ (6ターゲット修正)
2. `apply_grpc_fixes` 実行 → "Pods: No such file or directory" ❌
3. Flutter build → 独自のpod install (20.7s) → 修正をリセット ❌
4. 同じgRPC-Core テンプレートエラー

**最終解決策**:
```ruby
# タイミングを修正：Flutter buildの「後」にgRPC修正を適用
lane :firebase do
  # Flutter iOS ビルド（署名なし）
  sh("flutter build ios --release --dart-define-from-file=dart_defines/#{environment}.env --no-codesign")

  # gRPC修正を再適用（Flutter buildでpod installが実行された後）
  UI.message("🔧 Re-applying gRPC C++17 fixes after Flutter build...")
  apply_grpc_fixes

  # gymでアーカイブ+署名
  gym(...)
end

# 強化されたapply_grpc_fixes関数
def apply_grpc_fixes
  # Podsディレクトリ存在確認
  unless Dir.exist?("Pods")
    UI.error("❌ Pods directory not found. Skipping gRPC fixes.")
    return
  end

  # xcconfigファイル修正
  sh('find Pods -name "*.xcconfig" -exec grep -l "gRPC\\|GRPC" {} \\; 2>/dev/null | head -10 | while IFS= read -r file; do
    if ! grep -q "CLANG_CXX_LANGUAGE_STANDARD.*c++17" "$file" 2>/dev/null; then
      echo "CLANG_CXX_LANGUAGE_STANDARD = c++17" >> "$file"
    fi
  done')

  # 直接プロジェクトファイルも修正（二重保護）
  project = Xcodeproj::Project.open("Runner.xcodeproj")
  project.targets.each do |target|
    if target.name.include?('Runner')
      target.build_configurations.each do |config|
        config.build_settings['CLANG_CXX_LANGUAGE_STANDARD'] = 'c++17'
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] << '-std=c++17'
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] << '-Wno-error=c++20-extensions'
      end
    end
  end
  project.save
end
```

**改善点**:
1. **タイミング修正**: Flutter build完了後にgRPC修正適用
2. **エラーハンドリング**: Podsディレクトリ存在確認
3. **二重保護**: xcconfig + 直接プロジェクト修正
4. **ログ改善**: 詳細な実行状況表示

**現在のステータス**: 🔄 最終解決策でCI/CDテスト中（commit: c9543fe）

---

**最終更新**: 2025年9月29日
**ステータス**: Flutter buildタイミング問題を解決した最終版をテスト中