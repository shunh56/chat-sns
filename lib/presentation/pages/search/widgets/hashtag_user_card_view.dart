import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/datasource/local/hashtags.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/search/sub_pages/user_card_stack_screen.dart';
import 'package:app/presentation/providers/users/hashtag_users.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/tag_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class HashtagUserCardView extends ConsumerWidget {
  const HashtagUserCardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tagIds = ref.watch(myAccountNotifierProvider).asData!.value.tags;
    //final tagIds = hashTags.map((e) => e["id"]!).toList();

    // タグが存在しない場合は何も表示しない
    if (tagIds.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "同じ趣味のユーザー",
            style: textStyle.w700(
              fontSize: 20,
              color: ThemeColor.white,
            ),
          ),
        ),
        const Gap(12),
        // GridViewでタグカードを表示
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true, // Columnの中で使うためにshrinkWrapをtrue
          physics: const NeverScrollableScrollPhysics(), // 親スクロールに任せる
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2列
            childAspectRatio: 0.75, // カードの縦横比
            crossAxisSpacing: 12, // 水平方向の間隔
            mainAxisSpacing: 12, // 垂直方向の間隔
          ),
          itemCount: tagIds.length,
          itemBuilder: (context, index) {
            final tagId = tagIds[index];
            final tagName = getTextFromId(tagId) ?? tagId;
            return _buildTagCard(context, ref, tagId, tagName, textStyle);
          },
        ),
      ],
    );
  }

  Widget _buildTagCard(BuildContext context, WidgetRef ref, String tagId,
      String tagName, ThemeTextStyle textStyle) {
    final asyncValue = ref.watch(hashTagUsersNotifierProvider(tagId));
    final themeSize = ref.watch(themeSizeProvider(context));
    final asyncTagStat = ref.watch(tagStatProvider(tagId));
    final statsWidget = asyncTagStat.when(
      data: (data) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "#$tagName",
              style: textStyle.w600(
                fontSize: 18,
                color: ThemeColor.white,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            Text(
              "${data.count}人",
              style: textStyle.w600(
                fontSize: 14,
                color: ThemeColor.white,
              ),
            ),
            Gap(themeSize.screenWidth / 4.5)
          ],
        );
      },
      error: (e, s) => SizedBox(),
      loading: () => SizedBox(),
    );
    return asyncValue.when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyCard(tagName, textStyle);
        }

        final user = users.first;
        return GestureDetector(
          onTap: () async {
            await ref
                .read(hashTagUsersNotifierProvider(tagId).notifier)
                .loadMore();
            final loadedUsers =
                ref.read(hashTagUsersNotifierProvider(tagId)).asData!.value;
            loadedUsers.removeWhere((user) => user.isMe);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserCardStackScreen(
                  users: loadedUsers,
                  userGroupId: "hashtag_$tagId",
                  userGroupTitle: "#$tagName",
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ユーザー画像
                  user.imageUrl != null
                      ? CachedImage.usersCard(user.imageUrl!)
                      : const SizedBox(),
                  // 暗くするオーバーレイ
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  statsWidget,
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) => _buildErrorCard(tagName, error, textStyle),
      loading: () => _buildLoadingCard(),
    );
  }

  // データがない場合のカード
  Widget _buildEmptyCard(String tagName, ThemeTextStyle textStyle) {
    // グラデーションと微妙な光沢効果を持つ背景
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColor.accent.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ThemeColor.accent.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // 背景装飾パターン
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CustomPaint(
                painter: GridPatternPainter(
                  lineColor: ThemeColor.accent.withOpacity(0.05),
                  lineWidth: 1,
                  gridSize: 12,
                ),
              ),
            ),
          ),

          // 右上のアクセント
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ThemeColor.accent.withOpacity(0.4),
                    ThemeColor.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // 左下のアクセント
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ThemeColor.accent.withOpacity(0.2),
                    ThemeColor.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // メインコンテンツ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // カスタムアイコン表現
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(
                      color: ThemeColor.accent.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeColor.accent.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeColor.accent,
                            Colors.purpleAccent.withOpacity(0.7),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.person_search,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Gap(12),

                // タグ名
                Text(
                  "#$tagName",
                  style: textStyle.w600(
                    fontSize: 14,
                    color: ThemeColor.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Gap(10),

                // ユーザーがいないテキスト
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeColor.accent.withOpacity(0.5),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      "ユーザーがいません",
                      style: textStyle.w400(
                        fontSize: 12,
                        color: ThemeColor.subText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // エラー表示のカード
  Widget _buildErrorCard(
      String tagName, Object error, ThemeTextStyle textStyle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColor.error.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: ThemeColor.error,
          ),
          const Gap(8),
          Text(
            "#$tagName",
            style: textStyle.w600(
              fontSize: 14,
              color: ThemeColor.white,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(4),
          Text(
            "読み込みエラー",
            style: textStyle.w400(
              fontSize: 12,
              color: ThemeColor.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ローディング表示のカード
  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

// グリッドパターンの描画用のカスタムペインター
class GridPatternPainter extends CustomPainter {
  final Color lineColor;
  final double lineWidth;
  final double gridSize;

  GridPatternPainter({
    required this.lineColor,
    required this.lineWidth,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 斜めのグリッドパターンを描画
    for (double i = 0; i < size.width + size.height; i += gridSize) {
      // 左下から右上への線
      canvas.drawLine(
        Offset(0, i),
        Offset(i, 0),
        paint,
      );

      // 右下から左上への線
      canvas.drawLine(
        Offset(size.width, i),
        Offset(size.width - i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
