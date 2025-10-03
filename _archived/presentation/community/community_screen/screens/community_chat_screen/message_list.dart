// lib/presentation/pages/community/components/chat_message_list.dart

import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/empty_message.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/error_state.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/message_bubble.dart';
import 'package:app/presentation/providers/community_message_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessageList extends ConsumerWidget {
  final String communityId;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.communityId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(communityMessagesProvider(communityId));

    return messagesState.when(
      data: (messages) {
        if (messages.isEmpty) return const EmptyMessageState();

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView.builder(
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            itemCount: messages.length,
            itemBuilder: (context, index) => ChatMessageBubble(
              message: messages[index],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState(error: error.toString()),
    );
  }
}
