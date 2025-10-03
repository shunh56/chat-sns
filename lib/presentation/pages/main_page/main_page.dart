import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/follow/follow_list_notifier.dart';
import '../../providers/follow/followers_list_notifier.dart';
import '../../providers/shared/app/session_provider.dart';
import '../../services/dm_banner.dart';
import 'components/main_content.dart';
import 'components/navigation/bottom_navigation_bar.dart';
import 'components/navigation/floating_action_buttons.dart';
import 'components/drawer.dart';
import 'components/overlays/heart_animation_overlay.dart';

/// 重要なプロバイダーをキープするProvider
final mainPageProvidersKeeper = Provider<void>((ref) {
  // 重要なプロバイダーをキープ
  ref.watch(followingListNotifierProvider);
  ref.watch(followersListNotifierProvider);
  return;
});

/// メインページ - UI構成を担当
class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // セッション管理とプロバイダーキープ
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sessionStateProvider.notifier).startSession();
        ref.read(mainPageProvidersKeeper);
      });
      return null;
    }, const []);

    return const Scaffold(
      drawer: MainPageDrawer(),
      body: Stack(
        children: [
          MainContent(),
          HeartAnimationArea(),
          DMNotificationBanner(),
        ],
      ),
      bottomNavigationBar: MainBottomNavigationBar(),
      floatingActionButton: MainFloatingActionButtons(),
    );
  }
}