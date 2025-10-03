import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/analytics/screen_name.dart';
import '../../../providers/shared/app/session_provider.dart';
import '../../../providers/state/scroll_controller.dart';
import '../constants/tab_constants.dart';

/// メインページの統合状態管理
final mainPageStateProvider =
    StateNotifierProvider<MainPageStateNotifier, MainPageState>((ref) {
  return MainPageStateNotifier(ref);
});

/// メインページの状態
class MainPageState {
  final int currentIndex;
  final bool isLoading;
  final String? error;

  const MainPageState({
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
  });

  MainPageState copyWith({
    int? currentIndex,
    bool? isLoading,
    String? error,
  }) {
    return MainPageState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// メインページの状態管理クラス
class MainPageStateNotifier extends StateNotifier<MainPageState> {
  final Ref _ref;

  MainPageStateNotifier(this._ref) : super(const MainPageState());

  /// タブを変更する
  void changeTab(BuildContext context, int index) {
    // 無効なインデックスの場合は何もしない
    if (!MainPageTabIndex.isValidIndex(index)) {
      state = state.copyWith(error: '無効なタブインデックス: $index');
      return;
    }

    if (state.currentIndex == index) {
      _handleSameTabTap(index);
      return;
    }

    state = state.copyWith(currentIndex: index, error: null);
    _trackScreenView(index);
  }

  /// 同じタブがタップされた時の処理
  void _handleSameTabTap(int index) {
    switch (index) {
      case MainPageTabIndex.home:
        _ref.read(scrollToTopProvider.notifier).scrollToTop();
        break;
      case MainPageTabIndex.timeline:
        if (_ref.read(timelineScrollController).hasClients) {
          _ref.read(timelineScrollController).animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
        }
        break;
    }
  }

  /// 画面表示の追跡
  void _trackScreenView(int index) {
    try {
      final sessionNotifier = _ref.read(sessionStateProvider.notifier);

      switch (index) {
        case MainPageTabIndex.home:
          sessionNotifier.trackScreenView(ScreenName.homePage.value);
          break;
        case MainPageTabIndex.timeline:
          sessionNotifier.trackScreenView(ScreenName.timelinePage.value);
          break;
        case MainPageTabIndex.chat:
          sessionNotifier.trackScreenView(ScreenName.chatPage.value);
          break;
        case MainPageTabIndex.profile:
          sessionNotifier.trackScreenView(ScreenName.profilePage.value);
          break;
      }
    } catch (e) {
      state = state.copyWith(error: '画面追跡でエラーが発生しました: $e');
    }
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }
}
