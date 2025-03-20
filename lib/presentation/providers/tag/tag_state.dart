// lib/presentation/providers/tag/tag_state.dart

import 'package:app/domain/entity/tag/tag.dart';

enum TagStatus { initial, loading, loaded, error }

class TagState {
  final TagStatus status;
  final List<Tag> tags;
  final List<Tag> selectedTags;
  final String? errorMessage;
  final bool isUploading;
  final Map<String, List<Tag>> tagsByCategory;

  const TagState({
    this.status = TagStatus.initial,
    this.tags = const [],
    this.selectedTags = const [],
    this.errorMessage,
    this.isUploading = false,
    this.tagsByCategory = const {},
  });

  TagState copyWith({
    TagStatus? status,
    List<Tag>? tags,
    List<Tag>? selectedTags,
    String? errorMessage,
    bool? isUploading,
    Map<String, List<Tag>>? tagsByCategory,
  }) {
    return TagState(
      status: status ?? this.status,
      tags: tags ?? this.tags,
      selectedTags: selectedTags ?? this.selectedTags,
      errorMessage: errorMessage,
      isUploading: isUploading ?? this.isUploading,
      tagsByCategory: tagsByCategory ?? this.tagsByCategory,
    );
  }
}
