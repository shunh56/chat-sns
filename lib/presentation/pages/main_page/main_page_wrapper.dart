import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../components/popup/popup_handler.dart';
import 'main_page.dart';
import 'providers/lifecycle_notifier.dart';
import 'services/voip_service.dart';

/// Scaffold Key Provider
final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

/// メインページラッパー - ライフサイクル管理を担当
class MainPageWrapper extends HookConsumerWidget {
  const MainPageWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ライフサイクル管理
    final lifecycleNotifier = ref.read(lifecycleNotifierProvider.notifier);

    // VoIPサービス初期化
    useEffect(() {
      final voipService = ref.read(voipServiceProvider);
      voipService.initialize();
      return null;
    }, const []);

    // アプリライフサイクル監視
    useEffect(() {
      void handleLifecycleChange() {
        final state = WidgetsBinding.instance.lifecycleState;
        if (state != null) {
          lifecycleNotifier.onLifecycleStateChanged(state);
        }
      }

      WidgetsBinding.instance
          .addObserver(_LifecycleObserver(handleLifecycleChange));

      return () {
        // 実際のオブザーバーの削除は_LifecycleObserverのdisposeで行う
      };
    }, const []);

    // 初期化処理
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // ライフサイクル初期化
        await lifecycleNotifier.initialize();

        // ポップアップ表示
        await Future.delayed(const Duration(milliseconds: 500));
        final popupManager = ref.read(popupManagerProvider);
        popupManager.checkAndShowPopups(context);
      });
      return null;
    }, const []);

    return Scaffold(
      extendBody: true,
      key: ref.watch(scaffoldKeyProvider),
      body: const MainPage(),
    );
  }
}

/// アプリライフサイクル監視用のObserver
class _LifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onLifecycleChanged;

  _LifecycleObserver(this.onLifecycleChanged);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onLifecycleChanged();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
