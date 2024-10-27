import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/images_widget.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/post_content_menu_widget.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/post_text_input_widget.dart';
import 'package:app/presentation/providers/notifier/push_notification_notifier.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:app/usecase/posts/post_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            primaryFocus?.unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: themeSize.horizontalPadding,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            primaryFocus?.unfocus();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "キャンセル",
                            style: textStyle.w400(
                              fontSize: 14,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final postState = ref.read(postStateProvider);
                            final text = ref.read(inputTextProvider);
                            if (text.isNotEmpty) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              ref
                                  .read(allPostsNotifierProvider.notifier)
                                  .createPost(postState);
                              showMessage("送信を開始しました。");
                              Navigator.pop(context);
                            } else {
                              showMessage("テキストを入力してください。");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ThemeColor.highlight,
                            ),
                            child: Text(
                              "送信",
                              style: TextStyle(
                                color:
                                    ref.watch(postStateProvider).isReadyToUpload
                                        ? ThemeColor.white
                                        : Colors.white.withOpacity(0.3),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: const [
                          Gap(24),
                          PostTextInputWidget(),
                          Gap(8),
                          PostImagesWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              _buildPublicityLabel(ref),
              const Gap(8),
              const PostContentMenu(),
            ],
          ),
        ),
      ),
    );
  }

  _buildPublicityLabel(WidgetRef ref) {
    final isPublic = ref.watch(isPublicProvider);
    return GestureDetector(
      onTap: () {
        ref.read(isPublicProvider.notifier).state = !isPublic;
      },
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
        child: isPublic
            ? const Row(
                children: [
                  Icon(
                    size: 18,
                    Icons.public_rounded,
                    color: Colors.blueAccent,
                  ),
                  Gap(4),
                  Text(
                    "公開",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              )
            : const Row(
                children: [
                  Icon(
                    size: 18,
                    Icons.lock_outline_rounded,
                    color: Colors.blueAccent,
                  ),
                  Gap(4),
                  Text(
                    "友達のみ",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
