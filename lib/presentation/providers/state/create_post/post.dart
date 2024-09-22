//UIからstateを構築し、そのデータをnotifierもしくはusecaseに渡す(一つの引数として)
import 'dart:io';

import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostState {
  final String text;
  final List<File> images;
  final bool isPublic;
  PostState({
    required this.text,
    required this.images,
    required this.isPublic,
  });

  get isReadyToUpload => (text.isNotEmpty);
}

final postStateProvider = Provider.autoDispose(
  (ref) {
    final text = ref.watch(inputTextProvider);
    final images = ref.watch(imageListNotifierProvider);
    final isPublic = ref.watch(isPublicProvider);
    return PostState(
      text: text,
      images: images,
      isPublic: isPublic,
    );
  },
);

final isPublicProvider = StateProvider((ref) => false);
