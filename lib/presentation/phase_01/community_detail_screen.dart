import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/community.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final Community community;

  const CommunityDetailScreen({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // カスタムAppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: ThemeColor.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ヘッダー背景画像
                  Image.network(
                    community.backgroundImageUrl,
                    fit: BoxFit.cover,
                  ),
                  // グラデーションオーバーレイ
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          ThemeColor.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {},
              ),
            ],
          ),

          // コミュニティ情報
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // コミュニティヘッダー
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(community.thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community.title,
                              style: textStyle.w700(
                                fontSize: 24,
                                color: ThemeColor.white,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              "${community.memberCount}人が参加中",
                              style: textStyle.w500(
                                fontSize: 14,
                                color: ThemeColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // 参加ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "コミュニティに参加",
                        style: textStyle.w600(fontSize: 16),
                      ),
                    ),
                  ),
                  const Gap(24),

                  // 説明文
                  Text(
                    community.description,
                    style: textStyle.w400(
                      fontSize: 15,
                      color: ThemeColor.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const Gap(16),

                  // タグ
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: community.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColor.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "#$tag",
                          style: textStyle.w500(
                            fontSize: 13,
                            color: ThemeColor.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(24),

                  // 統計情報
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColor.stroke,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: community.statistics.entries.map((entry) {
                        return Column(
                          children: [
                            Text(
                              entry.value.toString(),
                              style: textStyle.w700(
                                fontSize: 20,
                                color: ThemeColor.white,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              entry.key,
                              style: textStyle.w400(
                                fontSize: 12,
                                color: ThemeColor.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const Gap(24),

                  // コミュニティルール
                  Text(
                    "コミュニティルール",
                    style: textStyle.w600(
                      fontSize: 18,
                      color: ThemeColor.white,
                    ),
                  ),
                  const Gap(12),
                  ...community.rules.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: ThemeColor.primary,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              rule,
                              style: textStyle.w400(
                                fontSize: 14,
                                color: ThemeColor.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Gap(24),

                  // 最近の投稿
                  Text(
                    "最近の投稿",
                    style: textStyle.w600(
                      fontSize: 18,
                      color: ThemeColor.white,
                    ),
                  ),
                  const Gap(16),
                  ...community.recentPosts.map((post) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColor.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ThemeColor.stroke,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(post.userImageUrl),
                              ),
                              const Gap(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.userName,
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: ThemeColor.white,
                                    ),
                                  ),
                                  Text(
                                    "2時間前",
                                    style: textStyle.w400(
                                      fontSize: 12,
                                      color: ThemeColor.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(12),
                          Text(
                            post.content,
                            style: textStyle.w400(
                              fontSize: 15,
                              color: ThemeColor.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          if (post.imageUrl != null) ...[
                            const Gap(12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post.imageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          const Gap(12),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border_rounded,
                                    size: 20,
                                    color: ThemeColor.textTertiary,
                                  ),
                                  const Gap(4),
                                  Text(
                                    post.likeCount.toString(),
                                    style: textStyle.w500(
                                      fontSize: 13,
                                      color: ThemeColor.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 20,
                                    color: ThemeColor.textTertiary,
                                  ),
                                  const Gap(4),
                                  Text(
                                    post.commentCount.toString(),
                                    style: textStyle.w500(
                                      fontSize: 13,
                                      color: ThemeColor.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Gap(24),

                  // アクティブメンバー
                  Text(
                    "アクティブメンバー",
                    style: textStyle.w600(
                      fontSize: 18,
                      color: ThemeColor.white,
                    ),
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColor.stroke,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: community.topMembers.map((member) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        NetworkImage(member.imageUrl),
                                  ),
                                  if (member.isOnline)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: ThemeColor.success,
                                          border: Border.all(
                                            color: ThemeColor.background,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: textStyle.w600(
                                        fontSize: 15,
                                        color: ThemeColor.white,
                                      ),
                                    ),
                                    Text(
                                      member.role,
                                      style: textStyle.w400(
                                        fontSize: 13,
                                        color: ThemeColor.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "フォロー",
                                  style: textStyle.w500(
                                    fontSize: 13,
                                    color: ThemeColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),

      // 投稿ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: ThemeColor.primary,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}
