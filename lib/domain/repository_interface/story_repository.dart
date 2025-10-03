// lib/domain/repositories/story_repository.dart

import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/story/story_view.dart';

abstract class StoryRepository {
  // ストーリーの作成・取得・更新・削除
  Future<void> uploadStory(Story story, String localMediaPath);
  Future<Story?> getStory(String storyId);
  Future<void> updateStoryCaption(String storyId, String newCaption);
  Future<void> deleteStory(String storyId);

  // いいね関連
  Future<void> likeStory(String storyId, String userId);
  Future<void> unlikeStory(String storyId, String userId);
  Future<bool> hasUserLikedStory(String storyId, String userId);

  // ユーザー関連ストーリー
  Future<List<Story>> getUserStories(String userId);
  Future<List<Story>> getActiveUserStories(String userId); // 追加
  Future<List<Story>> getFollowingUserStories(String userId);

  // タグ関連
  Future<List<Story>> getStoriesByTag(String tagId); // 追加

  // ストーリーアクション
  Future<void> addStoryAction(StoryAction action); // viewStory の代わり
  Future<List<StoryAction>> getStoryActions(
      String storyId, StoryActionType type); // getStoryViewers の代わり
}
