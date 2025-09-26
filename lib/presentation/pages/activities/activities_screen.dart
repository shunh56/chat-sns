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
import 'package:flutter/services.dart';
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
        return ListView(
          addAutomaticKeepAlives: true,
          children: [
            //ここに、直近1週間で獲得した通知件数をアニメーションで大きく表示させたい。
            AnimatedNotificationCounter(count: () {
              int cnt = 0;
              final q = list
                  .where((e) => e.updatedAt.toDate().isAfter(
                      DateTime.now().subtract(const Duration(days: 7))))
                  .toList();
              for (var i in q) {
                cnt += i.userIds.length;
              }
              return cnt;
            }()),
            ListView.builder(
              itemCount: list.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
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
            ),
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
      highlightColor: Colors.white.withOpacity(0.1),
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
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Gap(4),
                  _buildActionIcon(activity.actionType),
                  const Gap(16),
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
      case ActionType.postReaction:
        iconData = Icons.emoji_emotions_outlined;
        iconColor = Colors.yellow;
        break;
      case ActionType.postLike:
        iconData = Icons.favorite_outline_rounded;
        iconColor = Colors.pinkAccent;
        break;
      case ActionType.currentStatusPostLike:
        iconData = Icons.favorite_outline_rounded;
        iconColor = Colors.pinkAccent;
        break;
      case ActionType.postComment:
        iconData = Icons.comment_outlined;
        iconColor = Colors.blue;
        break;
      case ActionType.none:
        return Text(type.toString()); // 空のウィジェットを返す
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  String contentText(ActionType type) {
    switch (type) {
      case ActionType.postReaction:
        return "があなたの投稿にリアクションしました。";
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
} // アニメーション実行済み状態を管理するProvider

// アニメーション実行済み状態を管理するProvider
final animationExecutedProvider = StateProvider.autoDispose((ref) => false);

// カウンターの状態を管理するProvider
final notificationCounterProvider = StateNotifierProvider.autoDispose
    .family<NotificationCounterNotifier, NotificationCounterState, int>(
  (ref, targetCount) => NotificationCounterNotifier(targetCount),
);

// 状態クラス
class NotificationCounterState {
  final int currentCount;
  final bool isAnimating;
  final bool isCompleted;

  const NotificationCounterState({
    this.currentCount = 0,
    this.isAnimating = false,
    this.isCompleted = false,
  });

  NotificationCounterState copyWith({
    int? currentCount,
    bool? isAnimating,
    bool? isCompleted,
  }) {
    return NotificationCounterState(
      currentCount: currentCount ?? this.currentCount,
      isAnimating: isAnimating ?? this.isAnimating,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// StateNotifier
class NotificationCounterNotifier
    extends StateNotifier<NotificationCounterState> {
  final int targetCount;

  NotificationCounterNotifier(this.targetCount)
      : super(const NotificationCounterState());

  Future<void> startAnimation() async {
    if (state.isAnimating || targetCount == 0) return;

    state = state.copyWith(isAnimating: true);

    // 3秒固定のアニメーション
    int incrementInterval = 1;
    int totalSteps = 1;

    if (targetCount < 10) {
      totalSteps = targetCount;
      incrementInterval = 80;
    } else if (targetCount < 30) {
      totalSteps = targetCount;
      incrementInterval = 60 - targetCount;
    } else {
      totalSteps = 30;
      incrementInterval = 30;
    }

    final increment = targetCount / totalSteps;
    int currentStep = 0;
    double currentValue = 0.0;

    while (currentStep < totalSteps) {
      if (!mounted) return;

      currentStep++;
      currentValue += increment;

      // 最後のステップでは正確に目標値に設定
      if (currentStep == totalSteps) {
        state = state.copyWith(currentCount: targetCount);
      } else {
        state = state.copyWith(currentCount: currentValue.round());
      }

      // ハプティックフィードバック（20ステップごと、または最後）
      if (currentStep % 20 == 0 || currentStep == totalSteps) {
        HapticFeedback.lightImpact();
      }

      await Future.delayed(Duration(milliseconds: incrementInterval));
    }

    state = state.copyWith(isAnimating: false, isCompleted: true);

    // 完了時の強いハプティック
    HapticFeedback.mediumImpact();
  }

  // アニメーション完了後の静的表示用
  void setFinalCount() {
    state = state.copyWith(
      currentCount: targetCount,
      isAnimating: false,
      isCompleted: true,
    );
  }

  void reset() {
    state = const NotificationCounterState();
  }
}

class AnimatedNotificationCounter extends HookConsumerWidget {
  final int count;

  const AnimatedNotificationCounter({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
      ),
    );

    final counterState = ref.watch(notificationCounterProvider(count));
    final counterNotifier =
        ref.read(notificationCounterProvider(count).notifier);

    // アニメーション実行済みフラグの監視と制御
    final hasAnimationExecuted = ref.watch(animationExecutedProvider);
    //final setAnimationExecuted = ref.read(animationExecutedProvider.notifier);

    // 初回アニメーション開始（一度だけ実行）
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentExecutedState = hasAnimationExecuted;

        if (!currentExecutedState) {
          // 初回のみ：フルアニメーション実行
          animationController.forward();
          Future.delayed(const Duration(milliseconds: 300), () {
            counterNotifier.startAnimation().then((_) {
              // アニメーション完了後にフラグを立てる
              ref.read(animationExecutedProvider.notifier).state = true;
            });
          });
        } else {
          // 既にアニメーション実行済みの場合は最終値を直接表示
          animationController.forward();
          counterNotifier.setFinalCount();
        }
      });
      return null;
    }, []); // hasAnimationExecutedを依存関係から削除

    // カウント完了時のバウンスアニメーション（初回のみ）
    final bounceController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final bounceAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: bounceController,
          curve: Curves.bounceOut,
        ),
      ),
    );

    useEffect(() {
      final currentExecutedState = ref.read(animationExecutedProvider);
      if (counterState.isCompleted && !currentExecutedState) {
        bounceController.forward();
      }
      return null;
    }, [counterState.isCompleted]);

    final theme = Theme.of(context);

    return Transform.scale(
      scale: scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 48, bottom: 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0084FF), // 鮮やかなブルー
              Color(0xFFF61AFE), // ピンクパープル
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            // タイトルセクション
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '今週の通知',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const Gap(8),

            // カウンター表示
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                Transform.scale(
                  scale: counterState.isCompleted && !hasAnimationExecuted
                      ? bounceAnimation
                      : (hasAnimationExecuted ? 1.0 : 0.8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: Text(
                      '${counterState.currentCount}',
                      key: ValueKey(counterState.currentCount),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 80,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(4, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(4),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '件',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
