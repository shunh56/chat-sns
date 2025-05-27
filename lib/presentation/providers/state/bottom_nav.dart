// Flutter imports:

// Package imports:
import 'package:app/presentation/providers/state/scroll_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider =
    StateNotifierProvider<BottomNavIndex, int>((ref) {
  return BottomNavIndex(ref);
});

class BottomNavIndex extends StateNotifier<int> {
  BottomNavIndex(this.ref) : super(0);
  final Ref ref;
  void changeIndex(
    BuildContext context,
    int index,
  ) {
    if (state == 1 && index == 1) {
      if (ref.read(timelineScrollController).hasClients) {
        ref.read(timelineScrollController).animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
      }
    }
    state = index;
  }
}
