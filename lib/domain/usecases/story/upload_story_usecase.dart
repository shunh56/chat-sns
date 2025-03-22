// lib/domain/usecases/story/upload_story_usecase.dart

import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/repositories/story_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final uploadStoryUsecaseProvider = Provider(
  (ref) => UploadStoryUsecase(
    ref.watch(storyRepositoryProvider),
  ),
);

class UploadStoryUsecase {
  final StoryRepository _storyRepository;

  UploadStoryUsecase(this._storyRepository);

  Future<void> execute({
    required String userId,
    required String localMediaPath,
    String? caption,
    StoryMediaType mediaType = StoryMediaType.image,
    StoryVisibility visibility = StoryVisibility.public,
    List<String> tags = const [],
    String? location,
    bool isSensitiveContent = false,
    Duration expirationDuration = const Duration(hours: 24),
  }) async {
    // 入力検証
    if (localMediaPath.isEmpty) {
      throw Exception('Media file is required');
    }

    // UUIDの生成
    final storyId = const Uuid().v4();

    // タイムスタンプの生成
    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch + expirationDuration.inMilliseconds));

    // ストーリーオブジェクトの作成
    final story = Story(
      id: storyId,
      userId: userId,
      mediaUrl: '', // 実際のURLは後で設定される
      caption: caption,
      mediaType: mediaType,
      visibility: visibility,
      createdAt: now,
      expiresAt: expiresAt,
      tags: tags,
      location: location,
      isSensitiveContent: isSensitiveContent,
    );

    // リポジトリを通じてアップロード

    await _storyRepository.uploadStory(story, localMediaPath);
  }
}
