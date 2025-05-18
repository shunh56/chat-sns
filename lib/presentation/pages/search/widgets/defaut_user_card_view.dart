import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/search/sub_pages/user_card_stack_screen.dart';
import 'package:app/presentation/providers/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class DefaultUserCardView extends ConsumerWidget {
  const DefaultUserCardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);
    final onlineUsersAsyncValue = ref.watch(recentUsersNotifierProvider);
    final width = themeSize.screenWidth * 0.42;
    final height = width * 1.3;
    const titleSize = 16.0;
    const textSize = 14.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "気になる友達を見つけよう",
                style: textStyle.w700(
                  fontSize: 20,
                  color: ThemeColor.white,
                ),
              ),
              const Gap(4),
              Text(
                "新しく始めた人やアクティブなユーザーと\n趣味や興味を共有して仲良くなろう",
                style: textStyle.w400(
                  fontSize: 14,
                  color: const Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        SizedBox(
          height: height,
          child: ListView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            children: [
// newUsersのカードスタック
              newUsersAsyncValue.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const SizedBox();
                  }
                  users.removeWhere((user) => user.isMe);
                  final user = users.first;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserCardStackScreen(
                            users: users,
                            userGroupId: "new_users", // 固有のIDを指定
                            userGroupTitle: "最近始めたユーザー", // オプションでタイトルも指定可能
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base image container with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: CachedImage.usersCard(user.imageUrl!),
                            ),
                          ),
                          // Blur effect with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "最近始めたユーザー",
                                style: textStyle.w600(
                                  fontSize: titleSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                "新しいユーザー",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: textSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(height / 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: ThemeColor.error),
                      const Gap(8),
                      Text(
                        'エラーが発生しました\n${error.toString()}',
                        textAlign: TextAlign.center,
                        style: textStyle.w400(
                          fontSize: 12,
                          color: ThemeColor.error,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

// onlineUsersのカードスタック
              onlineUsersAsyncValue.when(
                data: (users) {
                  users.removeWhere((user) => user.isMe);
                  if (users.isEmpty) {
                    return const SizedBox();
                  }
                  final user = users.first;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserCardStackScreen(
                            users: users,
                            userGroupId: "online_users", // 固有のIDを指定
                            userGroupTitle: "アクティブな友達", // オプションでタイトルも指定可能
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base image container with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: CachedImage.usersCard(user.imageUrl!),
                            ),
                          ),
                          // Blur effect with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "アクティブな友達",
                                style: textStyle.w800(
                                  fontSize: titleSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                "オンラインの友達",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: textSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(height / 3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: ThemeColor.error),
                      const Gap(8),
                      Text(
                        'エラーが発生しました\n${error.toString()}',
                        textAlign: TextAlign.center,
                        style: textStyle.w400(
                          fontSize: 12,
                          color: ThemeColor.error,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
