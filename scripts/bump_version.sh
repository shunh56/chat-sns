#!/bin/bash

# バージョン管理スクリプト
# 使用方法: ./scripts/bump_version.sh [patch|minor|major]

set -e

VERSION_TYPE=${1:-patch}

echo "🔢 Current version:"
flutter pub deps | grep -E '^app '

echo "📦 Installing cider..."
flutter pub get

echo "🚀 Bumping $VERSION_TYPE version..."
flutter pub run cider bump $VERSION_TYPE

echo "📝 Getting new version..."
NEW_VERSION=$(flutter pub run cider version)

echo "✅ New version: $NEW_VERSION"

echo "📝 Updating CHANGELOG.md..."
flutter pub run cider release

echo "✨ Version bump completed!"
echo "New version: $NEW_VERSION"