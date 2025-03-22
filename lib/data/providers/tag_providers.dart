// lib/presentation/providers/tag/tag_provider.dart

import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/repositories/tag_repository.dart';
import 'package:app/domain/usecases/tag/get_tags_usecase.dart';
import 'package:app/domain/usecases/tag/upload_initial_tags_usecase.dart';
import 'package:app/domain/usecases/tag/use_tag_usecase.dart';
import 'package:app/presentation/providers/tag/tag_notifier.dart';
import 'package:app/presentation/providers/tag/tag_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(FirebaseFirestore.instance);
});

// タグ状態管理用のプロバイダー
final tagProvider = StateNotifierProvider<TagNotifier, TagState>((ref) {
  return TagNotifier(
    ref.watch(getTagsUsecaseProvider),
    ref.watch(useTagUsecaseProvider),
  );
});

// カテゴリー別のタグを取得するプロバイダー
final tagsByCategoryProvider =
    Provider.family<List<Tag>, String>((ref, category) {
  final tagState = ref.watch(tagProvider);

  if (tagState.tagsByCategory.containsKey(category)) {
    return tagState.tagsByCategory[category] ?? [];
  }
  return [];
});

// 人気のタグを取得するプロバイダー（使用回数順）
final popularTagsProvider = Provider<List<Tag>>((ref) {
  final tags = ref.watch(tagProvider).tags;

  if (tags.isEmpty) return [];

  final sortedTags = [...tags]
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  return sortedTags;
});

// 最新のタグを取得するプロバイダー（作成日順）
final recentTagsProvider = Provider<List<Tag>>((ref) {
  final tags = ref.watch(tagProvider).tags;

  if (tags.isEmpty) return [];

  final sortedTags = [...tags]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedTags;
});

// 特定のタグを取得するプロバイダー
final tagByIdProvider = Provider.family<Tag?, String>((ref, tagId) {
  final tags = ref.watch(tagProvider).tags;
  return tags.firstWhere((tag) => tag.id == tagId);
});

// 初期タグをアップロードするためのプロバイダー（管理者機能）
final uploadInitialTagsProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(uploadInitialTagsUsecaseProvider).execute();
});

// 選択されたタグのプロバイダー
final selectedTagsProvider = Provider<List<Tag>>((ref) {
  return ref.watch(tagProvider).selectedTags;
});
