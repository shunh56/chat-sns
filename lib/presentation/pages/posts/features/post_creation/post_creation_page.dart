import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'create_post_screen/create_post_screen_refactored.dart';

/// 投稿作成ページ（エントリーポイント）
///
/// 機能:
/// - 投稿作成画面への導線
/// - 統一されたインターフェース
class PostCreationPage extends ConsumerWidget {
  const PostCreationPage({
    super.key,
    this.community,
  });

  final dynamic community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreatePostScreenRefactored(community: community);
  }
}
