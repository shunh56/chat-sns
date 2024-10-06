
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/blog.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class BlogWidget extends ConsumerWidget {
  const BlogWidget({super.key, required this.blog, required this.user});
  final Blog blog;
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  child: UserIcon.tileIcon(user, width: 40),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  blog.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "・${blog.createdAt.xxAgo}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(4),
                          const Icon(
                            Icons.more_horiz_rounded,
                            color: ThemeColor.subText,
                            size: 20,
                          )
                        ],
                      ),
                      const Gap(4),
                      Text(
                        blog.contents.join(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              children: user.currentStatus.tags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.only(right: 8),
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
                          fontSize: 12,
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _buildPostBottomSection(context),
          // const Gap(8),
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
          if (blog.replyCount > 0)
            Row(
              children: [
                Text(
                  blog.replyCount.toString(),
                  style: const TextStyle(
                    color: ThemeColor.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Text(
                  "messages",
                  style: TextStyle(
                    color: ThemeColor.subText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          if (blog.likeCount > 0)
            Row(
              children: [
                const Gap(12),
                GradientText(
                  text:blog.likeCount.toString(),
                  
                ),
              ],
            ),
        ],
      ),
    );
  }
}

