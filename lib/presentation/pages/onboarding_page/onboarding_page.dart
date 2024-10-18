import 'package:app/core/extenstions/string_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/button/basic.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/components/widgets/fade_transition_widget.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/invite_code_usecase.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:gap/gap.dart';

final usernameProvider = StateProvider<String>((ref) => '');
final nameProvider = StateProvider<String>((ref) => '');
final selectedOtherIdsProvider = StateProvider<List<String>>((ref) => []);
final doingProvider = StateProvider<String>((ref) => '');

final imageProvider = StateProvider<File?>((ref) => null);
//final genderProvider = StateProvider<Gender>((ref) => Gender.male);

const ONBOARDING_LENGTH = 5;
final pageIndex = StateProvider((ref) => 0);
final pageController = Provider((ref) => PageController(initialPage: 0));

final creatingProcessProvider = StateProvider.autoDispose((ref) => false);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AnimatedContainer(
                    margin: EdgeInsets.only(
                      right: (themeSize.screenWidth -
                              2 * themeSize.horizontalPadding) /
                          4 *
                          (ONBOARDING_LENGTH - ref.watch(pageIndex)),
                    ),
                    height: 6,
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: ref.watch(pageController),
                    children: [
                      const InputNameScreen(),
                      const InputUsernameScreen(),
                      const InputImageUrlScreen(),
                      const AddOtherFriendsScreen(),
                      const InputDoingScreen(),
                      Container(),
                    ],
                    onPageChanged: (value) =>
                        ref.read(pageIndex.notifier).state = value,
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: ref.watch(creatingProcessProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Visibility(
              visible: ref.watch(creatingProcessProvider),
              child: ShaderWidget(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "アカウント作成中",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(12),
                      CircularProgressIndicator(
                        strokeWidth: 1.2,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//01
class InputNameScreen extends ConsumerWidget {
  const InputNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final name = ref.watch(nameProvider);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(themeSize.screenHeight * 0.2),
            Text(
              "あなたの名前は？",
              style: textStyle.w600(
                fontSize: 20,
              ),
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            TextFormField(
              initialValue: name,
              autofocus: true,
              textAlign: TextAlign.center,
              cursorColor: ThemeColor.text,
              style: textStyle.w600(
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(nameProvider.notifier).state = value;
              },
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
              child: BasicButton(
                text: "次へ",
                ontap: name.isEmpty
                    ? null
                    : () async {
                        ref.read(pageController).animateToPage(1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//02
class InputUsernameScreen extends ConsumerWidget {
  const InputUsernameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final username = ref.watch(usernameProvider);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(themeSize.screenHeight * 0.2),
            Text(
              "ユーザー名を入力",
              style: textStyle.w600(
                fontSize: 20,
              ),
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            TextFormField(
              initialValue: username,
              autofocus: true,
              textAlign: TextAlign.center,
              cursorColor: ThemeColor.text,
              style: textStyle.w600(
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(usernameProvider.notifier).state = value;
              },
            ),
            SizedBox(
              height: themeSize.screenHeight * 0.05,
              child: (!username.isUsername && username.usernameError != null)
                  ? Text(
                      username.usernameError!,
                      style: textStyle.w600(
                        color: ThemeColor.error,
                      ),
                    )
                  : null,
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
              child: BasicButton(
                text: "次へ",
                ontap: !username.isUsername
                    ? null
                    : () async {
                        final alreadyUsed = await ref
                            .read(userUsecaseProvider)
                            .checkUsername(username);
                        if (alreadyUsed) {
                          showMessage("そのユーザー名は既に利用されています。");
                        } else {
                          primaryFocus?.unfocus();
                          ref.read(pageController).animateToPage(2,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//03
class InputImageUrlScreen extends ConsumerWidget {
  const InputImageUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final image = ref.watch(imageProvider);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(themeSize.screenHeight * 0.2),
            Text(
              "プロフィール画像をアップロード",
              style: textStyle.w600(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 48 + themeSize.screenHeight * 0.1,
              child: Center(
                child: (image != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100 * 2 / 9),
                        child: Image.file(
                          image,
                          height: 100,
                          width: 100,
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final pickedFile = await ref
                              .read(imageProcessorNotifierProvider)
                              .getIconImage();
                          if (pickedFile != null) {
                            ref.read(imageProvider.notifier).state =
                                File(pickedFile.path);
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: ThemeColor.accent,
                            borderRadius: BorderRadius.circular(100 * 2 / 9),
                            border: Border.all(
                              color: ThemeColor.stroke,
                              width: 0.4,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 48,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
              child: BasicButton(
                text: image != null ? "次へ" : "スキップ",
                ontap: () {
                  ref.read(pageController).animateToPage(3,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
                enableSkip: image == null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//04
//AddOtherFriendsScreen
class AddOtherFriendsScreen extends ConsumerWidget {
  const AddOtherFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final usedCode =
        ref.read(myAccountNotifierProvider).asData!.value.usedCode!;
    final selectedOtherIds = ref.watch(selectedOtherIdsProvider);
    getUser() async {
      final code =
          await ref.read(inviteCodeUsecaseProvider).getInviteCode(usedCode);
      final user = (await ref
              .read(allUsersNotifierProvider.notifier)
              .getUserAccounts([code.userId]))
          .first;
      final otherUsers = await ref
          .read(friendIdListNotifierProvider.notifier)
          .getFriends(user.userId);
      return [user, ...otherUsers];
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(themeSize.screenHeight * 0.05),
            Text(
              "あなたの友達をタップ",
              style: textStyle.w600(
                fontSize: 20,
              ),
            ),
            const Gap(12),
            Expanded(
              child: FutureBuilder(
                future: getUser(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final users = snapshot.data!;
                  final user = users[0];
                  final others = users.sublist(1, users.length);
                  return Column(
                    children: [
                      Center(
                        child: UserIcon.tileIcon(user, width: 108),
                      ),
                      const Gap(8),
                      Text(
                        "${user.name}さんの友達です",
                        style: textStyle.w600(
                          fontSize: 16,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: others.length,
                          padding: EdgeInsets.symmetric(
                            horizontal: themeSize.horizontalPaddingLarge,
                          ),
                          itemBuilder: (context, index) {
                            final item = others[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  UserIcon.tileIcon(item, width: 60),
                                  const Gap(12),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeColor.text,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  selectedOtherIds.contains(item.userId)
                                      ? GestureDetector(
                                          onTap: () {
                                            final list = List<String>.from(
                                                selectedOtherIds);
                                            list.removeWhere(
                                                (id) => id == item.userId);
                                            ref
                                                .read(selectedOtherIdsProvider
                                                    .notifier)
                                                .state = list;
                                          },
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.green,
                                            child: Icon(
                                              Icons.check,
                                              color: ThemeColor.white,
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            final list = List<String>.from(
                                                selectedOtherIds);
                                            list.add(item.userId);
                                            ref
                                                .read(selectedOtherIdsProvider
                                                    .notifier)
                                                .state = list;
                                          },
                                          child: const CircleAvatar(
                                            backgroundColor: ThemeColor.stroke,
                                            child: Icon(
                                              Icons.check,
                                              color: ThemeColor.white,
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            const Gap(12),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
              child: BasicButton(
                text: selectedOtherIds.isNotEmpty ? "次へ" : "スキップ",
                ontap: () {
                  ref.read(pageController).animateToPage(4,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
                enableSkip: selectedOtherIds.isEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//05
class InputDoingScreen extends ConsumerWidget {
  const InputDoingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final doing = ref.watch(doingProvider);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            FadeTransitionWidget(
              child: SizedBox(
                height: themeSize.screenHeight * 0.15,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "これで最後！",
                    style: textStyle.w600(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            Text(
              "今何してる？",
              style: textStyle.w600(
                fontSize: 20,
              ),
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            TextFormField(
              initialValue: doing,
              autofocus: true,
              textAlign: TextAlign.center,
              cursorColor: ThemeColor.text,
              style: textStyle.w600(
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                ref.read(doingProvider.notifier).state = value;
              },
            ),
            Gap(
              themeSize.screenHeight * 0.05,
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
              child: BasicButton(
                text: "アカウント作成",
                ontap: doing.isEmpty
                    ? null
                    : () async {
                        primaryFocus?.unfocus();
                        final username = ref.read(usernameProvider);
                        final name = ref.read(nameProvider);
                        final image = ref.read(imageProvider);
                        final doing = ref.read(doingProvider);
                        debugPrint("username : $username");
                        debugPrint("name : $name");
                        debugPrint("image : ${image?.path}");
                        debugPrint("doing : $doing");
                        ref.read(pageController).animateToPage(4,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut);

                        if (username.isUsername &&
                            name.isNotEmpty &&
                            doing.isNotEmpty) {
                          final alreadyUsed = await ref
                              .read(userUsecaseProvider)
                              .checkUsername(username);
                          if (alreadyUsed) {
                            showMessage("そのユーザー名はすでに利用されています。");
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            ref.read(pageController).animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                            return;
                          }
                          try {
                            await ref
                                .read(myAccountNotifierProvider.notifier)
                                .createUser(username, name, image, doing);

                            ref.read(creatingProcessProvider.notifier).state =
                                false;
                            showMessage('アカウントが作成されました');
                          } catch (e) {
                            ref.read(creatingProcessProvider.notifier).state =
                                false;
                            showErrorSnackbar(error: e);
                          }
                        } else {
                          showMessage('すべての項目を入力してください');
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
