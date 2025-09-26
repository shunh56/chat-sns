#!/bin/bash

echo "🔥 Firebase App Distribution セットアップ"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Firebase CLIインストール確認
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}Firebase CLIをインストールします...${NC}"
    curl -sL https://firebase.tools | bash
fi

# Firebase ログイン
echo -e "${GREEN}Firebaseにログインしてください${NC}"
firebase login

# Firebase トークン生成
echo -e "${GREEN}CI/CD用のFirebaseトークンを生成します${NC}"
firebase login:ci

echo -e "${YELLOW}生成されたトークンをGitHub Secretsに追加してください:${NC}"
echo "FIREBASE_TOKEN=<generated-token>"

# Firebase App ID取得
echo -e "${GREEN}Firebase App IDを取得します${NC}"

# iOS App ID
echo -e "${YELLOW}iOS App IDs:${NC}"
firebase apps:list ios

# Android App ID
echo -e "${YELLOW}Android App IDs:${NC}"
firebase apps:list android

echo -e "${GREEN}完了！以下の情報をGitHub Secretsに追加してください:${NC}"
echo "- FIREBASE_TOKEN"
echo "- FIREBASE_APP_ID_IOS_DEV"
echo "- FIREBASE_APP_ID_IOS_PROD"
echo "- FIREBASE_APP_ID_ANDROID_DEV"
echo "- FIREBASE_APP_ID_ANDROID_PROD"