import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/state/create_post/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogContentsList extends ConsumerWidget {
  const BlogContentsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentList = ref.watch(contentListNotifierProvider);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 2,
                  color: ThemeColor.white.withOpacity(0.3),
                ),
              ),
            ),
            child: Text(
              contentList[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
