// lib/presentation/pages/community/components/chat_message_input.dart

import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatMessageInput extends HookConsumerWidget {
  final String communityId;
  final TextEditingController controller;
  final VoidCallback onSendMessage;

  const ChatMessageInput({
    super.key,
    required this.communityId,
    required this.controller,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () async {
                final image = await ref
                    .read(imageProcessorNotifierProvider)
                    .getPostImage();

                try {
                  isLoading.value = true;
                  if (image != null) {
                    await ref.read(communityUsecaseProvider).sendImages(
                      communityId,
                      [image],
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send image: $e')),
                  );
                } finally {
                  isLoading.value = false;
                }
              },
              color: Colors.grey[400],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3B4E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'メッセージを入力...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: onSendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
