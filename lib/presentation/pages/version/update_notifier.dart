import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/presentation/pages/version/version_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateNotifier extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateNotifier({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UpdateNotifier> createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends ConsumerState<UpdateNotifier> {
  static const String _lastCheckKey = 'last_version_check';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _checkVersion() async {
    try {
      final status = await ref.read(versionStatusProvider.future);

      if (!mounted) return;

      switch (status) {
        case VersionStatus.requiresUpdate:
          _showForceUpdateDialog();
          break;

        case VersionStatus.updateAvailable:
          // updateAvailableの場合のみ、1日1回チェックを適用
          final prefs = await SharedPreferences.getInstance();
          final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;

          if (now - lastCheck >= const Duration(days: 1).inMilliseconds) {
            await prefs.setInt(_lastCheckKey, now);
            _showUpdateAvailableDialog();
          }
          break;

        case VersionStatus.upToDate:
          break;
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ThemeColor.background.withOpacity(0.8),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: _UpdateDialog(
          title: 'アップデートが必要です',
          message: 'このバージョンはサポートが終了しました。\n'
              '引き続きアプリをご利用いただくには、'
              '最新バージョンへのアップデートが必要です。',
          isRequired: true,
          onUpdate: _openStore,
        ),
      ),
    );
  }

  void _showUpdateAvailableDialog() {
    showDialog(
      context: context,
      barrierColor: ThemeColor.background.withOpacity(0.8),
      builder: (context) => _UpdateDialog(
        title: '新しいバージョンが利用可能です',
        message: '新しいバージョンがリリースされています。\n'
            'アップデートして最新機能をお楽しみください。',
        isRequired: false,
        onUpdate: _openStore,
      ),
    );
  }

  Future<void> _openStore() async {
    final url = Theme.of(context).platform == TargetPlatform.iOS
        ? APP_STORE_URL
        : PLAY_STORE_URL;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _UpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isRequired;
  final VoidCallback onUpdate;

  const _UpdateDialog({
    required this.title,
    required this.message,
    required this.isRequired,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeColor.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: ThemeColor.stroke,
          width: 1,
        ),
      ),
      title: Column(
        children: [
          Icon(
            isRequired ? Icons.warning_rounded : Icons.system_update_rounded,
            color: isRequired ? ThemeColor.error : ThemeColor.primary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: ThemeColor.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: ThemeColor.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        if (!isRequired)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: ThemeColor.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              '後で',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            if (!isRequired) Navigator.of(context).pop();
            onUpdate();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isRequired ? ThemeColor.error : ThemeColor.primary,
            foregroundColor: ThemeColor.text,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'アップデート',
            style: TextStyle(
              color: ThemeColor.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
