// lib/domain/usecases/tag/get_popular_tags_usecase.dart
import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getPopularTagsUsecaseProvider = Provider<GetPopularTagsUsecase>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return GetPopularTagsUsecase(repository);
});

class GetPopularTagsUsecase {
  final TagRepository repository;

  GetPopularTagsUsecase(this.repository);

  Future<List<TagStat>> execute(int limit) async {
    return await repository.getPopularTags(limit: limit);
  }
}
