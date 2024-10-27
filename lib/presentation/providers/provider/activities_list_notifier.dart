// Package imports:
import 'dart:async';

import 'package:app/domain/entity/activities.dart';
import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/activities_usecase.dart';
import 'package:app/usecase/block_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

final activitiesListNotifierProvider = StateNotifierProvider.autoDispose<
    ActivitiesListNotifier, AsyncValue<List<Activity>>>((ref) {
  return ActivitiesListNotifier(
    ref,
    ref.watch(activitiesUsecaseProvider),
  )..initialize();
});

/// State
class ActivitiesListNotifier extends StateNotifier<AsyncValue<List<Activity>>> {
  ActivitiesListNotifier(this.ref, this.usecase)
      : super(const AsyncValue<List<Activity>>.loading());

  final Ref ref;
  final ActivitiesUsecase usecase;

  Future<void> initialize() async {
    final list = await usecase.getRecentActivities();
    state = AsyncValue.data(list);
    final posts = list
        .where((e) =>
            e.actionType == ActionType.postLike ||
            e.actionType == ActionType.postComment)
        .map((e) => e.post as Post)
        .toList();
    final currentStatusPosts = list
        .where((e) => e.actionType == ActionType.currentStatusPostLike)
        .map((e) => e.post as CurrentStatusPost)
        .toList();

    ref.read(allPostsNotifierProvider.notifier).addPosts(posts);
    ref
        .read(allCurrentStatusPostsNotifierProvider.notifier)
        .addPosts(currentStatusPosts);
  }
}
