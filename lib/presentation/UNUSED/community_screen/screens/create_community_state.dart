// lib/presentation/pages/community/states/create_community_state.dart

import 'dart:io';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:app/domain/usecases/image_uploader_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'create_community_state.freezed.dart';
part 'create_community_state.g.dart';

@freezed
class CreateCommunityState with _$CreateCommunityState {
  const factory CreateCommunityState({
    @Default('') String name,
    @Default('') String description,
    @Default([]) List<String> tags,
    File? thumbnailFile, // FileをNullableで管理
    @Default(false) bool isLoading,
    String? error,
  }) = _CreateCommunityState;
}

@riverpod
class CreateCommunityNotifier extends _$CreateCommunityNotifier {
  @override
  CreateCommunityState build() => const CreateCommunityState();

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateThumbnailFile(File file) {
    state = state.copyWith(thumbnailFile: file);
  }

  void addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !state.tags.contains(trimmedTag)) {
      state = state.copyWith(tags: [...state.tags, trimmedTag]);
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(
      tags: state.tags.where((t) => t != tag).toList(),
    );
  }

  Future<void> createCommunity() async {
    final id = const Uuid().v4();
    if (state.thumbnailFile == null) {
      state = state.copyWith(error: 'サムネイル画像を選択してください');
      throw Exception('サムネイル画像を選択してください');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final communityUsecase = ref.read(communityUsecaseProvider);
      final userId = ref.read(authProvider).currentUser!.uid;

      // 画像をアップロードしてURLを取得
      final thumbnailUrl = await ref
          .read(imageUploadUsecaseProvider)
          .uploadCommunityThumbnailImage(id, state.thumbnailFile!);

      final community = Community(
        id: id,
        name: state.name,
        description: state.description,
        thumbnailImageUrl: thumbnailUrl,
        memberCount: 0,
        messageCount: 0,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        moderators: [userId],
        userId: userId,
        tags: state.tags,
      );

      await communityUsecase.createCommunity(community);
    } catch (e) {
      showErrorSnackbar(error: e);
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
