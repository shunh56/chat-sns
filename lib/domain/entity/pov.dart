import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pov {
  final String imageUrl;
  final double aspectRatio;
  final String text;
  //
  final String id;
  final String userId;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  int likeCount;
  int replyCount;
  //
  bool isDeletedByUser;
  bool isDeletedByAdmin;
  bool isDeletedByModerator;

  Pov({
    required this.imageUrl,
    required this.aspectRatio,
    required this.text,
    //
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.replyCount,
    required this.isDeletedByUser,
    required this.isDeletedByAdmin,
    required this.isDeletedByModerator,
  });

  factory Pov.fromJson(Map<String, dynamic> json) {
    return Pov(
      imageUrl: json["imageUrl"],
      aspectRatio: json["aspectRatio"],
      text: json["text"],
      id: json["id"],
      userId: json["userId"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"],
      isDeletedByUser: json["isDeletedByUser"],
      isDeletedByAdmin: json["isDeletedByAdmin"],
      isDeletedByModerator: json["isDeletedByModerator"],
    );
  }

  /*factory Pov.fromPovState(PovState povState) {
    final timestamp = Timestamp.now();
    return Pov(
      imageUrl: povState.imageFile!,
      text: povState.text,
      id: Uuid().v4(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: timestamp,
      updatedAt: timestamp,
      likeCount: 0,
      replyCount: 0,
      isDeletedByUser: false,
      isDeletedByAdmin: false,
      isDeletedByModerator: false,
    );
  } */
}

class PovState {
  final String text;
  final File? imageFile;

  PovState({
    required this.text,
    required this.imageFile,
  });

  bool get isReadyToUpload => (text.isNotEmpty && imageFile != null);
}

final povStateProvider = Provider.autoDispose(
  (ref) {
    final text = ref.watch(povTextProvider);
    final image = ref.watch(povImageFileProvider);
    return PovState(
      text: text,
      imageFile: image,
    );
  },
);

final povTextProvider = StateProvider.autoDispose((ref) => "");
final povImageFileProvider = StateProvider.autoDispose<File?>((ref) => null);
