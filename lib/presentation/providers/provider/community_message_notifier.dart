import 'dart:async';

import 'package:app/domain/entity/room_message.dart';
import 'package:app/usecase/comunity_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityMessagesProvider = StateNotifierProvider.autoDispose
    .family<CommunityMessagesNotifier, AsyncValue<List<Message>>, String>(
  (ref, communityId) => CommunityMessagesNotifier(
    ref: ref,
    communityId: communityId,
    usecase: ref.read(communityUsecaseProvider),
  ).._initialize(),
);

class CommunityMessagesNotifier
    extends StateNotifier<AsyncValue<List<Message>>> {
  CommunityMessagesNotifier({
    required this.ref,
    required this.communityId,
    required this.usecase,
  }) : super(const AsyncValue.loading());

  final Ref ref;
  final String communityId;
  final CommunityUsecase usecase;

  Timestamp? lastMessageTimestamp;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  Future<void> _initialize() async {
    try {
      // 初期データの取得
      final initialMessages = await _fetchInitialMessages();
      state = AsyncValue.data(initialMessages);

      // 最新メッセージのストリーミングを開始
      _subscribeToLatestMessage();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<Message>> _fetchInitialMessages() async {
    final messages = await usecase.getMessages(communityId);
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      lastMessageTimestamp = lastMessage.createdAt;
    }
    return messages;
  }

  void _subscribeToLatestMessage() {
    _subscription = usecase.streamMessages(communityId).listen((snapshot) {
      if (snapshot.isEmpty) return;
      final latestMessage = snapshot.first;
      final currentMessages = state.value ?? [];
      if (currentMessages.isEmpty ||
          currentMessages.first.id != latestMessage.id) {
        state = AsyncValue.data([latestMessage, ...currentMessages]);
      }
    });
  }

  Future<void> loadMoreMessages() async {
    if (_isLoading || lastMessageTimestamp == null) return;

    try {
      _isLoading = true;
      final newMessages = await usecase.getMessages(communityId,
          lastMessageTimestamp: lastMessageTimestamp);
      if (newMessages.isNotEmpty) {
        final lastMessage = newMessages.last;
        lastMessageTimestamp = lastMessage.createdAt;
        final currentMessages = state.value ?? [];
        state = AsyncValue.data([...currentMessages, ...newMessages]);
      }
    } catch (e) {
      // エラーの場合でも現在の状態は保持
      print('Error loading more messages: $e');
    } finally {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
