// lib/presentation/providers/story/story_notifier.dart

import 'package:app/domain/usecases/story/get_stories_usecase.dart';
import 'package:app/domain/usecases/story/story_action_usecase.dart';
import 'package:app/presentation/providers/story/story_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class StoryNotifier extends StateNotifier<StoryState> {
  final GetStoriesUsecase _getStoriesUsecase;
  final StoryActionUsecase _storyActionUsecase;

  StoryNotifier(this._getStoriesUsecase, this._storyActionUsecase)
      : super(const StoryState());

  // フィードストーリーを読み込む
  Future<void> loadFeedStories(String currentUserId) async {
    try {
      state = state.copyWith(
        status: StoryStatus.loading,
        errorMessage: null,
      );

      final stories = await _getStoriesUsecase.getFeedStories(currentUserId);

      state = state.copyWith(
        status: StoryStatus.loaded,
        stories: stories,
        hasMore: false, // ストーリーはページネーションなしで全件取得
      );
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ユーザーのストーリーを読み込む
  Future<void> loadUserStories(String userId) async {
    try {
      state = state.copyWith(
        status: StoryStatus.loading,
        errorMessage: null,
      );

      final stories = await _getStoriesUsecase.getUserActiveStories(userId);

      state = state.copyWith(
        status: StoryStatus.loaded,
        stories: stories,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // タグでストーリーを検索
  Future<void> loadStoriesByTag(String tagId) async {
    try {
      state = state.copyWith(
        status: StoryStatus.loading,
        errorMessage: null,
      );

      final stories = await _getStoriesUsecase.getStoriesByTag(tagId);

      state = state.copyWith(
        status: StoryStatus.loaded,
        stories: stories,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: StoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ストーリーを閲覧済みとしてマーク
  Future<void> markAsViewed(String storyId, String viewerId) async {
    try {
      await _storyActionUsecase.markStoryAsViewed(storyId, viewerId);
      
      // ローカルの状態も更新（閲覧数を増やす）
      final updatedStories = state.stories.map((story) {
        if (story.id == storyId) {
          return story.copyWith(viewCount: story.viewCount + 1);
        }
        return story;
      }).toList();
      
      state = state.copyWith(stories: updatedStories);
    } catch (e) {
      // エラーがあっても特に状態は変更しない
      print('Failed to mark story as viewed: $e');
    }
  }
}