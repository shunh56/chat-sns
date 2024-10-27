import 'dart:async';

import 'package:app/datasource/direct_message_datasource.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/posts/all_current_status_posts.dart';
import 'package:app/repository/direct_message_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageListNotifierProvider = StateNotifierProvider.autoDispose
    .family<MessageListNotifier, AsyncValue<List<CoreMessage>>, String>(
  (ref, userId) => MessageListNotifier(
    ref,
    ref.watch(dmRepositoryProvider),
    userId,
  )..init(),
);

class MessageListNotifier extends StateNotifier<AsyncValue<List<CoreMessage>>> {
  MessageListNotifier(
    this._ref,
    this._repository,
    this.userId,
  ) : super(const AsyncValue.loading());

  final Ref _ref;
  final DirectMessageRepository _repository;
  final String userId;

  StreamSubscription<List<CoreMessage>>? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  init() async {
    List<CoreMessage> cache = [];
    String id = DMKeyConverter.getKey(
        _ref.watch(authProvider).currentUser!.uid, userId);
    final list = await _repository.getMessages(id);
    cache = list;
    final currentStatusPosts = List<CurrentStatusMessage>.from(
        list.where((e) => e is CurrentStatusMessage));
    await _ref
        .read(allCurrentStatusPostsNotifierProvider.notifier)
        .getPosts(currentStatusPosts.map((e) => e.postId).toList());
    state = AsyncValue.data(cache);
    final stream = _repository.streamMessages(id);
    _subscription = stream.listen((event) async {
      final currentStatusPosts = List<CurrentStatusMessage>.from(
          list.where((e) => e is CurrentStatusMessage));
      await _ref
          .read(allCurrentStatusPostsNotifierProvider.notifier)
          .getPosts(currentStatusPosts.map((e) => e.postId).toList());
      if (mounted) {
        if (event.isNotEmpty) {
          if (cache.isEmpty) {
            cache = [...event];
            state = AsyncValue.data(cache);
          } else {
            if (event[0].id != cache[0].id) {
              cache = [event[0], ...cache];
              state = AsyncValue.data(cache);
            }
          }
          if (event[0].senderId != _ref.watch(authProvider).currentUser!.uid) {
            _ref.read(dmDatasourceProvider).readOverview(userId);
          }
        }
      }
    });
  }
}
