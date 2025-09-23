import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ReplyItem extends ConsumerWidget {
  const ReplyItem({super.key, required this.reply});
  final Reply reply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final user =
        ref.read(allUsersNotifierProvider).asData!.value[reply.userId]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザーアバター（コンパクト）

            UserIcon(
              user: user,
            ),

            const Gap(12),

            // メインコンテンツエリア
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ヘッダー（名前とタイムスタンプ）
                  _buildHeader(user, textStyle),

                  const Gap(10),

                  // リプライ内容
                  _buildContent(textStyle),

                  //const Gap(8),

                  // アクションバー（コンパクト）
                  // _buildCompactActionBar(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user, ThemeTextStyle textStyle) {
    return Row(
      children: [
        // ユーザー名（シンプル）
        Flexible(
          child: Text(
            user.name,
            style: textStyle
                .w600(
                  fontSize: 14,
                  height: 1.2,
                )
                .copyWith(
                  //color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const Gap(8),

        // タイムスタンプ（軽量）
        Text(
          "• ${reply.createdAt.xxAgo}",
          style: const TextStyle(
            fontSize: 12,
            color: ThemeColor.subText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeTextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        reply.text,
        style: const TextStyle(
          fontSize: 14,
          color: ThemeColor.text,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        maxLines: null, // ListView内でのテキスト表示を最適化
      ),
    );
  }

  Widget _buildCompactActionBar(ThemeData theme) {
    return Row(
      children: [
        _buildCompactActionButton(
          icon: Icons.favorite_border,
          label: "いいね",
          onTap: () {
            // いいねアクション
          },
          theme: theme,
        ),
        const Gap(16),
        _buildCompactActionButton(
          icon: Icons.chat_bubble_outline,
          label: "返信",
          onTap: () {
            // 返信アクション
          },
          theme: theme,
        ),
        const Spacer(),
        _buildCompactActionButton(
          icon: Icons.more_horiz,
          label: "", //"その他",
          onTap: () {
            // その他のオプション
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const Gap(4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
