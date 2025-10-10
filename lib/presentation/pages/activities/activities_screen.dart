import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/activities_list_notifier.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActivitiesScreen extends HookConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(activitiesListNotifierProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(activitiesListNotifierProvider.notifier);
        notifier.readActivities();
      });
      return null;
    }, const []);
    final listView = asyncValue.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const Gap(16),
                Text(
                  "通知はありません",
                  style: textStyle.w600(
                    fontSize: 16,
                    color: ThemeColor.subText,
                  ),
                ),
              ],
            ),
          );
        }

        // 未読と既読を分ける
        final unreadActivities =
            list.where((activity) => !activity.isSeen).toList();
        final readActivities =
            list.where((activity) => activity.isSeen).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // 未読セクション
            if (unreadActivities.isNotEmpty) ...[
              _SectionHeader(
                title: '未読',
                count: unreadActivities.length,
              ),
              ListView.builder(
                itemCount: unreadActivities.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ActivityTile(activity: unreadActivities[index]);
                },
              ),
              const Gap(16),
            ],

            // 既読セクション
            if (readActivities.isNotEmpty) ...[
              _SectionHeader(
                title: '既読',
                count: readActivities.length,
              ),
              ListView.builder(
                itemCount: readActivities.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  return ActivityTile(activity: readActivities[index]);
                },
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, s) => const SizedBox(),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "アクティビティ",
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(activitiesListNotifierProvider.notifier).refresh();
        },
        child: listView,
      ),
    );
  }
}

class ActivityTile extends ConsumerWidget {
  const ActivityTile({super.key, required this.activity});
  final Activity activity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    var users = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => activity.userIds.contains(user.userId))
        .toList();
    if (users.isEmpty) return const SizedBox();
    if (users.length > 2) {
      users = users.sublist(0, 2);
    }
    if (activity.actionType == ActionType.none) {
      return const SizedBox();
    }
    return InkWell(
      splashColor: ThemeColor.stroke,
      highlightColor: Colors.white.withOpacity(0.05),
      onTap: () async {
        ref
            .read(activitiesListNotifierProvider.notifier)
            .readActivity(activity);
        try {
          if (activity.actionType.toString().startsWith("ActionType.post")) {
            final post =
                await ref.read(postUsecaseProvider).getPost(activity.refId);
            activity.post = post;
            ref.read(allPostsNotifierProvider.notifier).addPosts([post]);
            ref
                .read(navigationRouterProvider(context))
                .goToPost(activity.post, me);
          }
        } catch (e) {
          showErrorSnackbar(error: e);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: themeSize.horizontalPadding,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: activity.isSeen
              ? Colors.transparent
              : ThemeColor.highlight.withOpacity(0.05),
        ),
        child: Row(
          children: [
            // アクションアイコン
            _buildActionIcon(activity.actionType),
            const Gap(12),

            // ユーザーアイコン
            SizedBox(
              width: 48,
              height: 48,
              child: users.length == 2
                  ? Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: UserIcon(
                            user: users[0],
                            r: 18,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: UserIcon(
                            user: users[1],
                            r: 18,
                          ),
                        ),
                      ],
                    )
                  : UserIcon(
                      user: users[0],
                      r: 24,
                    ),
            ),
            const Gap(12),

            // テキスト情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: activity.userIds.length > 1
                              ? "${users[0].name}さん、他${activity.userIds.length - 1}人"
                              : "${users[0].name}さん",
                          style: textStyle.w600(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: contentText(activity.actionType),
                          style: textStyle.w400(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(4),
                  Text(
                    activity.updatedAt.xxAgo,
                    style: textStyle.w400(
                      fontSize: 12,
                      color: ThemeColor.subText,
                    ),
                  ),
                ],
              ),
            ),

            // 未読インジケーター
            if (!activity.isSeen)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ThemeColor.highlight,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(ActionType type) {
    final IconData iconData;
    final Color iconColor;

    switch (type) {
      case ActionType.postReaction:
        iconData = Icons.emoji_emotions_outlined;
        iconColor = Colors.yellow.shade700;
        break;
      case ActionType.postLike:
        iconData = Icons.favorite_rounded;
        iconColor = Colors.pink.shade400;
        break;
      case ActionType.currentStatusPostLike:
        iconData = Icons.favorite_rounded;
        iconColor = Colors.pink.shade400;
        break;
      case ActionType.postComment:
        iconData = Icons.comment_rounded;
        iconColor = Colors.blue.shade400;
        break;
      case ActionType.none:
        return const SizedBox(width: 32);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 18,
      ),
    );
  }

  String contentText(ActionType type) {
    switch (type) {
      case ActionType.postReaction:
        return "があなたの投稿にリアクションしました";
      case ActionType.postLike:
        return "があなたの投稿にいいねしました";
      case ActionType.postComment:
        return "があなたの投稿にコメントしました";
      case ActionType.currentStatusPostLike:
        return "があなたのステータスにいいねしました";
      case ActionType.none:
        return "";
    }
  }
}

/// セクションヘッダー
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ThemeColor.subText,
            ),
          ),
          const Gap(6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
