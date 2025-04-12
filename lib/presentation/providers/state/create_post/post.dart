import 'dart:io';

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 新しく追加するプロバイダー
final titleTextProvider = StateProvider.autoDispose((ref) => "");
final hashtagsProvider = StateProvider.autoDispose<List<String>>((ref) => []);
final mentionsProvider = StateProvider.autoDispose<List<String>>((ref) => []);

class PostState {
  final String id;
  final String userId;
  final String title;
  final String? text;
  final List<File> images;
  final List<String> hashtags;
  final List<String> mentions;
  final bool isPublic;
  //final String? communityId;

  PostState({
    required this.id,
    required this.userId,
    required this.title,
    this.text,
    required this.images,
    required this.hashtags,
    required this.mentions,
    required this.isPublic,
    //this.communityId,
  });

  // タイトルか本文のどちらかは必須
  get isReadyToUpload => title.isNotEmpty;

  toJson(List<double> aspectRatios, List<String> imageUrls) {
    return {
      "id": id,
      "createdAt": Timestamp.now(),
      "userId": userId,
      "title": title,
      "text": text,
      "mediaUrls": imageUrls,
      "aspectRatios": aspectRatios,
      "hashtags": hashtags,
      "mentions": mentions,
      "likeCount": 0,
      "replyCount": 0,
      "isDeletedByUser": false,
      "isDeletedByAdmin": false,
      "isDeletedByModerator": false,
      "isPublic": isPublic,
      // "communityId": communityId,
    };
  }
}

final postStateProvider = Provider.autoDispose(
  (ref) {
    final id = const Uuid().v4();
    final title = ref.watch(titleTextProvider);
    final text = ref.watch(inputTextProvider);
    final images = ref.watch(imageListNotifierProvider);
    final hashtags = ref.watch(hashtagsProvider);
    final mentions = ref.watch(mentionsProvider);
    final isPublic = ref.watch(isPublicProvider);
    final userId = ref.watch(authProvider).currentUser!.uid;
    //final communityId = ref.watch(communityIdProvider);

    return PostState(
      id: id,
      userId: userId,
      title: title,
      text: text.isEmpty ? null : text,
      images: images,
      hashtags: hashtags,
      mentions: mentions,
      isPublic: isPublic,
      //  communityId: communityId,
    );
  },
);

final isPublicProvider = StateProvider.autoDispose((ref) => true);
//final communityIdProvider = StateProvider.autoDispose<String?>((ref) => null);
