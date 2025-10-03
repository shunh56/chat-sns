import 'dart:async';

import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepliesNotifierProvider = StateNotifierProvider.autoDispose
    .family<PostRepliesNotifier, AsyncValue<List<Reply>>, String>(
  (ref, postId) => PostRepliesNotifier(
    ref,
    ref.watch(postUsecaseProvider),
    postId,
  )..init(),
);

class PostRepliesNotifier extends StateNotifier<AsyncValue<List<Reply>>> {
  PostRepliesNotifier(
    this._ref,
    this._usecase,
    this.postId,
  ) : super(const AsyncValue.loading());

  final Ref _ref;
  final PostUsecase _usecase;
  final String postId;

  StreamSubscription<List<Reply>>? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  init() async {
    final stream = _usecase.streamPostReplies(postId);

    _subscription = stream.listen((event) async {
      await _ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts(event.map((reply) => reply.userId).toList());
      if (mounted) {
        state = AsyncValue.data(event);
      }
    });
  }
}
