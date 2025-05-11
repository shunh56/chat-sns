import 'dart:async';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/UNUSED/community_screen/model/topic.dart';
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/topics_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// メッセージの取得件数を定数で管理
const initialMessageCount = 20;
const additionalMessageCount = 15;

final scrollControllerProvider = Provider.autoDispose(
  (ref) => ScrollController(),
);

// メッセージ管理用のプロバイダー
final messageListProvider = StateNotifierProvider.family<MessageListNotifier,
    List<QueryDocumentSnapshot>, String>((ref, topicId) {
  return MessageListNotifier(ref, topicId);
});

class MessageListNotifier extends StateNotifier<List<QueryDocumentSnapshot>> {
  final Ref ref;
  final String topicId;
  StreamSubscription? _subscription;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;

  MessageListNotifier(this.ref, this.topicId) : super([]) {
    _initializeMessages();
  }

  Future<void> _initializeMessages() async {
    // 初期メッセージを取得
    final snapshot = await ref
        .read(firestoreProvider)
        .collection("topics")
        .doc(topicId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(initialMessageCount)
        .get();

    state = snapshot.docs;
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    // 新規メッセージのストリーム監視を開始
    _subscription = ref
        .read(firestoreProvider)
        .collection("topics")
        .doc(topicId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty &&
          (state.isEmpty || snapshot.docs.first.id != state.first.id)) {
        state = [...snapshot.docs, ...state];
      }
    });
  }

  Future<bool> loadMoreMessages() async {
    await Future.delayed(const Duration(milliseconds: 30));
    if (_isLoading || _lastDocument == null) return false;
    _isLoading = true;
    try {
      final snapshot = await ref
          .read(firestoreProvider)
          .collection("topics")
          .doc(topicId)
          .collection("messages")
          .orderBy("createdAt", descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(additionalMessageCount)
          .get();

      if (snapshot.docs.isNotEmpty) {
        state = [...state, ...snapshot.docs];
        _lastDocument = snapshot.docs.last;
        return true;
      } else {
        return false;
      }
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

// TopicScreen の実装を修正
class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final user =
        ref.read(allUsersNotifierProvider).asData!.value[topic.userId]!;
    final scrollController = ref.watch(scrollControllerProvider);
    scrollController.addListener(() async {
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent + 120) {
        final pos = scrollController.position.maxScrollExtent;
        bool reload = await ref
            .read(messageListProvider(topic.id).notifier)
            .loadMoreMessages();
        if (reload && scrollController.hasClients) {
          scrollController.jumpTo(pos);
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    });

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            child: Text(
              "",
              style: textStyle.appbarText(isSmall: true),
            ),
          ),
          actions: [
            if (topic.isPro)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Gap(12),
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              height: themeSize.screenHeight,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UserIcon(user: user),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topic.title,
                                      style: textStyle.w600(
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Gap(4),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${user.name}・${topic.createdAt.xxAgo}",
                                            style: textStyle.w600(
                                              fontSize: 14,
                                              color: ThemeColor.subText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Text(
                            topic.text,
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                          if (topic.tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                children: topic.tags
                                    .map(
                                      (tag) => Container(
                                        margin: const EdgeInsets.only(
                                          top: 8,
                                          right: 8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: ThemeColor.stroke,
                                        ),
                                        child: Text(
                                          tag,
                                          style: textStyle.w600(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    TopicMessages(
                      topicId: topic.id,
                    ),
                    const SizedBox(
                      height: 96,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: BottomTextField(topic: topic),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicMessages extends ConsumerStatefulWidget {
  const TopicMessages({super.key, required this.topicId});
  final String topicId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TopicMessagesState();
}

class _TopicMessagesState extends ConsumerState<TopicMessages>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final messages = ref.watch(messageListProvider(widget.topicId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            bottom: 8,
            top: 12,
          ),
          child: Text(
            "コメント",
            style: textStyle.w600(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;

            return MessageItem(
              messageData: messageData,
            );
          },
        ),
      ],
    );
  }
}

class MessageItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> messageData;

  const MessageItem({
    super.key,
    required this.messageData,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageItemState();
}

class _MessageItemState extends ConsumerState<MessageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final messageData = widget.messageData;
    final createdAt = messageData["createdAt"] as Timestamp;
    final text = messageData["text"] as String;
    final userId = messageData["userId"] as String;

    return FutureBuilder(
      future:
          ref.read(allUsersNotifierProvider.notifier).getUserAccounts([userId]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        final user = snapshot.data![0];

        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 0.4,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserIcon(
                user: user,
                width: 32,
                isCircle: true,
              ),
              const Gap(12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                        Text(
                          createdAt.xxAgo,
                          style: textStyle.w400(
                            fontSize: 13,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      text,
                      style: textStyle.w500(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final controllerProvider = Provider((ref) => TextEditingController());
final inputTextProvider = StateProvider((ref) => "");

class BottomTextField extends ConsumerWidget {
  final Topic topic;
  const BottomTextField({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final controller = ref.watch(controllerProvider);
    final scrollController = ref.watch(scrollControllerProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    return Container(
      width: MediaQuery.sizeOf(context).width,
      color: ThemeColor.background,
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: bottomPadding,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 6,
        maxLength: 400,
        style: textStyle.w600(
          fontSize: 14,
        ),
        onChanged: (value) {
          ref.read(inputTextProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: "メッセージを入力",
          filled: true,
          isDense: true,
          fillColor: ThemeColor.stroke,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20),
          ),
          hintStyle: textStyle.w400(
            fontSize: 14,
            color: ThemeColor.subText,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          counterText: "",
          suffixIcon: ref.watch(inputTextProvider).isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    await ref
                        .read(topicsUsecaseProvider)
                        .sendMessage(topic.id, ref.read(inputTextProvider));
                    controller.clear();
                    ref.read(inputTextProvider.notifier).state = "";
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(
                    Icons.send,
                    color: ThemeColor.highlight,
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
