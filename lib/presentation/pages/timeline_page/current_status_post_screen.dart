import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/direct_message_usecase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class CurrentStatusPostScreen extends ConsumerWidget {
  const CurrentStatusPostScreen(
      {super.key, required this.post, required this.user});
  final CurrentStatusPost post;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(controllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${user.name}のステータス",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildPostSection(context, ref),
                Divider(
                  height: 0,
                  thickness: 0.8,
                  color: ThemeColor.white.withOpacity(0.3),
                ),
                _buildPostBottomSection(context),
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
              decoration: BoxDecoration(
                color: ThemeColor.highlight.withOpacity(0.3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 6,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeColor.text,
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
                        fillColor: ThemeColor.background,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: ThemeColor.highlight,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        /* suffixIcon: text.value.isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                ref
                                    .read(dmUsecaseProvider)
                                    .sendMessage(text.value, user);
                                text.value = '';
                                controller.clear();
                              },
                              child: const Icon(
                                Icons.send,
                                color: ThemeColor.highlight,
                              ),
                            )
                          : const SizedBox(), */
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
    );
  }

  Widget _buildPostSection(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  child: UserIcon.bottomSheetIcon(user)),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.createdAt.xxAgo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  Text("${user.name}がステータスを更新しました。"),
                ],
              ),
            ],
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.after.tags
                      .where((tag) => !post.before.tags.contains(tag))
                      .isNotEmpty ||
                  post.after.tags.length != post.before.tags.length)
                Row(
                  children: [
                    const Text(
                      "タグ : ",
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColor.text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(8),
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
                                  style: const TextStyle(
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
              if (post.after.doing != post.before.doing &&
                  post.after.doing.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Text(
                        "してること",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.doing,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
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
                      const Text(
                        "食べてる : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.eating,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
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
                      const Text(
                        "気分 : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.mood,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
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
                      const Text(
                        "場所 : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.nowAt,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
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
                      const Text(
                        "次の場所",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          post.after.nextAt,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ThemeColor.background,
                            fontWeight: FontWeight.w400,
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
                      const Text(
                        "一緒にいる人 : ",
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
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
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            child: Container(
                                              color: ThemeColor.accent,
                                              height: 32,
                                              width: 32,
                                              child: user.imageUrl != null
                                                  ? CachedNetworkImage(
                                                      imageUrl: user.imageUrl!,
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  120),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        height: 32,
                                                        width: 32,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              const SizedBox(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const SizedBox(),
                                                    )
                                                  : const Icon(
                                                      Icons.person_outline,
                                                      size: 32 * 0.8,
                                                      color: ThemeColor.stroke,
                                                    ),
                                            ),
                                          ),
                                        ],
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
    );
  }

  _buildPostBottomSection(context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (post.replyCount > 0)
            Row(
              children: [
                Text(
                  post.replyCount.toString(),
                  style: const TextStyle(
                    color: ThemeColor.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Text(
                  "件の反応",
                  style: TextStyle(
                    color: ThemeColor.subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          if (post.likeCount > 0)
            Row(
              children: [
                const Gap(12),
                GradientText(
                  text: post.likeCount.toString(),
                ),
              ],
            ),
          const Gap(12),
          const Icon(
            Icons.more_horiz_rounded,
            color: ThemeColor.subText,
            size: 20,
          )
        ],
      ),
    );
  }
}
