import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// リプライ一覧コンポーネント
///
/// 投稿に対するリプライを一覧表示する再利用可能コンポーネント
class ReplyList extends ConsumerWidget {
  const ReplyList({
    super.key,
    this.postId,
  });

  final String? postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: 10, // TODO: 実際のリプライ数に置き換え
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('ユーザー名 $index'),
            subtitle: Text('リプライ内容 $index'),
            trailing: Text('${index + 1}分前'),
          ),
        );
      },
    );
  }
}
