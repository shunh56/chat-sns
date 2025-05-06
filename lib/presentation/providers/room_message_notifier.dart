import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/datasource/room_datasource.dart';
import 'package:app/domain/entity/room_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// メッセージの状態を管理するNotifier

// Providerの定義
final chatMessagesProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesNotifier, AsyncValue<List<Message>>, String>(
  (ref, userId) => ChatMessagesNotifier(
    ref: ref,
    userId: userId,
  ).._initialize(),
);

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  ChatMessagesNotifier({
    required this.ref,
    required this.userId,
  }) : super(const AsyncValue.loading());

  final Ref ref;
  final String userId;

  Timestamp? lastMessageTimestamp;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  Future<void> _initialize() async {
    try {
      DebugPrint("INIT");
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
    final snapshot =
        await ref.read(roomDatasourceProvider).fetchMessages(userId);
    if (snapshot.docs.isNotEmpty) {
      final lastMessage = Message.fromJson(snapshot.docs.last.data());
      lastMessageTimestamp = lastMessage.createdAt;
    }
    DebugPrint("Snapshots : ${snapshot.docs.length}");
    return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
  }

  void _subscribeToLatestMessage() {
    _subscription = ref
        .read(roomDatasourceProvider)
        .streamMessages(userId)
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final latestMessage = Message.fromJson(snapshot.docs.first.data());
      final currentMessages = state.value ?? [];

      // 重複を避けて最新メッセージを追加
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
      final snapshot = await ref
          .read(roomDatasourceProvider)
          .fetchMessages(userId, lastMessageTimestamp: lastMessageTimestamp);

      if (snapshot.docs.isNotEmpty) {
        final lastMessage = Message.fromJson(snapshot.docs.last.data());
        lastMessageTimestamp = lastMessage.createdAt;
        final newMessages =
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();

        final currentMessages = state.value ?? [];
        state = AsyncValue.data([...currentMessages, ...newMessages]);
      }
    } catch (e) {
      // エラーの場合でも現在の状態は保持
      DebugPrint('Error loading more messages: $e');
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
