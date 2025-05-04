// lib/domain/usecases/story/toggle_story_like_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/repository_interface/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleStoryLikeUsecaseProvider = Provider(
  (ref) => ToggleStoryLikeUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class ToggleStoryLikeUsecase {
  final StoryRepository _storyRepository;

  ToggleStoryLikeUsecase(this._storyRepository);

  Future<bool> execute({
    required String storyId,
    required String userId,
  }) async {
    // 現在のいいね状態を確認
    final isLiked = await _storyRepository.hasUserLikedStory(storyId, userId);
    
    // いいねの状態を切り替え
    if (isLiked) {
      await _storyRepository.unlikeStory(storyId, userId);
      return false; // いいねを解除した
    } else {
      await _storyRepository.likeStory(storyId, userId);
      return true; // いいねした
    }
  }
}