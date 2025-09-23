// lib/presentation/pages/posts/post/widgets/post_card/post_content.dart
import 'package:app/presentation/pages/posts/post/components/style/post_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/pages/posts/post/components/text/linkified_text.dart';
import 'package:gap/gap.dart';

/// 投稿のコンテンツ部分を表示するウィジェット
class PostContent extends ConsumerWidget {
  const PostContent({
    super.key,
    required this.post,
    this.maxLines,
    this.onExpand,
  });

  final Post post;

  final int? maxLines;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.text.isNotEmpty) ...[
          const Gap(4),
          _buildTextContent(),
        ],
      ],
    );
  }

  /// テキストコンテンツを構築
  Widget _buildTextContent() {
    return LinkifiedText(
      text: post.text,
      style: _getTextStyle(),
      maxLines: maxLines ?? _getDefaultMaxLines(),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 詳細画面用のテキストコンテンツを構築

  TextStyle _getTextStyle() {
    return PostTextStyles.getContentText(
      fontSize: 14,
      height: 1.4,
    );
  }

  /// デフォルトの最大行数を取得
  int _getDefaultMaxLines() {
    return 4;
  }
}

/// コンテンツのスケルトンローディング
class PostContentSkeleton extends StatelessWidget {
  const PostContentSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _getPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトルのスケルトン
          Container(
            width: double.infinity,
            height: _getTitleHeight(),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(8),

          // テキストのスケルトン
          ...List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      width: index == 2 ? 150 : double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    return const EdgeInsets.fromLTRB(16, 8, 16, 0);
  }

  double _getTitleHeight() {
    return 20;
  }
}
