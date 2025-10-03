import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pages/main_page/providers/main_page_state_notifier.dart';

/// 下位互換性のためのプロバイダー（新しいMainPageStateProviderへのプロキシ）
final bottomNavIndexProvider = Provider<int>((ref) {
  return ref.watch(mainPageStateProvider.select((state) => state.currentIndex));
});

/// 下位互換性のためのNotifier（新しいMainPageStateNotifierへのプロキシ）
class BottomNavIndex extends StateNotifier<int> {
  BottomNavIndex(this.ref) : super(0);
  final Ref ref;

  void changeIndex(BuildContext context, int index) {
    ref.read(mainPageStateProvider.notifier).changeTab(context, index);
  }
}
