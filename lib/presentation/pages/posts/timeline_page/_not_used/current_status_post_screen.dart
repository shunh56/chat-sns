/*import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/UNUSED/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/main_page/heart_animation_overlay.dart';
import 'package:app/presentation/pages/posts/timeline_page/timeline_page.dart';
import 'package:app/presentation/pages/posts/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/heart_animation_notifier.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/direct_message_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class CurrentStatusPostScreen extends ConsumerWidget {
  const CurrentStatusPostScreen(
      {super.key, required this.postRef, required this.user});
  final CurrentStatusPost postRef;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final controller = ref.watch(controllerProvider);
    final post = ref
        .watch(allCurrentStatusPostsNotifierProvider)
        .asData!
        .value[postRef.id]!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${user.name}のステータス",
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildPostSection(context, ref, post),
                    Divider(
                      height: 0,
                      thickness: 0.8,
                      color: ThemeColor.white.withOpacity(0.3),
                    ),
                    _buildPostBottomSection(context, ref, post),
                  ],
                ),
              ),
              if (user.userId != ref.read(authProvider).currentUser!.uid)
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding: EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 6,
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
                          onChanged: (value) {
                            ref.read(inputTextProvider.notifier).state = value;
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              ref
                                  .read(dmUsecaseProvider)
                                  .sendCurrentStatusReply(value, user, post);
                              showMessage("メッセージを送信しました。");
                              controller.clear();
                              ref.read(inputTextProvider.notifier).state = "";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "メッセージを入力",
                            filled: true,
                            isDense: true,
                            fillColor: ThemeColor.stroke,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintStyle: textStyle.w400(
                              color: ThemeColor.subText,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      ref.watch(inputTextProvider).isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                String text = ref.read(inputTextProvider);
                                ref
                                    .read(dmUsecaseProvider)
                                    .sendCurrentStatusReply(text, user, post);
                                showMessage("メッセージを送信しました。");
                                controller.clear();
                                ref.read(inputTextProvider.notifier).state = "";
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Icon(
                                  Icons.send,
                                  color: ThemeColor.highlight,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
            ],
          ),
          const HeartAnimationArea(),
        ],
      ),
    );
  }

  Widget _buildPostSection(
      BuildContext context, WidgetRef ref, CurrentStatusPost post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final heartAnimationNotifier = ref.read(heartAnimationNotifierProvider);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (details) {
        ref
            .read(allCurrentStatusPostsNotifierProvider.notifier)
            .incrementLikeCount(user, post);
        heartAnimationNotifier.showHeart(
          context,
          details.globalPosition.dx,
          details.globalPosition.dy - themeSize.appbarHeight,
          (details.globalPosition.dy -
              themeSize.appbarHeight -
              details.localPosition.dy),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserIconPostIcon(
                  user: user,
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.createdAt.xxAgo,
                      style: textStyle.w600(fontSize: 20),
                    ),
                    const Text("ステータスを更新しました。"),
                  ],
                ),
              ],
            ),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*        if (post.after.tags
                        .where((tag) => !post.before.tags.contains(tag))
                        .isNotEmpty ||
                    post.after.tags.length != post.before.tags.length)
                  Row(
                    children: [
                      Text(
                        "タグ : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Wrap(
                          children: post.after.tags
                              .map(
                                (tag) => Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
               */
                if (post.after.doing != post.before.doing &&
                    post.after.doing.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "してること",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            post.after.doing,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.after.eating != post.before.eating &&
                    post.after.eating.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "食べてる",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            post.after.eating,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.after.mood != post.before.mood &&
                    post.after.mood.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "気分",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            post.after.mood,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.after.nowAt != post.before.nowAt &&
                    post.after.nowAt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "場所",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            post.after.nowAt,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.after.nextAt != post.before.nextAt &&
                    post.after.nextAt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "次の場所",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(
                            post.after.nextAt,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (post.after.nowWith
                    .where((id) => !post.before.nowWith.contains(id))
                    .isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          "一緒にいる人",
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: FutureBuilder(
                            future: ref
                                .read(allUsersNotifierProvider.notifier)
                                .getUserAccounts(post.after.nowWith),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }
                              final users = snapshot.data!;

                              return Wrap(
                                children: users
                                    .map(
                                      (user) => Container(
                                        margin: const EdgeInsets.all(4),
                                        child: UserIconPostIcon(
                                          user: user,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildPostBottomSection(
      BuildContext context, WidgetRef ref, CurrentStatusPost post) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (post.likeCount > 0)
            Row(
              children: [
                const Gap(12),
                GradientText(
                  text: post.likeCount.toString(),
                ),
                const Gap(4),
                Text(
                  "いいね",
                  style: textStyle.w600(color: ThemeColor.subText),
                ),
              ],
            ),
          const Gap(12),
          GestureDetector(
            onTap: () {
              PostBottomModelSheet(context)
                  .openCurrentStatusPostAction(post, user);
            },
            child: const Icon(
              Icons.more_horiz_rounded,
              color: ThemeColor.subText,
              size: 20,
            ),
          )
        ],
      ),
    );
  }
}
 */