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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.title.isNotEmpty) ...[
            const Gap(8),
            _buildTitle(),
          ],
          if (post.text.isNotEmpty) ...[
            const Gap(6),
            _buildTextContent(),
          ],
          if (post.hashtags.isNotEmpty) ...[
            const Gap(8),
            _buildHashtags(),
          ],
        ],
      ),
    );
  }

  /// タイトルを構築
  Widget _buildTitle() {
    return Text(
      post.title,
      style: PostTextStyles.getHeaderText(
          fontSize: 16, fontWeight: FontWeight.w700),
      maxLines: null,
      overflow: null,
    );
  }

  /// テキストコンテンツを構築
  Widget _buildTextContent() {
    return LinkifiedText(
      text: post.text,
      style: _getTextStyle(),
      maxLines: maxLines ?? _getDefaultMaxLines(),
      overflow: TextOverflow.ellipsis,
      /* onLinkTap: (url) {
        // URLタップの処理
      },
      onHashtagTap: (hashtag) {
        // ハッシュタグタップの処理
      },
      onMentionTap: (mention) {
        // メンションタップの処理
      }, */
    );
  }

  /// 詳細画面用のテキストコンテンツを構築

  /// ハッシュタグを構築
  Widget _buildHashtags() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children:
          post.hashtags.map((hashtag) => _buildHashtagChip(hashtag)).toList(),
    );
  }

  /// コンパクトなハッシュタグ表示
  Widget _buildCompactHashtags() {
    final displayHashtags = post.hashtags.take(3).toList();
    final hasMore = post.hashtags.length > 3;

    return Row(
      children: [
        ...displayHashtags.map(
          (hashtag) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _buildHashtagChip(hashtag, isCompact: true),
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+${post.hashtags.length - 3}',
              style: PostTextStyles.getContentText(
                fontSize: 10,
                color: Colors.blue.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }

  /// ハッシュタグチップを構築
  Widget _buildHashtagChip(String hashtag, {bool isCompact = false}) {
    return GestureDetector(
      onTap: () {
        // ハッシュタグタップの処理
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 8,
          vertical: isCompact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          '#$hashtag',
          style: PostTextStyles.getContentText(
            fontSize: isCompact ? 10 : 12,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// タイトルのフォントサイズを取得

  /// タイトルのフォントウェイトを取得

  /// テキストスタイルを取得
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
