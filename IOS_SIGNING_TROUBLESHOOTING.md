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

### 🔄 方法11: 環境変数でAPI Key認証（現在テスト中）

**コミット**: (次のコミット)

**実装内容**:
```ruby
# 環境変数でAPI Key認証情報を設定
ENV["APP_STORE_CONNECT_API_KEY_ID"] = ENV["APP_STORE_CONNECT_API_KEY_ID"]
ENV["APP_STORE_CONNECT_API_KEY_PATH"] = api_key_path

# Flutter IPAビルドを直接実行
sh("flutter build ipa --release ...")
```

**期待される動作**:
- Fastlaneのapp_store_connect_api_keyアクションをスキップ
- 環境変数経由でxcodebuildにAPI Key情報を渡す
- OpenSSLエラーを回避

**結果**: 🔄 テスト中

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

**最終更新**: 2025年9月26日
**ステータス**: 方法4をテスト中