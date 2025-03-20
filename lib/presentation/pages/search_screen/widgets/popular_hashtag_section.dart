// lib/presentation/widgets/popular_hashtags_section.dart

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/providers/tag_providers.dart';
import 'package:app/domain/usecases/tag/upload_initial_tags_usecase.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/story/story_home_page.dart';
import 'package:app/presentation/providers/tag/tag_state.dart';
import 'package:app/temp/sample_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopularHashtagsSection extends ConsumerStatefulWidget {
  const PopularHashtagsSection({super.key});

  @override
  ConsumerState<PopularHashtagsSection> createState() =>
      _PopularHashtagsSectionState();
}

class _PopularHashtagsSectionState
    extends ConsumerState<PopularHashtagsSection> {
  @override
  void initState() {
    super.initState();
    // 画面表示後にタグを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagProvider.notifier).loadAllTags();
    });
  }

  // タグのカテゴリに基づいて背景画像URLを取得
  String _getBackgroundImageUrl(String tagName, String? category) {
    // タグカテゴリや名前に基づいてシード値を決定
    final seed = (category ?? tagName).toLowerCase().replaceAll(' ', '-');
    // ランダム性を持たせつつも同じタグなら同じ画像になるように固定シード値を使用
    return 'https://picsum.photos/seed/$seed/300/300';
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tagState = ref.watch(tagProvider);

    // タグの状態に基づいて表示
    if (tagState.status == TagStatus.loading) {
      return Center(child: CircularProgressIndicator());
    }

    // 使用回数に基づいて人気のタグを取得
    final popularTags = [...tagState.tags]
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    // 上位8つのタグを取得（または全てのタグが8つ未満の場合は全て）
    final displayTags = popularTags.take(8).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "注目のハッシュタグ",
                style: textStyle.w700(
                  fontSize: 20,
                  color: ThemeColor.white,
                ),
              ),
              TextButton(
                onPressed: () async {
                  // 全てのタグを表示するページに遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryHomePage(),
                    ),
                  );
                },
                child: Text(
                  "すべて見る",
                  style: textStyle.w500(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          // 新しいタグ表示UIの実装（背景画像付き）
          Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayTags.length,
              itemBuilder: (context, index) {
                final tag = displayTags[index];
                final bgImageUrl = _getBackgroundImageUrl(tag.name, tag.category);
                
                return GestureDetector(
                  onTap: () {
                    // タグがタップされた時、対応するストーリーページに遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoryHomePage(initialTag: tag),
                      ),
                    );

                    // タグの使用回数を増加
                    ref.read(tagProvider.notifier).useTag(tag);
                  },
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 背景画像
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: bgImageUrl,
                            height: 180,
                            width: 150,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Color(0xFF2A2A2A),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Color(0xFF2A2A2A),
                              child: Icon(Icons.error, color: Colors.white54),
                            ),
                          ),
                        ),
                        // オーバーレイグラデーション
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // コンテンツ
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // タグ名
                              Text(
                                "#${tag.name}",
                                style: textStyle.w700(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              // 投稿数とカテゴリ
                              Row(
                                children: [
                                  Icon(
                                    Icons.photo_library,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "${tag.usageCount} 投稿",
                                    style: textStyle.w500(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              if (tag.category != null) ...[
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag.category!,
                                    style: textStyle.w500(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}