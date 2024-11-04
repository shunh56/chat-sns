import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/screens/tabs.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

final messagesStreamProvider = StreamProvider.family((ref, String topicId) {
  return ref
      .watch(firestoreProvider)
      .collection("topics")
      .doc(topicId)
      .collection("messages")
      .orderBy("createdAt", descending: true)
      .snapshots();
});

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topic});
  final Topic topic;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final messages = ref.watch(messagesStreamProvider(topic.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topic.title,
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: Column(
        children: [
          TopicCard(topic: topic),
          Expanded(
            child: messages.when(
              data: (messages) {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.zero,
                  itemCount: messages.docs.length,
                  itemBuilder: (context, index) {
                    final messageData = messages.docs[index].data();
                    final createdAt = messageData["createdAt"] as Timestamp;
                    final text = messageData["text"] as String;
                    final userId = messageData["userId"] as String;

                    return FutureBuilder(
                      future: ref
                          .read(allUsersNotifierProvider.notifier)
                          .getUserAccounts([userId]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final user = snapshot.data![0];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UserIcon(
                                user: user,
                                width: 48,
                              ),
                              const Gap(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.name,
                                        style: textStyle.w400(
                                          fontSize: 16,
                                          color: ThemeColor.subText,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        createdAt.xxAgo,
                                        style: textStyle.w400(
                                          color: ThemeColor.subText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    text,
                                    style: textStyle.w600(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (e, s) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ),
          BottomTextField(topic: topic),
        ],
      ),
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

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 24;

    return Container(
      width: MediaQuery.sizeOf(context).width,
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
          suffixIcon: ref.watch(inputTextProvider).isNotEmpty
              ? GestureDetector(
                  onTap: () async {
                    sendMessage(ref);
                    controller.clear();
                    ref.read(inputTextProvider.notifier).state = "";
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

  sendMessage(WidgetRef ref) {
    final Map<String, dynamic> json = {
      "id": const Uuid().v4(),
      "createdAt": Timestamp.now(),
      "userId": ref.read(authProvider).currentUser!.uid,
      "text": ref.watch(inputTextProvider),
    };
    ref
        .watch(firestoreProvider)
        .collection("topics")
        .doc(topic.id)
        .collection("messages")
        .doc(json["id"])
        .set(json);
  }
}
