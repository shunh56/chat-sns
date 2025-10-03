import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'application/bootstrap/app_bootstrap.dart';

/// アプリケーションのエントリーポイント
///
/// 初期化とエラーハンドリングを簡潔に管理
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      // アプリケーションブートストラップの実行
      final bootstrap = AppBootstrap();
      final app = await bootstrap.initialize();

      // アプリケーションの起動
      runApp(app);
    },
    (error, stack) {
      // 予期しないエラーをCrashlyticsに報告
      FirebaseCrashlytics.instance.recordError(error, stack);
    },
  );
}