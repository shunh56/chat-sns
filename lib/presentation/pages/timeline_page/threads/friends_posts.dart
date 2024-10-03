import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_section.dart';
import 'package:app/presentation/pages/timeline_page/widget/current_status_post.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/chats/voice_chats_list.dart';
import 'package:app/presentation/providers/provider/posts/friends_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

//keepAlive => stateful widget
class FriendsPostsThread extends ConsumerStatefulWidget {
  const FriendsPostsThread({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FriendsPostsThreadState();
}

class _FriendsPostsThreadState extends ConsumerState<FriendsPostsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final postList = ref.watch(friendsPostsNotiferProvider);
    final asyncValue = ref.watch(myAccountNotifierProvider);
    final card = asyncValue.when(
      data: (me) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildCurrentStatus(context, ref, me),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return postList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            List<Future> futures = [];
            futures
                .add(ref.read(friendsPostsNotiferProvider.notifier).refresh());
            futures.add(
                ref.read(voiceChatListNotifierProvider.notifier).refresh());
            await Future.wait(futures);
            return;
          },
          child: ListView(
            children: [
              const VoiceChatSection(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: card,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final post = list[index];
                  final user = ref
                      .read(allUsersNotifierProvider)
                      .asData!
                      .value[post.userId]!;
                  if (post is Post) {
                    Post item = post;
                    return GestureDetector(
                      onTap: () {
                        item = item.copyWith(likeCount: post.likeCount + 1);
                      },
                      child: PostWidget(postRef: item, user: user),
                    );
                  }
                  if (post is CurrentStatusPost) {
                    return CurrentStatusPostWidgets(context, ref, post, user)
                        .timelinePost();
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditCurrentStatusScreen(),
      ),
    );
  }

  Widget _buildCurrentStatus(
      BuildContext context, WidgetRef ref, UserAccount me) {
    final canvasTheme = me.canvasTheme;
    return box(
      canvasTheme,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "「いま」ボード",
            style: TextStyle(
              fontSize: 16,
              color: canvasTheme.boxTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          if (me.currentStatus.doing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "なにしてる？",
                      style: TextStyle(
                        fontSize: 14,
                        color: canvasTheme.boxSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Text(
                        me.currentStatus.doing,
                        style: TextStyle(
                          fontSize: 16,
                          color: canvasTheme.boxSecondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (me.currentStatus.eating.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "なに食べてる？",
                      style: TextStyle(
                        fontSize: 14,
                        color: canvasTheme.boxSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Text(
                        me.currentStatus.eating,
                        style: TextStyle(
                          fontSize: 16,
                          color: canvasTheme.boxSecondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (me.currentStatus.mood.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "今の気分は？",
                      style: TextStyle(
                        fontSize: 14,
                        color: canvasTheme.boxSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Text(
                        me.currentStatus.mood,
                        style: TextStyle(
                          fontSize: 16,
                          color: canvasTheme.boxSecondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (me.currentStatus.nextAt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "どこにいる？",
                      style: TextStyle(
                        fontSize: 14,
                        color: canvasTheme.boxSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            me.currentStatus.nowAt,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (me.currentStatus.nextAt.isNotEmpty)
                            Text(
                              "next: ${me.currentStatus.nextAt}",
                              style: TextStyle(
                                fontSize: 16,
                                color: canvasTheme.boxSecondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (me.currentStatus.nowWith.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "一緒にいる人",
                      style: TextStyle(
                        fontSize: 14,
                        color: canvasTheme.boxSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FutureBuilder(
                      future: ref
                          .read(allUsersNotifierProvider.notifier)
                          .getUserAccounts(me.currentStatus.nowWith),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final users = snapshot.data!;
                        return SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: users
                                .map(
                                  (user) => Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        color: ThemeColor.accent,
                                        height: 48,
                                        width: 48,
                                        child: user.imageUrl != null
                                            ? CachedNetworkImage(
                                                imageUrl: user.imageUrl!,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 120),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: 48,
                                                  width: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    const SizedBox(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const SizedBox(),
                                              )
                                            : const Icon(
                                                Icons.person_outline,
                                                size: 48 * 0.8,
                                                color: ThemeColor.stroke,
                                              ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
      () {
        navToEditCurrentStatus(context, ref, me);
      },
    );
  }

  Widget box(CanvasTheme canvasTheme, Widget child, Function onPressed) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: canvasTheme.boxBgColor,
                  borderRadius: BorderRadius.circular(canvasTheme.boxRadius),
                  border: Border.all(
                    width: canvasTheme.boxWidth,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.1),
              ),
              child: SizedBox(
                height: 18,
                width: 18,
                child: SvgPicture.asset(
                  "assets/images/icons/edit.svg",
                  color: canvasTheme.boxTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
