// Flutter imports:
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:flutter/material.dart';

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
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Container(
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
        .read(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[message.postId]!;
    return Container(
      margin: const EdgeInsets.only(
        top: 24,
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
          CurrentStatusDmWidget(
            post: post,
            user: user,
          ),
          const Gap(8),
          Row(
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

/*    final postAsyncValue = ref.watch(currentStatusPostProvider(message.postId));
    return postAsyncValue.maybeWhen(
      data: (post) {
        return Container(
          margin: const EdgeInsets.only(
            top: 24,
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
              CurrentStatusDmWidget(
                post: post,
                user: user,
              ),
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(navigationRouterProvider(context))
                          .goToProfile(user);
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
      },
      orElse: () => const SizedBox(),
    ); */
  }
}
