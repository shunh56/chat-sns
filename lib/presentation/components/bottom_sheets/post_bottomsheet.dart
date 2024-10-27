import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/others/report_user_screen.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:app/presentation/pages/timeline_page/widget/reply_widget.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/posts/replies.dart';
import 'package:app/usecase/voice_chat_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PostBottomModelSheet {
  PostBottomModelSheet(this.context);
  final BuildContext context;

  openPostMenu() {
    showModalBottomSheet(
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, chlid) {
          final themeSize = ref.watch(themeSizeProvider(context));
          final textStyle = ThemeTextStyle(themeSize: themeSize);
          return Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 36,
              left: 12,
              right: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //ios design
                Container(
                  height: 4,
                  width: MediaQuery.sizeOf(context).width / 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const Gap(12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      PageTransitionMethods.slideUp(
                        const CreatePostScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: ThemeColor.icon,
                            ),
                            const Gap(12),
                            Text(
                              "つぶやき",
                              style: textStyle.w600(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          "短いテキストメッセージを友達にシェア。気軽に日常の出来事や考えをフレンドにリアルタイムで共有できる。",
                          style: textStyle.w400(
                            fontSize: 10,
                            color: ThemeColor.subText,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    Navigator.pop(context);
                    openVoiceChatMenu();
                    showUpcomingSnackbar();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.graphic_eq_rounded,
                              color: ThemeColor.icon,
                            ),
                            const Gap(12),
                            Text(
                              "ボイスチャット",
                              style: textStyle.w600(
                                fontSize: 14,
                              ),
                            ),
                            const Gap(12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ThemeColor.stroke,
                                ),
                                color: ThemeColor.white.withOpacity(0.1),
                              ),
                              child: Text(
                                "PRO",
                                style: textStyle.w600(),
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          "リアルタイムの音声会話。フレンドや新しい人々と通話をすることができます。",
                          style: textStyle.w400(
                            fontSize: 10,
                            color: ThemeColor.subText,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //blog?
              ],
            ),
          );
        });
      },
    );
  }

  final vcTitleProvider = StateProvider.autoDispose((ref) => "");
  openVoiceChatMenu() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);
            final controller = ref.watch(controllerProvider);
            return Container(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
                left: 12,
                right: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ios design
                  Container(
                    height: 4,
                    width: MediaQuery.sizeOf(context).width / 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(24),
                  Text(
                    "ボイスルームを作成",
                    style: textStyle.w600(
                      fontSize: 14,
                    ),
                  ),
                  const Gap(24),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 20,
                    style: textStyle.w600(
                      fontSize: 14,
                    ),
                    onChanged: (value) {
                      ref.read(inputTextProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "タイトル",
                      filled: true,
                      isDense: true,
                      fillColor: ThemeColor.stroke,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintStyle: textStyle.w400(
                        fontSize: 14,
                        color: ThemeColor.subText,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ref.watch(inputTextProvider).isNotEmpty
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                String text = ref.read(inputTextProvider);
                                controller.clear();
                                ref.read(inputTextProvider.notifier).state = "";
                                final vc = await ref
                                    .read(voiceChatUsecaseProvider)
                                    .createVoiceChat(text);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VoiceChatScreen(id: vc.id),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.pink,
                                ),
                                child: Text(
                                  "作成する",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : Opacity(
                              opacity: 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: ThemeColor.accent),
                                child: Text(
                                  "作成する",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  final inputTextProvider = StateProvider.autoDispose((ref) => "");
  final controllerProvider =
      Provider.autoDispose((ref) => TextEditingController());

  openReplies(UserAccount user, Post post) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);
            final controller = ref.watch(controllerProvider);
            final asyncValue = ref.watch(postRepliesNotifierProvider(post.id));

            final listView = asyncValue.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      "コメントはありません",
                      style: textStyle.w600(
                        fontSize: 14,
                        color: ThemeColor.subText,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final reply = list[index];
                    return ReplyWidget(reply: reply);
                  },
                );
              },
              error: (e, s) => Text("error : $e, $s"),
              loading: () {
                return const SizedBox();
              },
            );
            return Container(
              height: themeSize.screenHeight * 0.6,
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ios design
                  Container(
                    height: 4,
                    width: MediaQuery.sizeOf(context).width / 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    "コメント",
                    style: textStyle.w600(
                      fontSize: 14,
                    ),
                  ),

                  Expanded(
                    child: listView,
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 16,
                      right: 16,
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
                              ref.read(inputTextProvider.notifier).state =
                                  value;
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                ref
                                    .read(allPostsNotifierProvider.notifier)
                                    .addReply(user, post, value);
                                controller.clear();
                                ref.read(inputTextProvider.notifier).state = "";
                                primaryFocus?.unfocus();
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
                                fontSize: 14,
                                color: ThemeColor.subText,
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
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  String text = ref.read(inputTextProvider);
                                  ref
                                      .read(allPostsNotifierProvider.notifier)
                                      .addReply(user, post, text);

                                  controller.clear();
                                  ref.read(inputTextProvider.notifier).state =
                                      "";
                                  primaryFocus?.unfocus();
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
          },
        );
      },
    );
  }

  openPostAction(Post post, UserAccount user, {bool hideComments = false}) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
                left: themeSize.horizontalPadding,
                right: themeSize.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ios design
                  Container(
                    height: 4,
                    width: MediaQuery.sizeOf(context).width / 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(24),

                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref
                                .read(navigationRouterProvider(context))
                                .goToProfile(
                                  user,
                                  replace: true,
                                );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "プロフィール",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: ThemeColor.icon,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!hideComments)
                          Column(
                            children: [
                              Divider(
                                height: 0,
                                thickness: 0.4,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pop(context);
                                  openReplies(user, post);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "コメント",
                                        style: textStyle.w600(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: ThemeColor.icon,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),

                  //TODO
                  /*    const Gap(12),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                        behavior:HitTestBehavior.opaque,
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ミュート",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_off_outlined,
                                  color: ThemeColor.icon,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
 */
                  const Gap(12),
                  if (user.userId != ref.watch(authProvider).currentUser!.uid)
                    Container(
                      decoration: BoxDecoration(
                        color: ThemeColor.stroke,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReportUserScreen(user),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "報告",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.error,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: ThemeColor.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 0,
                            thickness: 0.4,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context);
                              UserBottomModelSheet(context)
                                  .blockUserBottomSheet(user);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ブロック",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.error,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.block_outlined,
                                    color: ThemeColor.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  openCurrentStatusPostAction(CurrentStatusPost post, UserAccount user) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
                left: themeSize.horizontalPadding,
                right: themeSize.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ios design
                  Container(
                    height: 4,
                    width: MediaQuery.sizeOf(context).width / 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(24),

                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref
                                .read(navigationRouterProvider(context))
                                .goToProfile(
                                  user,
                                  replace: true,
                                );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "プロフィール",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: ThemeColor.icon,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (user.userId !=
                            ref.watch(authProvider).currentUser!.uid)
                          Column(
                            children: [
                              Divider(
                                height: 0,
                                thickness: 0.4,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  ref
                                      .read(navigationRouterProvider(context))
                                      .goToCurrentStatusPost(post, user,
                                          replace: true);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "メッセージを送る",
                                        style: textStyle.w600(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: ThemeColor.icon,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),

                  //TODO
                  /*    const Gap(12),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                        behavior:HitTestBehavior.opaque,
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ミュート",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_off_outlined,
                                  color: ThemeColor.icon,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
 */
                  const Gap(12),
                  if (user.userId != ref.watch(authProvider).currentUser!.uid)
                    Container(
                      decoration: BoxDecoration(
                        color: ThemeColor.stroke,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReportUserScreen(user),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "報告",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.error,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: ThemeColor.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            height: 0,
                            thickness: 0.4,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              UserBottomModelSheet(context)
                                  .blockUserBottomSheet(user);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ブロック",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.error,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.block_outlined,
                                    color: ThemeColor.error,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
