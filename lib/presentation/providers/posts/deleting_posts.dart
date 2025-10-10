import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deleting_posts.g.dart';

/// 削除中の投稿IDを管理するProvider
@Riverpod(keepAlive: true)
class DeletingPosts extends _$DeletingPosts {
  @override
  Set<String> build() {
    return <String>{};
  }

  /// 投稿の削除開始
  void startDeleting(String postId) {
    state = {...state, postId};
  }

  /// 投稿の削除完了
  void finishDeleting(String postId) {
    state = state.where((id) => id != postId).toSet();
  }

  /// 特定の投稿が削除中かどうか
  bool isDeleting(String postId) {
    return state.contains(postId);
  }

  /// 全ての削除をクリア
  void clearAll() {
    state = <String>{};
  }
}
