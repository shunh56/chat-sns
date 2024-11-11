// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/usecase/image_usecase.dart';
import 'package:app/usecase/posts/post_usecase.dart';
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
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// State
class UserImagesNotifier extends StateNotifier<AsyncValue<List<UserImage>>> {
  UserImagesNotifier(this.userId, this.usecase)
      : super(const AsyncValue.loading());

  final String userId;
  final PostUsecase usecase;

  Future<void> initialize() async {
    try {
      final posts = await usecase.getImagePostFromUserId(userId);
      final List<UserImage> images = [];
      
      for (final post in posts) {
        for (final imageUrl in post.mediaUrls) {
          images.add(UserImage(
            post.id,  // 投稿のIDを使用
            imageUrl,
            post.createdAt,
          ));
        }
      }
      
      // createdAtで降順にソート
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = AsyncValue.data(images);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /*addImages(List<String> imageUrls) {
    final list = state.asData?.value ?? [];
    final currentTime = Timestamp.now();
    final newImages = imageUrls.map((url) => 
      UserImage(DateTime.now().millisecondsSinceEpoch.toString(), url, currentTime)
    ).toList();
    
    state = AsyncValue.data([...newImages, ...list]);
  }

  removeImage(UserImage image) {
    final list = List<UserImage>.from(state.asData?.value ?? []);
    list.removeWhere((e) => e.id == image.id && e.imageUrl == image.imageUrl);
    state = AsyncValue.data(list);
    return usecase.removeImage(image);
  }*/
}