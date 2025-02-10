// toast_utils.dart
import 'package:app/core/utils/variables.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static void showSuccessToast(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.green.shade800,
      icon: Icons.check_circle_outline,
    );
  }

  static void showErrorToast(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.red.shade800,
      icon: Icons.error_outline,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// error_handler.dart
Future handleError<T>({
  required Future<T> Function() process,
  String? successMessage,
  String? errorMessage,
  String? Function(dynamic error)? errorHandler,
  bool showSuccessToast = true,
}) async {
  try {
    final result = await process();

    if (showSuccessToast && successMessage != null) {
      ToastUtils.showSuccessToast(successMessage);
    }

    return result;
  } catch (e) {
    final message =
        errorHandler?.call(e) ?? errorMessage ?? 'エラーが発生しました。もう一度お試しください。';

    ToastUtils.showErrorToast(message);
  }
}
