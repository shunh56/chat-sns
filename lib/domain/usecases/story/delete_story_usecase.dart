// lib/domain/usecases/story/delete_story_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/repository_interface/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteStoryUsecaseProvider = Provider(
  (ref) => DeleteStoryUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class DeleteStoryUsecase {
  final StoryRepository _storyRepository;

  DeleteStoryUsecase(this._storyRepository);

  Future<void> execute({
    required String storyId,
    required String userId,
  }) async {
    // 権限チェック
    final story = await _storyRepository.getStory(storyId);

    if (story == null) {
      throw Exception('Story not found');
    }

    if (story.userId != userId) {
      throw Exception('User does not have permission to delete this story');
    }

    // ストーリー削除
    await _storyRepository.deleteStory(storyId);
  }
}
