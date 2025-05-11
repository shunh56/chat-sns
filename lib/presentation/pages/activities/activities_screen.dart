import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/activities_list_notifier.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
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
          return SizedBox(
            height: themeSize.screenHeight * 0.1,
            child: Center(
              child: Text(
                "アクティビティはありません。",
                style: textStyle.w600(
                  color: ThemeColor.subText,
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final activity = list[index];
            return Column(
              children: [
                if (index == 0)
                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: ThemeColor.stroke,
                  ),
                ActivityTile(activity: activity),
                const Divider(
                  height: 0,
                  thickness: 0.8,
                  color: ThemeColor.stroke,
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, s) => const SizedBox(),
    );
    return Scaffold(
      appBar: AppBar(
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

    return InkWell(
      splashColor: ThemeColor.stroke,
      highlightColor: Colors.white.withOpacity(0.1),
      onTap: () async {
        ref
            .read(activitiesListNotifierProvider.notifier)
            .readActivity(activity);
        try {
          if (activity.actionType == ActionType.postLike ||
              activity.actionType == ActionType.postComment) {
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
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildActionIcon(activity.actionType),
                  const Gap(16),
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: users.length == 2
                        ? Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: UserIcon(
                                  user: users[0],
                                  width: 36,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: UserIcon(
                                  user: users[1],
                                  width: 36,
                                ),
                              ),
                            ],
                          )
                        : UserIcon(
                            user: users[0],
                            width: 54,
                          ),
                  ),
                  const Gap(12),
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
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: contentText(
                                  activity.actionType,
                                ),
                                style: activity.isSeen
                                    ? textStyle.w400(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.7),
                                      )
                                    : textStyle.w600(
                                        fontSize: 14,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              activity.updatedAt.xxAgo,
                              style: textStyle.w400(
                                fontSize: 10,
                                color: ThemeColor.subText,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
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
      case ActionType.postLike:
      case ActionType.currentStatusPostLike:
        iconData = Icons.favorite_outline_rounded;
        iconColor = Colors.pinkAccent;
        break;
      case ActionType.postComment:
        iconData = Icons.comment_outlined;
        iconColor = Colors.blue;
        break;
      case ActionType.none:
        return const SizedBox(); // 空のウィジェットを返す
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  String contentText(ActionType type) {
    switch (type) {
      case ActionType.postLike:
        return "があなたの投稿にいいねしました";
      case ActionType.postComment:
        return "があなたの投稿にコメントしました。";
      case ActionType.currentStatusPostLike:
        return "があなたのステータスにいいねしました。";
      case ActionType.none:
        return "";
    }
  }
}
