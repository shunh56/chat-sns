//UIからstateを構築し、そのデータをnotifierもしくはusecaseに渡す(一つの引数として)
import 'dart:io';

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PostState {
  final String id;
  final String userId;
  final String text;
  final List<File> images;
  final bool isPublic;
  PostState({
    required this.id,
    required this.userId,
    required this.text,
    required this.images,
    required this.isPublic,
  });

  get isReadyToUpload => (text.isNotEmpty);

  toJson(List<double> aspectRatios, List<String> imageUrls) {
    return {
      "id": id,
      "createdAt": Timestamp.now(),
      "userId": userId,
      "text": text,
      "mediaUrls": imageUrls,
      "aspectRatios": aspectRatios,
      "likeCount": 0,
      "replyCount": 0,
      "isDeletedByUser": false,
      "isDeletedByAdmin": false,
      "isDeletedByModerator": false,
      "isPublic": isPublic,
    };
  }
}

final postStateProvider = Provider.autoDispose(
  (ref) {
    final id = const Uuid().v4();
    final text = ref.watch(inputTextProvider);
    final images = ref.watch(imageListNotifierProvider);
    final isPublic = ref.watch(isPublicProvider);
    final userId = ref.watch(authProvider).currentUser!.uid;
    return PostState(
      id: id,
      text: text,
      images: images,
      isPublic: isPublic,
      userId: userId,
    );
  },
);

final isPublicProvider = StateProvider.autoDispose((ref) => false);
