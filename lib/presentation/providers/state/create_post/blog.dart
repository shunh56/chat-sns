//UIからstateを構築し、そのデータをnotifierもしくはusecaseに渡す(一つの引数として)

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogState {
  final String title;
  final List<dynamic> contents;

  BlogState({
    required this.title,
    required this.contents,
  });

  get isReadyToUpload => (title.isNotEmpty && contents.isNotEmpty);
}

final blogStateProvider = Provider.autoDispose(
  (ref) {
    final title = ref.watch(titleTextProvider);
    final contents = ref.watch(contentListNotifierProvider);
    return BlogState(
      title: title,
      contents: contents,
    );
  },
);

final titleTextProvider = StateProvider.autoDispose((ref) => "");

final contentListNotifierProvider =
    StateNotifierProvider.autoDispose<ListStateNotifier, List<dynamic>>((ref) {
  return ListStateNotifier();
});

class ListStateNotifier extends StateNotifier<List<dynamic>> {
  ListStateNotifier() : super([]);

  // 要素を追加するメソッド
  void addContent(dynamic item) {
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
