// UI実装例
import 'package:app/domain/entity/room_message.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/providers/image/image_processor.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/room_message_notifier.dart';
import 'package:app/domain/usecases/room_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class RoomScreen extends HookConsumerWidget {
  final String roomId;
  final ScrollController scrollController;

  const RoomScreen({
    super.key,
    required this.roomId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesState = ref.watch(chatMessagesProvider(roomId));

    // スクロール監視
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          ref.read(chatMessagesProvider(roomId).notifier).loadMoreMessages();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  reverse: true, // 新しいメッセージを下に表示
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      message: message,
                      isMyMessage:
                          roomId == ref.read(authProvider).currentUser!.uid,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error, $stack'),
              ),
            ),
          ),
          if (roomId == ref.read(authProvider).currentUser!.uid)
            const MessageInputBar(),
        ],
      ),
    );
  }
}

class MessageBubble extends HookConsumerWidget {
  final Message message;
  final bool isMyMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            const CircleAvatar(
              radius: 16,
              child: Text("USERID"),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isMyMessage
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMyMessage ? const Radius.circular(0) : null,
                    bottomLeft: !isMyMessage ? const Radius.circular(0) : null,
                  ),
                ),
                child:
                    _MessageContent(message: message, isMyMessage: isMyMessage),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(message.createdAt.toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isMyMessage) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 16, color: Colors.blue),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const _MessageContent({
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMyMessage ? Colors.white : Colors.black,
            ),
          ),
        );

      case MessageType.image:
        return GestureDetector(
          onTap: () {
            // 画像の詳細表示
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ImageViewerScreen(imageUrl: message.imageUrls![0]),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedImage.userImage(message.imageUrls![0], 200),
          ),
        );

      case MessageType.voice:
        return _VoiceMessageContent(
          message: message,
          isMyMessage: isMyMessage,
        );
    }
  }
}

class _VoiceMessageContent extends HookConsumerWidget {
  final Message message;
  final bool isMyMessage;

  const _VoiceMessageContent({
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = useState(false);
    final progress = useState(0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying.value ? Icons.pause : Icons.play_arrow,
              color: isMyMessage ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // 音声再生の処理
              isPlaying.value = !isPlaying.value;
            },
          ),
          Container(
            width: 100,
            height: 2,
            color: isMyMessage
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth * progress.value,
                  color: isMyMessage ? Colors.white : Colors.black,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${message.duration ?? 0}s',
            style: TextStyle(
              color: isMyMessage ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class MessageInputBar extends HookConsumerWidget {
  const MessageInputBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final focusNode = useFocusNode();
    final isLoading = useState(false);

    Future<void> sendMessage() async {
      if (messageController.text.trim().isEmpty) return;

      try {
        isLoading.value = true;
        await ref
            .read(roomUsecaseProvider)
            .sendMessage(messageController.text.trim());

        messageController.clear();
        focusNode.unfocus();
      } catch (e) {
        showErrorSnackbar(error: e);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> sendImage() async {
      final image =
          await ref.read(imageProcessorNotifierProvider).getPostImage();

      try {
        isLoading.value = true;
        if (image != null) {
          await ref
              .read(roomUsecaseProvider)
              .sendImages(ref.read(authProvider).currentUser!.uid, [image]);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: isLoading.value ? null : sendImage,
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendMessage(),
                enabled: !isLoading.value,
              ),
            ),
            IconButton(
              icon: isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: isLoading.value ? null : sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
