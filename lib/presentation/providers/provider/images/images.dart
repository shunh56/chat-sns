// Flutter imports:

// Package imports:

import 'package:app/usecase/image_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserImage {
  final String id;
  final String imageUrl;
  final Timestamp createdAt;
  UserImage(this.id, this.imageUrl, this.createdAt);

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      json["id"],
      json["imageUrl"],
      json["createdAt"],
    );
  }

  bool get isNew {
    return DateTime.now().difference(createdAt.toDate()).inHours < 24;
  }
}

final userImagesNotiferProvider = StateNotifierProvider.family<
    UserImagesNotifier, AsyncValue<List<UserImage>>, String>((ref, userId) {
  return UserImagesNotifier(
    userId,
    ref.watch(imageUsecaseProvider),
  )..initialize();
});

/// State
class UserImagesNotifier extends StateNotifier<AsyncValue<List<UserImage>>> {
  UserImagesNotifier(this.userId, this.usecase)
      : super(const AsyncValue.loading());

  final String userId;
  final ImageUsecase usecase;

  Future<void> initialize() async {
    final imageUrls = await usecase.getImages(userId: userId);
    state = AsyncValue.data(imageUrls);
  }

  addImages(List<String> imageUrls) {
    final list = state.asData?.value ?? [];
    final adding = usecase.addImages(imageUrls);
    state = AsyncValue.data([...adding, ...list]);
  }

  removeImage(UserImage image) {
    final list = List<UserImage>.from(state.asData?.value ?? []);
    list.removeWhere((e) => e.id == image.id);
    state = AsyncValue.data(list);
    return usecase.removeImage(image);
  }
}
