// lib/domain/usecases/tag/get_popular_tags_usecase.dart
import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/entity/tag_stat.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getActiveUsersProvider = Provider<GetActiveUsers>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return GetActiveUsers(repository);
});

class GetActiveUsers {
  final TagRepository repository;

  GetActiveUsers(this.repository);

  Future<List<TagUser>> execute(
    String tagId, {
    String? lastUserId,
  }) async {
    return await repository.getActiveUsers(
      tagId,
    );
  }
}
