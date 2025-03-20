// Flutter imports:
import 'package:app/core/utils/debug_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';

import '../utils/animated_message.dart';

class LeftMessage extends HookConsumerWidget {
  const LeftMessage({
    super.key,
    required this.message,
    required this.user,
    this.isLatest = false,
  });
  final CoreMessage message;
  final UserAccount user;
  final bool isLatest;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    
    // 通常のメッセージウィジェット
    final messageWidget = Container(
      margin: const EdgeInsets.only(
        top: 6,
        left: 12,
        right: 72,
        bottom: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(navigationRouterProvider(context)).goToProfile(user);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: CachedImage.userIcon(
                user.imageUrl,
                user.name,
                14,
              ),
            ),
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.text,
                      style: textStyle.w500(
                        fontSize: 14,
                        color: ThemeColor.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  message.createdAt.xxAgo,
                  style: textStyle.w400(
                    fontSize: 10,
                    color: ThemeColor.subText,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    // 最新のメッセージの場合のみアニメーション適用
    if (isLatest) {
      return AnimatedMessageWidget(
        animationType: AnimationType.slide,
        slideFromBottom: false,
        duration: const Duration(milliseconds: 250),
        child: messageWidget,
      );
    } else {
      return messageWidget;
    }
  }
}