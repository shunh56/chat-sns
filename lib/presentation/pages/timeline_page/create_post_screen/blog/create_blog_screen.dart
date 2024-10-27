import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/blog/blog_content_menu.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/blog/blog_contents_input.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/blog/blog_contents_list.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/blog/title_input.dart';
import 'package:app/presentation/providers/state/create_post/blog.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:app/usecase/posts/blog_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CreateBlogScreen extends ConsumerWidget {
  const CreateBlogScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final blogUsecase = ref.read(blogUsecaseProvider);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: themeSize.screenHeight,
            width: themeSize.screenWidth,
          ),
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding),
                  children: [
                    Gap(MediaQuery.of(context).viewPadding.top +
                        themeSize.appbarHeight +
                        12),
                    const BlogTitleInputWidget(),
                    const Gap(8),
                    const Divider(),
                    const BlogContentsList(),
                    const Gap(8),
                    const BlogContentInputWidget(),
                  ],
                ),
              ),
              const BlogContentMenu(),
            ],
          ),
          //bottom menu items

          //top banner
          Positioned(
            top: 0,
            child: Container(
              color: ThemeColor.background,
              height: MediaQuery.of(context).viewPadding.top +
                  themeSize.appbarHeight,
              width: MediaQuery.sizeOf(context).width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    bottom: 4,
                    child: Text(
                      "ブログ",
                      style: TextStyle(
                        color: ThemeColor.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: themeSize.horizontalPadding,
                    child: GestureDetector(
                      onTap: () {
                        primaryFocus?.unfocus();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "キャンセル",
                        style: TextStyle(
                          color: ThemeColor.highlight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: themeSize.horizontalPadding,
                    child: GestureDetector(
                      onTap: () async {
                        
                        debugPrint(
                            "title : ${ref.watch(blogStateProvider).title}");
                        debugPrint(
                            "contents : ${ref.watch(blogStateProvider).contents}");
                        if (ref.watch(blogStateProvider).isReadyToUpload) {
                          final text = ref.read(inputTextProvider);
                          if (text.isNotEmpty) {
                            ref
                                .read(contentListNotifierProvider.notifier)
                                .addContent(text);
                          }
                          final blogState = ref.watch(blogStateProvider);
                          blogUsecase.uploadPost(blogState);
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
                            color: ref.watch(blogStateProvider).isReadyToUpload
                                ? ThemeColor.white
                                : Colors.white.withOpacity(0.3),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
