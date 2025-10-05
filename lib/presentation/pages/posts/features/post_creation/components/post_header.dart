import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/domain/entity/user.dart';

/// 投稿作成画面のヘッダー部分
///
/// 機能:
/// - ユーザーアバターとユーザー名の表示
/// - シンプルで一貫性のあるデザイン
class PostHeader extends ConsumerWidget {
  const PostHeader({
    super.key,
    required this.user,
  });

  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          UserIcon(
            user: user,
            enableDecoration: false,
            r: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              user.name,
              style: textStyle.w600(
                fontSize: 14,
                color: ThemeColor.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
