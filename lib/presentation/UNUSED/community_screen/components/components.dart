import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showJoinDialog(
    BuildContext context, WidgetRef ref, Community community) async {
  final themeSize = ref.watch(themeSizeProvider(context));
  final textStyle = ThemeTextStyle(themeSize: themeSize);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        'コミュニティに参加',
        style: textStyle.w600(
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'コミュニティルールに同意して参加しますか？',
            style: textStyle.w600(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• 個人情報の共有は禁止です\n'
            '• 誹謗中傷は禁止です\n'
            '• 著作権を侵害する投稿は禁止です',
            style: textStyle.w400(fontSize: 14, color: ThemeColor.subText),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'キャンセル',
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: Text(
            '同意して参加',
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    ref.read(communityUsecaseProvider).joinCommunity(community);
  }
}

class UserStackIcons extends ConsumerWidget {
  const UserStackIcons({
    super.key,
    required this.users,
    this.displayCount = 5,
    this.imageRadius = 24.0,
    this.strokeColor,
  });
  final List<UserAccount> users;

  final int displayCount;
  final double imageRadius;
  final Color? strokeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const stroke = 4.0;
    List<Widget> stack = [];
    for (int i = min(displayCount, users.length) - 1; i >= 0; i--) {
      stack.add(
        Positioned(
          left: i * (imageRadius * 3 / 2) - stroke,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: stroke,
                color: strokeColor ?? ThemeColor.background,
              ),
            ),
            child: UserIcon(
              user: users[i],
              width: imageRadius * 2,
              isCircle: true,
              navDisabled: true,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: (imageRadius * 2 + stroke) +
          (min(displayCount, users.length) - 1) * (imageRadius * 3 / 2),
      height: imageRadius * 2,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: stack,
      ),
    );
  }
}

class EmptyUserStackIcons extends ConsumerWidget {
  const EmptyUserStackIcons({
    super.key,
    this.displayCount = 5,
    this.imageRadius = 24.0,
    this.bgColor,
    this.strokeColor,
  });

  final int displayCount;
  final double imageRadius;
  final Color? bgColor;
  final Color? strokeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const stroke = 4.0;
    List<Widget> stack = [];
    for (int i = displayCount - 1; i >= 0; i--) {
      stack.add(
        Positioned(
          left: i * (imageRadius * 3 / 2) - stroke,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: stroke,
                color: strokeColor ?? ThemeColor.background,
              ),
            ),
            child: CircleAvatar(
              radius: imageRadius,
              backgroundColor: bgColor ?? ThemeColor.accent,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: (imageRadius * 2 + stroke) +
          (displayCount - 1) * (imageRadius * 3 / 2),
      height: imageRadius * 2,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: stack,
      ),
    );
  }
}
