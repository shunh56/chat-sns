// lib/domain/usecases/story/update_story_caption_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/repository_interface/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateStoryCaptionUsecaseProvider = Provider(
  (ref) => UpdateStoryCaptionUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class UpdateStoryCaptionUsecase {
  final StoryRepository _storyRepository;

  UpdateStoryCaptionUsecase(this._storyRepository);

  Future<void> execute({
    required String storyId,
    required String userId,
    required String newCaption,
  }) async {
    // 権限チェック
    final story = await _storyRepository.getStory(storyId);
    
    if (story == null) {
      throw Exception('Story not found');
    }
    
    if (story.userId != userId) {
      throw Exception('User does not have permission to edit this story');
    }
    
    // キャプション更新
    await _storyRepository.updateStoryCaption(storyId, newCaption);
  }
}