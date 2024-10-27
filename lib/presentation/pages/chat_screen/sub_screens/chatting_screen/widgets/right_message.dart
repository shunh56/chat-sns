// Flutter imports:

// Package imports:
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

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

class RightMessage extends ConsumerWidget {
  const RightMessage({super.key, required this.message, required this.user});
  final CoreMessage message;
  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final dmOverviewList = ref.watch(dmOverviewListProvider);

    return _buildDefaultMessage(ref);
  }

  Widget _buildDefaultMessage(WidgetRef ref) {
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

    return Container(
      margin: const EdgeInsets.only(
        top: 4,
        left: 72,
        right: 12,
        bottom: 4,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: ThemeColor.text,
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
                      style: const TextStyle(
                        fontSize: 15,
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
  }
}

class RightCurrentStatusMessage extends ConsumerWidget {
  const RightCurrentStatusMessage(
      {super.key, required this.message, required this.user});
  final CurrentStatusMessage message;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildCurrentStatusReply(context, ref);
  }

  Widget _buildCurrentStatusReply(BuildContext context, WidgetRef ref) {
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

    final post = ref
        .read(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[message.postId]!;
    return Container(
      margin: const EdgeInsets.only(
        top: 24,
        left: 72,
        right: 12,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "ステータスに返信しました。",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          const Gap(4),
          CurrentStatusDmWidget(post: post, user: user),
          const Gap(4),
          Row(
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
                          style: const TextStyle(
                            fontSize: 10,
                            color: ThemeColor.text,
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
                        decoration: const BoxDecoration(
                          color: ThemeColor.highlight,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(4),
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final postAsyncValue = ref.watch(currentStatusPostProvider(message.postId));

    return postAsyncValue.maybeWhen(
      data: (post) {
        return Container(
          margin: const EdgeInsets.only(
            top: 24,
            left: 72,
            right: 12,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "ステータスに返信しました。",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              const Gap(4),
              CurrentStatusDmWidget(post: post, user: user),
              const Gap(4),
              Row(
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
                              style: const TextStyle(
                                fontSize: 10,
                                color: ThemeColor.text,
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
                            decoration: const BoxDecoration(
                              color: ThemeColor.highlight,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(4),
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
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}
