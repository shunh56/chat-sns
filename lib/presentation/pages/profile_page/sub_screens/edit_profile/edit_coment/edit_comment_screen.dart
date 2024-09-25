/*// Flutter imports:
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';


final editCommentText = StateProvider.autoDispose((ref) => "");

class EditCommentScreen extends ConsumerWidget {
  const EditCommentScreen({
    super.key,
    required this.aboutMe,
  });
  final String aboutMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(MediaQuery.of(context).viewPadding.top),
            SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 12,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "自己紹介",
                      style: TextStyle(
                        color: ThemeColor.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    child: Visibility(
                      visible: ref.watch(editCommentText).isNotEmpty,
                      child: Material(
                        borderRadius: BorderRadius.circular(100),
                       // color: yellow300,
                        child: InkWell(
                          splashColor: Colors.black.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100.0),
                          onTap: () {
                            final inputText = ref.read(editCommentText);
                            //validate()
                            ref.read(commentTextStateProvider.notifier).state =
                                inputText;
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              "保存",
                             
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Gap(24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'あなたの個性を輝かせるプロフィールを作成しましょう。ここでは、あなた自身について自由に紹介してください。趣味や特技、好きなこと、これまでの経験など、何でも結構です。自己紹介を通じて、他のユーザーと繋がりを持ち、共通の興味を見つけるチャンスです。',
                    style: TextStyle(
                      color: ThemeColor.highlight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '自己紹介',
                    style: TextStyle(
                      color: ThemeColor.highlight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  TextField(
                    style: const TextStyle(
                      color: ThemeColor.text,
                      fontSize: 14,
                    ),
                    onChanged: (value) {
                      ref.read(editCommentText.notifier).state = value;
                    },
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: 10,
                    maxLength: 200,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.pink),
                      ),
                      disabledBorder: const OutlineInputBorder(),
                      hintText: '自己紹介を編集',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      counterStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      errorStyle: const TextStyle(color: Colors.pink),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */