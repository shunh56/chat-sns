import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/datasource/local/hashtags.dart';
import 'package:app/presentation/pages/profile_page/edit_bio_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectHashtagScreen extends ConsumerWidget {
  final List<String> beforeTags;
  final maxCount = 5;

  const SelectHashtagScreen({
    super.key,
    required this.beforeTags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    // 選択されたタグのリスト
    final selectedTags = ref.watch(tagsStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        } else {
          ref.read(tagsStateProvider.notifier).state = beforeTags;
          Navigator.of(context).pop();
        }
        // 標準的なスワイプ遷移アニメーションを適用して画面を閉じる

        return; // trueを返すと標準の戻る動作が発生するため、falseを返す
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'ハッシュタグを選択',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // 選択中のタグを表示するセクション

            _buildSelectedTagsSection(context, ref, selectedTags),

            // カテゴリ別のタグ一覧
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: hashtagCategoryList.length,
                itemBuilder: (context, index) {
                  final category = hashtagCategoryList[index];
                  final categoryName = hashtagCategoryMap[category]!;
                  final tagsList = getTagsByGenre(category);

                  // タグがない場合はスキップ
                  if (tagsList.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tagsList.map((e) {
                          final tagId = e["id"]!;
                          final tagName = e["text"]!;
                          final isSelected = selectedTags.contains(tagId);

                          return _buildTagChip(
                              context, ref, tagId, tagName, isSelected);
                        }).toList(),
                      ),
                      Divider(color: Colors.white24, height: 32),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '選択中: ${selectedTags.length}/$maxCount',
                  style: textStyle.w500(
                    fontSize: 15,
                    color: ThemeColor.subText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '選択を完了',
                    style: textStyle.w600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 選択中のタグ表示セクション
  Widget _buildSelectedTagsSection(
      BuildContext context, WidgetRef ref, List<String> selectedTags) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '選択中のタグ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(tagsStateProvider.notifier).state = [],
                child: Text(
                  'クリア',
                  style: textStyle.w600(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: selectedTags.map((tagId) {
              // タグIDからテキストを取得
              final tagText = getTextFromId(tagId) ?? tagId;

              return Chip(
                label: Text(
                  tagText,
                  style: textStyle.w600(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(
                    width: 0,
                  ),
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                onDeleted: () {
                  removeTag(ref, tagId);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // タグチップウィジェット
  Widget _buildTagChip(BuildContext context, WidgetRef ref, String tagId,
      String tagName, bool isSelected) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return FilterChip(
      label: Text(
        tagName,
        style: textStyle.w600(
          fontSize: 14,
          color: isSelected ? Colors.white : ThemeColor.subText,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        if (isSelected) {
          removeTag(ref, tagId);
        } else {
          addTag(ref, tagId);
        }
      },
      backgroundColor: ThemeColor.accent,
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          width: 0,
        ),
      ),
    );
  }

  addTag(WidgetRef ref, String id) {
    final selectedTags = ref.watch(tagsStateProvider);
    final notifier = ref.read(tagsStateProvider.notifier);
    if (selectedTags.length < maxCount && !selectedTags.contains(id)) {
      final newTags = List<String>.from([...selectedTags, id]);
      notifier.state = newTags;
    }
  }

  removeTag(WidgetRef ref, String id) {
    final selectedTags = ref.read(tagsStateProvider);
    final notifier = ref.read(tagsStateProvider.notifier);
    notifier.state = [...selectedTags]..remove(id);
  }
}
