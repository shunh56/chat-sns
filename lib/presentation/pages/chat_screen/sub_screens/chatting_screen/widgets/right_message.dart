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
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';

import '../utils/animated_message.dart';

final currentStatusPostProvider = FutureProvider.family(
  (Ref ref, String postId) async {
    final cache =
        ref.watch(allCurrentStatusPostsNotifierProvider).asData?.value[postId];
    if (cache != null) return cache;
    final post =
        await ref.read(currentStatusPostUsecaseProvider).getPost(postId);
    ref.read(allCurrentStatusPostsNotifierProvider.notifier).addPosts([post]);
    return post;
  },
);

class RightMessage extends HookConsumerWidget {
  const RightMessage({
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
    return _buildDefaultMessage(context, ref);
  }

  Widget _buildDefaultMessage(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(dmOverviewListNotifierProvider);

    final checkIcon = asyncValue.when(
      data: (dmList) {
        final q = dmList.where((overview) => overview.userId == user.userId);
        if (q.isEmpty) return const SizedBox();
        final dmOverview = q.first;

        final list =
            dmOverview.userInfoList.where((item) => item.userId == user.userId);
        if (list.isEmpty) return const SizedBox();
        final info = list.first;
        if (message.createdAt.toDate().isBefore(info.lastOpenedAt.toDate())) {
          return const Icon(
            Icons.done,
            size: 12,
            color: ThemeColor.highlight,
          );
        } else {
          return const SizedBox();
        }
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    // 通常のメッセージウィジェット
    final messageWidget = Container(
      margin: const EdgeInsets.only(
        top: 6,
        left: 72,
        right: 12,
        bottom: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    //seen sign
                    checkIcon,
                    //time
                    Text(
                      message.createdAt.xxAgo,
                      style: textStyle.w400(
                        fontSize: 10,
                        color: ThemeColor.subText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 4,
                ),
                //message
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.highlight,
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
              ],
            ),
          ),
        ],
      ),
    );

    // デバッグ情報
    if (isLatest) {
      DebugPrint("アニメーション付きで表示するメッセージ: ${message.id}");
    }

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