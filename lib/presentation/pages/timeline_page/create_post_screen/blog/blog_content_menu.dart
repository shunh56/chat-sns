import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/blog/blog_contents_input.dart';
import 'package:app/presentation/providers/state/create_post/blog.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogContentMenu extends ConsumerWidget {
  const BlogContentMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final inputTextNotifier = ref.watch(inputTextProvider.notifier);
    final contentListNotifier = ref.watch(contentListNotifierProvider.notifier);
    return Container(
      color: Colors.white.withOpacity(0.1),
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              
              final item = ref.watch(inputTextProvider);
              if (item.isNotEmpty) {
                contentListNotifier.addContent(item);
                inputTextNotifier.state = "";
                ref.watch(controllerProvider).clear();
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ThemeColor.button,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
