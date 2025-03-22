// lib/presentation/providers/tag/tag_notifier.dart

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/usecases/tag/get_tags_usecase.dart';
import 'package:app/domain/usecases/tag/use_tag_usecase.dart';
import 'package:app/presentation/providers/tag/tag_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagNotifier extends StateNotifier<TagState> {
  final GetTagsUsecase _getTagsUsecase;
  final UseTagUsecase _useTagUsecase;

  TagNotifier(this._getTagsUsecase, this._useTagUsecase)
      : super(const TagState());

  // すべてのタグを読み込む
  Future<void> loadAllTags() async {
    try {
      state = state.copyWith(
        status: TagStatus.loading,
        errorMessage: null,
      );

      final tags = await _getTagsUsecase.getAllTags();

      // カテゴリ別にタグを整理
      final Map<String, List<Tag>> tagsByCategory = {};

      for (final tag in tags) {
        final category = tag.category ?? 'その他';
        if (!tagsByCategory.containsKey(category)) {
          tagsByCategory[category] = [];
        }
        tagsByCategory[category]!.add(tag);
      }

      state = state.copyWith(
        status: TagStatus.loaded,
        tags: tags,
        tagsByCategory: tagsByCategory,
      );
    } catch (e) {
      DebugPrint("Error : $e");
      state = state.copyWith(
        status: TagStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // カテゴリ別にタグを読み込む
  Future<void> loadTagsByCategory(String category) async {
    try {
      state = state.copyWith(
        status: TagStatus.loading,
        errorMessage: null,
      );

      final tags = await _getTagsUsecase.getTagsByCategory(category);

      state = state.copyWith(
        status: TagStatus.loaded,
        tags: tags,
      );
    } catch (e) {
      state = state.copyWith(
        status: TagStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // タグを検索
  Future<void> searchTags(String query) async {
    if (query.isEmpty) {
      await loadAllTags();
      return;
    }

    try {
      state = state.copyWith(
        status: TagStatus.loading,
        errorMessage: null,
      );

      final tags = await _getTagsUsecase.searchTags(query);

      state = state.copyWith(
        status: TagStatus.loaded,
        tags: tags,
      );
    } catch (e) {
      state = state.copyWith(
        status: TagStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // タグを選択/選択解除
  void toggleTagSelection(Tag tag) {
    final selectedTags = List<Tag>.from(state.selectedTags);

    if (selectedTags.any((t) => t.id == tag.id)) {
      selectedTags.removeWhere((t) => t.id == tag.id);
    } else {
      selectedTags.add(tag);
    }

    state = state.copyWith(selectedTags: selectedTags);
  }

  // タグの使用を記録
  Future<void> useTag(Tag tag) async {
    try {
      await _useTagUsecase.incrementTagUsage(tag.id);

      // ローカルのタグ情報も更新
      final updatedTags = state.tags.map((t) {
        if (t.id == tag.id) {
          return t.copyWith(usageCount: t.usageCount + 1);
        }
        return t;
      }).toList();

      state = state.copyWith(tags: updatedTags);
    } catch (e) {
      // エラーハンドリング（オプション）
      print('Failed to record tag usage: $e');
    }
  }

  // 選択されたタグをクリア
  void clearSelectedTags() {
    state = state.copyWith(selectedTags: []);
  }
}
