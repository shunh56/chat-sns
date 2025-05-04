// lib/presentation/pages/community/screens/community_chat_screen.dart

import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/chat_message_input.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/components.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/header.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/message_list.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityChatScreen extends ConsumerStatefulWidget {
  final Community community;

  const CommunityChatScreen({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityChatScreen> createState() =>
      _CommunityChatScreenState();
}

class _CommunityChatScreenState extends ConsumerState<CommunityChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CommunityChatHeader(community: widget.community),
          Expanded(
            child: ChatMessageList(
              communityId: widget.community.id,
              scrollController: _scrollController,
            ),
          ),
          ChatMessageInput(
            communityId: widget.community.id,
            controller: _messageController,
            onSendMessage: _handleSendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.people_outline),
          onPressed: () => _showMembersList(),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => _showCommunityOptions(),
        ),
      ],
    );
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      await ref.read(communityUsecaseProvider).sendMessage(
            widget.community.id,
            message,
          );
      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCommunityOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommunityOptionsSheet(community: widget.community),
    );
  }

  void _showMembersList() {
    // TODO: Implement members list view
  }
}
