// lib/presentation/providers/story/story_state.dart

import 'package:app/domain/entity/story/story.dart';

enum StoryStatus { initial, loading, loaded, error }

class StoryState {
  final StoryStatus status;
  final List<Story> stories;
  final String? errorMessage;
  final bool isUploading;
  final double uploadProgress;
  final bool hasMore; // hasMore プロパティを追加

  const StoryState({
    this.status = StoryStatus.initial,
    this.stories = const [],
    this.errorMessage,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.hasMore = false, // デフォルト値を設定
  });

  StoryState copyWith({
    StoryStatus? status,
    List<Story>? stories,
    String? errorMessage,
    bool? isUploading,
    double? uploadProgress,
    bool? hasMore, // copyWith メソッドにも追加
  }) {
    return StoryState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
