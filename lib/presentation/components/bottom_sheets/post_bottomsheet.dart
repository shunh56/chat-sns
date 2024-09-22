import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/voice_chat_screen.dart';
import 'package:app/presentation/pages/timeline_page/widget/reply_widget.dart';
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
        return Container(
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(context).viewPadding.bottom + 12,
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: ThemeColor.icon,
                          ),
                          Gap(12),
                          Text(
                            "つぶやき",
                            style: TextStyle(
                              color: ThemeColor.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Gap(4),
                      Text(
                        "短いテキストメッセージを友達にシェア。気軽に日常の出来事や考えをフレンドにリアルタイムで共有できる。",
                        style: TextStyle(
                          color: ThemeColor.text,
                          fontSize: 10,
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
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.graphic_eq_rounded,
                            color: ThemeColor.icon,
                          ),
                          Gap(12),
                          Text(
                            "ボイスチャット",
                            style: TextStyle(
                              color: ThemeColor.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Gap(4),
                      Text(
                        "リアルタイムの音声会話。フレンドや新しい人々と通話をすることができます。",
                        style: TextStyle(
                          color: ThemeColor.text,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
              ),
/*
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransitionMethods.slideUp(
                      const CreateBlogScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            color: ThemeColor.icon,
                          ),
                          Gap(12),
                          Text(
                            "ブログ",
                            style: TextStyle(
                              color: ThemeColor.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Gap(4),
                      Text(
                        "全ユーザーに公開される投稿形式。タイトルと文章を含み、詳細な内容や考えをまとめて公開することができます。",
                        style: TextStyle(
                          color: ThemeColor.text,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                ),
              ),
          */
            ],
          ),
        );
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
            final controller = ref.watch(controllerProvider);
            return Container(
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  const Text(
                    "ボイスルームを作成",
                    style: TextStyle(
                      color: ThemeColor.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(24),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      ref.read(inputTextProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "タイトル",
                      filled: true,
                      isDense: true,
                      fillColor: ThemeColor.accent,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
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
                                child: Container(
                                  child: const Text(
                                    "作成する",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                child: Container(
                                  child: const Text(
                                    "作成する",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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

  openReplies(Post post) {
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
            final controller = ref.watch(controllerProvider);
            final asyncValue = ref.watch(postRepliesNotifierProvider(post.id));

            final listView = asyncValue.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "コメントはありません",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  const Text(
                    "コメント",
                    style: TextStyle(
                      color: ThemeColor.text,
                      fontWeight: FontWeight.w600,
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
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeColor.text,
                            ),
                            onChanged: (value) {
                              ref.read(inputTextProvider.notifier).state =
                                  value;
                            },
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                ref
                                    .read(allPostsNotifierProvider.notifier)
                                    .addReply(post, value);
                                controller.clear();
                                ref.read(inputTextProvider.notifier).state = "";
                                primaryFocus?.unfocus();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "メッセージを入力",
                              filled: true,
                              isDense: true,
                              fillColor: ThemeColor.accent,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: ThemeColor.white,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                            ),
                          ),
                        ),
                        ref.watch(inputTextProvider).isNotEmpty
                            ? GestureDetector(
                                onTap: () async {
                                  String text = ref.read(inputTextProvider);
                                  ref
                                      .read(allPostsNotifierProvider.notifier)
                                      .addReply(post, text);

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
}
