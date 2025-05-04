import 'dart:async';

import 'package:app/data/datasource/direct_message_datasource.dart';
import 'package:app/domain/entity/message.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/data/repository/direct_message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  MessageListNotifier(this._ref, this._repository, this.userId)
      : super(const AsyncValue.loading());

  final Ref _ref;
  final DirectMessageRepository _repository;
  final String userId;
  Timestamp? lastTimeStamp;
  bool hasMore = true;
  bool _isLoading = false;

  StreamSubscription<List<CoreMessage>>? _subscription;
  List<CoreMessage> _messages = [];

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    try {
      String id = DMKeyConverter.getKey(
          _ref.watch(authProvider).currentUser!.uid, userId);

      // 初期メッセージの取得
      await _loadMessages(id);

      // リアルタイム更新のセットアップ
      final stream = _repository.streamMessages(id);
      _subscription = stream.listen((event) async {
        if (event.isNotEmpty && mounted) {
          _handleNewMessage(event, id);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;

    try {
      _isLoading = true;
      String id = DMKeyConverter.getKey(
          _ref.watch(authProvider).currentUser!.uid, userId);

      final newMessages = await _repository.getMessages(
        id,
        lastTimestamp: lastTimeStamp,
      );

      if (newMessages.isEmpty) {
        hasMore = false;
      } else {
        _messages.addAll(newMessages);
        lastTimeStamp = newMessages.last.createdAt;
        state = AsyncValue.data(_messages);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadMessages(String id) async {
    final list = await _repository.getMessages(id);
    if (list.isNotEmpty) {
      lastTimeStamp = list.last.createdAt;
    }
    _messages = list;
    hasMore = list.length >= 20;

    /*final currentStatusPosts =
        List<CurrentStatusMessage>.from(list.whereType<CurrentStatusMessage>());
    await _ref
        .read(allCurrentStatusPostsNotifierProvider.notifier)
        .getPosts(currentStatusPosts.map((e) => e.postId).toList()); */

    state = AsyncValue.data(_messages);
  }

  void _handleNewMessage(List<CoreMessage> event, String id) {
    if (_messages.isEmpty) {
      _messages = [...event];
    } else if (event[0].id != _messages[0].id) {
      _messages = [event[0], ..._messages];
    }
    state = AsyncValue.data(_messages);

    if (event[0].senderId != _ref.watch(authProvider).currentUser!.uid) {
      _ref.read(dmDatasourceProvider).readOverview(userId);
    }
  }
}
