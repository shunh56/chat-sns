import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/activities.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/activities_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(activitiesListNotifierProvider);
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
      body: listView,
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
    if (users.length > 2) {
      users = users.sublist(0, 2);
    }
    return InkWell(
      splashColor: ThemeColor.stroke,
      highlightColor: Colors.white.withOpacity(0.1),
      onTap: () {
        if (activity.actionType == ActionType.postLike ||
            activity.actionType == ActionType.postComment) {
          ref
              .read(navigationRouterProvider(context))
              .goToPost(activity.post as Post, me);
        } else {
          ref
              .read(navigationRouterProvider(context))
              .goToCurrentStatusPost(activity.post as CurrentStatusPost, me);
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
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: activity.userIds.length > 1
                                ? "${users[0].name}、他${activity.userIds.length - 1}人"
                                : users[0].name,
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: contentText(
                              activity.actionType,
                            ),
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            Text(
              activity.updatedAt.xxAgo,
              style: textStyle.w400(
                color: ThemeColor.subText,
              ),
            )
          ],
        ),
      ),
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
