import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final imageListNotifierProvider =
    StateNotifierProvider.autoDispose<ListStateNotifier, List<File>>((ref) {
  return ListStateNotifier();
});

class ListStateNotifier extends StateNotifier<List<File>> {
  ListStateNotifier() : super([]);

  // 要素を追加するメソッド
  void addItem(File item) {
    state = [...state, item];
  }

  // 指定したインデックスの要素を削除するメソッド
  void removeItem(int index) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }
}
