// Flutter imports:
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final editNameText = StateProvider.autoDispose((ref) => "");

class EditNameScreen extends ConsumerWidget {
  const EditNameScreen({
    super.key,
    required this.username,
  });
  final String username;

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
                      "名前",
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
                      visible: ref.watch(editNameText).isNotEmpty,
                      child: Material(
                        borderRadius: BorderRadius.circular(100),
                        //color: yellow300,
                        child: InkWell(
                          splashColor: Colors.black.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100.0),
                          onTap: () {
                            final inputText = ref.read(editNameText);
                            //validate()
                            ref.read(nameTextStateProvider.notifier).state =
                                inputText;
                            ref.read(editNameText.notifier).state = "";
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
            const Gap(60),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '現在の表示名は',
                      style: TextStyle(
                        color: ThemeColor.highlight,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      username,
                      style: const TextStyle(
                        color: ThemeColor.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '表示名をカスタマイズしましょう！表示名を中国語、日本語または単国語の文字を含む名前に変更できます。ただし、60日間は再変更ができません。再変更のご要望には応じかねますので、ご注意ください！Yoloの倫理規定に反する表示名を設定した場合、アカウントは無期限停止処分の対象となる場合があります。',
                    style: TextStyle(
                      color: ThemeColor.highlight,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '名前',
                    style: TextStyle(
                      color: ThemeColor.text,
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
                      ref.read(editNameText.notifier).state = value;
                    },
                    maxLength: 32,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
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
                      hintText: '表示名を入力',
                      hintStyle: const TextStyle(
                        color: ThemeColor.highlight,
                        fontSize: 14,
                      ),
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
