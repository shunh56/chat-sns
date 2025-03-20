// lib/domain/usecases/story/story_action_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/entity/story/story_view.dart';
import 'package:app/domain/repositories/story_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final storyActionUsecaseProvider = Provider(
  (ref) => StoryActionUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class StoryActionUsecase {
  final StoryRepository _storyRepository;

  StoryActionUsecase(this._storyRepository);

  // ストーリー閲覧を記録
  Future<void> markStoryAsViewed(String storyId, String viewerId) async {
    final actionId = const Uuid().v4();
    final action = StoryAction.view(
      id: actionId,
      storyId: storyId,
      userId: viewerId,
      createdAt: Timestamp.now(),
    );

    await _storyRepository.addStoryAction(action);
  }

  // ストーリーの閲覧者を取得
  Future<List<StoryAction>> getStoryViewers(String storyId) async {
    return await _storyRepository.getStoryActions(
        storyId, StoryActionType.view);
  }
}
