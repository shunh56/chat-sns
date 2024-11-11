package com.blank.sns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setDevMode") {
                val devMode = call.argument<Boolean>("devMode") ?: false
                // 環境変数を設定
                System.setProperty("DEV_MODE", devMode.toString())
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}