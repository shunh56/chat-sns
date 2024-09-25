// Flutter imports:
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/widgets/right_message.dart';
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// Project imports:

class LeftMessage extends ConsumerWidget {
  const LeftMessage({
    super.key,
    required this.message,
    required this.user,
  });
  final CoreMessage message;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(
        top: 4,
        left: 12,
        right: 72,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
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
                      style: const TextStyle(
                        fontSize: 15,
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: ThemeColor.text,
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
  }
}

class LeftCurrentStatusMessage extends ConsumerWidget {
  const LeftCurrentStatusMessage({
    super.key,
    required this.message,
    required this.user,
  });
  final CurrentStatusMessage message;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildCurrentStatusReply(context, ref);
  }

  Widget _buildCurrentStatusReply(BuildContext context, WidgetRef ref) {
    final post = ref
        .watch(allCurrentStatusPostsNotifierProvider)
        .asData
        ?.value[message.postId];
    late Widget content;
    if (post != null) {
      content = CurrentStatusPostWidgets(context, ref, post, user).dmWidget();
    } else {
      final postAsyncValue =
          ref.watch(currentStatusPostProvider(message.postId));
      content = postAsyncValue.maybeWhen(
        data: (post) {
          return CurrentStatusPostWidgets(context, ref, post, user).dmWidget();
        },
        orElse: () => const SizedBox(),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 72,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ステータスに返信しました。",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          const Gap(4),
          content,
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
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
                        decoration: const BoxDecoration(
                          color: ThemeColor.stroke,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 15,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: ThemeColor.text,
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
