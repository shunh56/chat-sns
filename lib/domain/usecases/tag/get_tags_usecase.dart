// lib/domain/usecases/tag/get_tags_usecase.dart

import 'package:app/data/providers/tag_providers.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/repositories/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTagsUsecaseProvider = Provider(
  (ref) => GetTagsUsecase(
    ref.watch(tagRepositoryProvider),
  ),
);

class GetTagsUsecase {
  final TagRepository _tagRepository;

  GetTagsUsecase(this._tagRepository);

  // 全てのタグを取得
  Future<List<Tag>> getAllTags() async {
    return await _tagRepository.getAllTags();
  }

  // カテゴリ別にタグを取得
  Future<List<Tag>> getTagsByCategory(String category) async {
    return await _tagRepository.getTagsByCategory(category);
  }

  // タグを検索
  Future<List<Tag>> searchTags(String query) async {
    return await _tagRepository.searchTags(query);
  }

  // タグIDでタグを取得
  Future<Tag?> getTagById(String tagId) async {
    return await _tagRepository.getTagById(tagId);
  }
}