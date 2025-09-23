import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timelineScrollController = Provider((ref) => ScrollController());
final chattingScrollController = Provider((ref) => ScrollController());

class ScrollToTopNotifier extends StateNotifier<int> {
  ScrollToTopNotifier() : super(0);

  void scrollToTop() {
    state = state + 1;
  }
}

final scrollToTopProvider = StateNotifierProvider<ScrollToTopNotifier, int>((ref) {
  return ScrollToTopNotifier();
});

class AnimatedPostsNotifier extends StateNotifier<Set<String>> {
  AnimatedPostsNotifier() : super(<String>{});

  void addAnimatedPost(String postId) {
    state = {...state, postId};
  }

  bool hasBeenAnimated(String postId) {
    return state.contains(postId);
  }
}

final animatedPostsProvider = StateNotifierProvider<AnimatedPostsNotifier, Set<String>>((ref) {
  return AnimatedPostsNotifier();
});

class DeletingPostsNotifier extends StateNotifier<Set<String>> {
  DeletingPostsNotifier() : super(<String>{});

  void startDeleting(String postId) {
    state = {...state, postId};
  }

  void finishDeleting(String postId) {
    state = {...state}..remove(postId);
  }

  bool isDeleting(String postId) {
    return state.contains(postId);
  }
}

final deletingPostsProvider = StateNotifierProvider<DeletingPostsNotifier, Set<String>>((ref) {
  return DeletingPostsNotifier();
});
