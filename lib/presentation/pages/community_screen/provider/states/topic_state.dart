//UIからstateを構築し、そのデータをnotifierもしくはusecaseに渡す(一つの引数として)

import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class TopicState {
  final String id;
  final String userId;
  final String? title;
  final String? text;
  final List<String> tags;

  final String? communityId;
  TopicState({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.tags,
    required this.communityId,
  });

  bool get isReadyToUpload =>
      (title != null && title!.isNotEmpty && text != null && text!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
      "userId": userId,
      "communityId": communityId,
      //
      "title": title,
      "text": text,
      "participantCount": 1,
      "postCount": 0,
      "tags": tags,
      //
      "isActive": true,
      "isPro": false,
    };
  }
}

final topicStateProvider = Provider.autoDispose(
  (ref) {
    final id = const Uuid().v4();
    final title = ref.watch(titleProvider);
    final text = ref.watch(textProvider);
    final userId = ref.watch(authProvider).currentUser!.uid;
    final tags = ref.watch(tagsProvider);
    final communityId = ref.watch(communityIdProvider);
    return TopicState(
      id: id,
      title: title,
      text: text,
      userId: userId,
      tags: tags,
      communityId: communityId,
    );
  },
);
final titleProvider = StateProvider.autoDispose<String?>((ref) => null);
final textProvider = StateProvider.autoDispose<String?>((ref) => null);
final tagsProvider = StateProvider<List<String>>((ref) => []);
final isPublicProvider = StateProvider.autoDispose((ref) => false);
final communityIdProvider = StateProvider<String?>((ref) => null);
