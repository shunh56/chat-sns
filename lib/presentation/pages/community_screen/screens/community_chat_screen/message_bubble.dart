// lib/presentation/pages/community/components/chat_message_bubble.dart

import 'package:app/domain/entity/room_message.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageBubble extends ConsumerWidget {
  final Message message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FutureBuilder(
        future: ref
            .read(allUsersNotifierProvider.notifier)
            .getUserAccounts([message.userId]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ],
            );
          }

          final user = snapshot.data![0];
          return Row(
            children: [
              UserIcon(
                user: user,
                width: 36,
                isCircle: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(message.createdAt),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildMessageContent(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(message.text);
      case MessageType.image:
        if (message.imageUrls == null || message.imageUrls!.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildImageContent();
      case MessageType.voice:
        return _buildVoiceContent();
      default:
        return Text(message.text);
    }
  }

  Widget _buildImageContent() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: message.imageUrls!.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 120,
              width: 120 / (message.aspectRatios?[index] ?? 1.0),
              child: CachedImage.postImage(
                message.imageUrls![index],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoiceContent() {
    // TODO: Implement voice message UI
    return const SizedBox.shrink();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();

    if (now.difference(date).inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day} ${date.hour}:${date.minute}';
    }
  }
}
