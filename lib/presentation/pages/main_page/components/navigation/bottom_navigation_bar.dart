import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/utils/text_styles.dart';
import '../../../../../core/utils/theme.dart';
import '../../../../components/core/shader.dart';
import '../../../../providers/shared/app/app_providers.dart' as app_providers;
import '../../../../providers/chats/dm_flag_provider.dart';
import '../../../../v2/tempo_app.dart';
import '../../constants/tab_constants.dart';
import '../../providers/main_page_state_notifier.dart';

/// テンポモードの有効/無効
const _isTempoModeEnabled = false;

/// メインページのボトムナビゲーションバー
class MainBottomNavigationBar extends ConsumerWidget {
  const MainBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(app_providers.themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final mainPageState = ref.watch(mainPageStateProvider);

    return ShaderWidget(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Colors.white,
          unselectedItemColor: ThemeColor.button.withOpacity(0.3),
          selectedLabelStyle: textStyle.w600(fontSize: 11),
          unselectedLabelStyle: textStyle.w600(fontSize: 11),
          currentIndex: mainPageState.currentIndex,
          onTap: (index) => _handleTabTap(ref, context, index),
          items: _buildNavigationItems(ref),
        ),
      ),
    );
  }

  /// タブタップ処理
  void _handleTabTap(WidgetRef ref, BuildContext context, int index) {
    if (index == MainPageTabIndex.tempo && _isTempoModeEnabled) {
      _navigateToTempoApp(context);
      return;
    }

    ref.read(mainPageStateProvider.notifier).changeTab(context, index);
  }

  /// Tempoアプリへの遷移
  void _navigateToTempoApp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TempoApp(),
        fullscreenDialog: true,
      ),
    );
  }

  /// ナビゲーションアイテムのリストを構築
  List<BottomNavigationBarItem> _buildNavigationItems(WidgetRef ref) {
    final items = <BottomNavigationBarItem>[];

    // 定数で定義されたナビゲーションアイテムを構築
    for (final entry in NavigationItems.items.entries) {
      final index = entry.key;
      final config = entry.value;

      items.add(_buildNavigationItem(
        ref: ref,
        label: config.label,
        index: index,
        iconPath: config.iconPath,
        hasNotification: config.hasNotification,
      ));
    }

    // Tempoモードが有効な場合のみTempoタブを追加
    if (_isTempoModeEnabled) {
      items.add(_buildTempoNavigationItem());
    }

    return items;
  }

  /// 通常のナビゲーションアイテムを構築
  BottomNavigationBarItem _buildNavigationItem({
    required WidgetRef ref,
    required String label,
    required int index,
    required String iconPath,
    bool hasNotification = false,
  }) {
    final mainPageState = ref.watch(mainPageStateProvider);
    final isSelected = index == mainPageState.currentIndex;

    return BottomNavigationBarItem(
      label: label,
      icon: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: SizedBox(
              height: 24,
              width: 24,
              child: SvgPicture.asset(
                iconPath,
                // ignore: deprecated_member_use
                color: isSelected
                    ? Colors.white
                    : ThemeColor.button.withOpacity(0.3),
              ),
            ),
          ),
          if (hasNotification) _buildNotificationIndicator(ref),
        ],
      ),
    );
  }

  /// Tempoナビゲーションアイテムを構築
  BottomNavigationBarItem _buildTempoNavigationItem() {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 18,
        ),
      ),
      label: "Tempo",
    );
  }

  /// 通知インジケーターを構築
  Widget _buildNotificationIndicator(WidgetRef ref) {
    final hasDmNotification = ref.watch(dmFlagProvider);

    return Visibility(
      visible: hasDmNotification,
      child: const Positioned(
        top: 0,
        right: 0,
        child: CircleAvatar(
          radius: 4,
          backgroundColor: Colors.red,
        ),
      ),
    );
  }
}