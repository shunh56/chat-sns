import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateUserTagsUsecaseProvider = Provider<UpdateUserTagsUsecase>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return UpdateUserTagsUsecase(repository);
});

class UpdateUserTagsUsecase {
  final TagRepository repository;

  UpdateUserTagsUsecase(this.repository);

  Future<void> execute({
    required List<String> newTags,
    required List<String> previousTags,
  }) async {
    await repository.updateUserTagsImmediate(newTags, previousTags);
  }
}
