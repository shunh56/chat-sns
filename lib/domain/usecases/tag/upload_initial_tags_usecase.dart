// lib/domain/usecases/tag/upload_initial_tags_usecase.dart

import 'package:app/data/providers/tag_providers.dart';
import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/repositories/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final uploadInitialTagsUsecaseProvider = Provider(
  (ref) => UploadInitialTagsUsecase(
    ref.watch(tagRepositoryProvider),
  ),
);

class UploadInitialTagsUsecase {
  final TagRepository _tagRepository;

  UploadInitialTagsUsecase(this._tagRepository);

  // アセットからタグをロードしてFirestoreにアップロード
  Future<void> execute() async {
    if (_tagRepository is TagRepositoryImpl) {
      final tagRepoImpl = _tagRepository as TagRepositoryImpl;
      
      // アセットからタグを読み込む
      final tags = await tagRepoImpl.loadInitialTagsFromAsset('assets/data/initial_tags.json');
      
      // Firestoreにアップロード
      await _tagRepository.uploadInitialTags(tags);
    } else {
      throw Exception('Repository implementation does not support loading tags from assets');
    }
  }
}