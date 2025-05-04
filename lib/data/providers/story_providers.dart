// lib/data/providers/story_providers.dart

import 'package:app/data/repository/story_repository_impl.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/repository_interface/story_repository.dart';
import 'package:app/domain/usecases/story/get_stories_usecase.dart';
import 'package:app/domain/usecases/story/story_action_usecase.dart';
import 'package:app/presentation/providers/story/story_notifier.dart';
import 'package:app/presentation/providers/story/story_state.dart';
import 'package:app/data/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ストレージサービスプロバイダー
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// リポジトリプロバイダー
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl(
    FirebaseFirestore.instance,
    ref.watch(storageServiceProvider),
    ref,
  );
});

// メインの Story プロバイダー
/*final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>((ref) {
  return StoryNotifier(
    ref.watch(getStoriesUsecaseProvider),
    ref.watch(storyActionUsecaseProvider),
  );
}); */

// タグ別のストーリー取得プロバイダー
final tagStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, tagId) async {
  return ref.watch(getStoriesUsecaseProvider).getStoriesByTag(tagId);
});

// ユーザー別のストーリー取得プロバイダー
final userStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, userId) async {
  return ref.watch(getStoriesUsecaseProvider).getUserActiveStories(userId);
});

// フィードストーリー取得プロバイダー
final feedStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, userId) async {
  return ref.watch(getStoriesUsecaseProvider).getFeedStories(userId);
});
