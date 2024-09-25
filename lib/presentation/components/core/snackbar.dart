// Flutter imports:
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:

showMessage(
  String message, [
  int ms = kDebugMode ? 2000 : 1200,
]) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      backgroundColor: ThemeColor.accent,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      duration: Duration(milliseconds: ms),
    ),
  );
}

showPermissionMessage(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2400),
      content: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          GestureDetector(
            onTap: () {
              openAppSettings();
            },
            child: const Text(
              "設定を開く",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

showUpcomingSnackbar() {
  showMessage("Comming Up Soon...");
}

showErrorSnackbar({Object? error}) {
  showMessage("予期せぬエラーが発生しました。 : $error");
}
