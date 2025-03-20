// lib/domain/usecases/story/get_stories_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/repositories/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final getStoriesUsecaseProvider = Provider(
  (ref) => GetStoriesUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class GetStoriesUsecase {
  final StoryRepository _storyRepository;

  GetStoriesUsecase(this._storyRepository);

  // ユーザーのアクティブなストーリーを取得
  Future<List<Story>> getUserActiveStories(String userId) async {
    return await _storyRepository.getActiveUserStories(userId);
  }

  // フィードストーリーを取得 (フォロー中のユーザーのストーリー)
  Future<List<Story>> getFeedStories(String currentUserId) async {
    return await _storyRepository.getFollowingUserStories(currentUserId);
  }

  // タグでストーリーを検索
  Future<List<Story>> getStoriesByTag(String tagId) async {
    return await _storyRepository.getStoriesByTag(tagId);
  }

}