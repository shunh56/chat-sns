// Flutter imports:
import 'dart:io';

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_profile/edit_coment/edit_comment_screen.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_profile/edit_name/edit_name_screen.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final thumbnailImageStateProvider =
    StateProvider.autoDispose<File?>((ref) => null);
final iconImageStateProvider = StateProvider.autoDispose<File?>((ref) => null);
final nameTextStateProvider = StateProvider.autoDispose<String>((ref) => "");
final commentTextStateProvider = StateProvider.autoDispose<String>((ref) => "");
final checkStatus = StateProvider.autoDispose((ref) => false);
final updatingProcessProvider = StateProvider.autoDispose((ref) => false);

checkStates(WidgetRef ref, UserAccount user) async {
  bool status = false;
  await Future.delayed(const Duration(milliseconds: 50));
  if (ref.read(thumbnailImageStateProvider) != null ||
      ref.read(iconImageStateProvider) != null) {
    status = true;
  }

  if (ref.read(nameTextStateProvider).isNotEmpty &&
      ref.read(nameTextStateProvider) != user.username) {
    status = true;
  }
  if (ref.read(commentTextStateProvider).isNotEmpty &&
      ref.read(commentTextStateProvider) != user.aboutMe) {
    status = true;
  }

  ref.read(checkStatus.notifier).state = status;
}

updateProfile(WidgetRef ref) async {
  ref.read(checkStatus.notifier).state = false;
  ref.read(updatingProcessProvider.notifier).state = true;
  File? thubnailFile = ref.read(thumbnailImageStateProvider);
  File? iconFile = ref.read(iconImageStateProvider);
  String? nameText = ref.read(nameTextStateProvider).isNotEmpty
      ? ref.read(nameTextStateProvider)
      : null;
  String? commentText = ref.read(commentTextStateProvider).isNotEmpty
      ? ref.read(commentTextStateProvider)
      : null;

  /*await ref.read(myAccountNotifierProvider.notifier).updateProfile(
        thubnailFile,
        iconFile,
        nameText,
        commentText,
      ); */
}

bool isUploading = false;

class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({
    super.key,
    required this.user,
  });
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    checkStates(ref, user);
    const imageHeight = 80.0;
    const imagePadding = 2.0;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          "プロフィールの編集",
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColor.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        child: Visibility(
                          visible: ref.watch(checkStatus),
                          child: Material(
                            borderRadius: BorderRadius.circular(100),
                            child: InkWell(
                              splashColor: Colors.black.withOpacity(0.3),
                              //highlightColor: white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100.0),
                              onTap: () async {
                                await updateProfile(ref);
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
                isUploading
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.black.withOpacity(0.1),
                        minHeight: 1.6,
                      )
                    : const SizedBox(
                        height: 1.6,
                      ),
                const Gap(12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "画像",
                        style: TextStyle(
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeColor.text.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ref.watch(iconImageStateProvider) == null
                                      ? Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                imageHeight / 3 + imagePadding),
                                            border: Border.all(
                                                color: ThemeColor.background,
                                                width: imagePadding),
                                          ),
                                          child: CachedImage.userIcon(
                                            user.imageUrl,
                                            ref
                                                    .watch(
                                                        nameTextStateProvider)
                                                    .isNotEmpty
                                                ? ref
                                                    .read(nameTextStateProvider)
                                                : user.username,
                                            imageHeight / 2,
                                          ),
                                        )
                                      : Container(
                                          width: imageHeight,
                                          height: imageHeight,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                imageHeight / 3 + imagePadding),
                                            border: Border.all(
                                                color: ThemeColor.background,
                                                width: imagePadding),
                                            image: DecorationImage(
                                              image: FileImage(
                                                ref.watch(
                                                    iconImageStateProvider)!,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              const Gap(4),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  final imageFile = await ref
                                      .read(imageProcessorNotifierProvider)
                                      .getIconImage();
                                  ref
                                      .read(iconImageStateProvider.notifier)
                                      .state = imageFile;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "プロフィール画像",
                                              style: TextStyle(
                                                color: ThemeColor.text,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "10MB未満のJPEG、PNG、GIF",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: ThemeColor.highlight,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Gap(4),
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.5),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(
                                  height: 1.4,
                                  color: ThemeColor.text.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "概要",
                        style: TextStyle(
                          color: ThemeColor.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeColor.text.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditNameScreen(
                                        username: ref
                                                .watch(nameTextStateProvider)
                                                .isNotEmpty
                                            ? ref.read(nameTextStateProvider)
                                            : user.username,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "名前",
                                              style: TextStyle(
                                                color: ThemeColor.text,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Gap(4),
                                            Text(
                                              ref
                                                      .watch(
                                                          nameTextStateProvider)
                                                      .isNotEmpty
                                                  ? ref.read(
                                                      nameTextStateProvider)
                                                  : user.username,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: ThemeColor.highlight,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Gap(4),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.5),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Divider(
                                  height: 1.4,
                                  color: ThemeColor.text.withOpacity(0.2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "ユーザー名",
                                            style: TextStyle(
                                              color: ThemeColor.text,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Gap(4),
                                          Text(
                                            "@${user.username}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: ThemeColor.highlight,
                                              fontSize: 14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const Gap(4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.5),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Divider(
                                  height: 1.4,
                                  color: ThemeColor.text.withOpacity(0.2),
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditCommentScreen(
                                          aboutMe: ref
                                                  .watch(
                                                      commentTextStateProvider)
                                                  .isNotEmpty
                                              ? ref.read(
                                                  commentTextStateProvider)
                                              : user.aboutMe ?? ""),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "自己紹介",
                                              style: TextStyle(
                                                color: ThemeColor.text,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Gap(4),
                                            Text(
                                              ref
                                                      .watch(
                                                          commentTextStateProvider)
                                                      .isNotEmpty
                                                  ? ref.read(
                                                      commentTextStateProvider)
                                                  : user.aboutMe ??
                                                      "自己紹介のメッセージを設定しよう",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: ThemeColor.highlight,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Gap(4),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.5),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                /*      //name
                  Container(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: 0.4,
                          color: black.withOpacity(0.3),
                        ),
                        bottom: BorderSide(
                          width: 0.4,
                          color: black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            "名前",
                            style: CustomTextStyle.jpText(
                              10,
                              black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            maxLength: 24,
                            initialValue: nameEditor,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                ref.watch(editNameProvider.notifier).state = val;
                              } else {
                                ref.watch(editNameProvider.notifier).state = null;
                              }
                            },
                            style: CustomTextStyle.jpText(
                              12,
                              black,
                              FontWeight.w400,
                            ),
                            cursorColor: yellow300,
                            decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              hintText: "名前を入力してください",
                              hintStyle: CustomTextStyle.jpText(
                                12,
                                black.withOpacity(0.3),
                                FontWeight.w400,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  //username
                  Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.4,
                          color: black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            "ユーザー名",
                            style: CustomTextStyle.jpText(
                              10,
                              black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showMessage("ユーザー名は変更できません。");
                          },
                          child: Text(
                            "@${user.username}",
                            style: CustomTextStyle.jpText(
                              12,
                              black,
                              FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  //comment
                  Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      left: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.4,
                          color: black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            "自己紹介",
                            style: CustomTextStyle.jpText(
                              10,
                              black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            maxLength: 200,
                            minLines: 1,
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                            initialValue: commentEditor,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                ref.watch(editCommentProvider.notifier).state = val;
                              } else {
                                ref.watch(editCommentProvider.notifier).state =
                                    null;
                              }
                            },
                            style: CustomTextStyle.jpText(
                              12,
                              black,
                              FontWeight.w400,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'^\n|\n{3,}'))
                            ],
                            //textInputAction: TextInputAction.done,
                            //cursorColor: yellow300,
                            //cursorHeight: 12,
                            decoration: InputDecoration(
                              hintText: "自己紹介をしよう",
                              hintStyle: CustomTextStyle.jpText(
                                12,
                                black.withOpacity(0.3),
                                FontWeight.w400,
                              ),
                              counterText: "",
                              counterStyle: CustomTextStyle.enText(
                                10,
                                yellow300,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          
                  //personalities
                  Container(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      left: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.4,
                          color: black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            "自分の性格",
                            style: CustomTextStyle.jpText(
                              10,
                              black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Material(
                          color: yellow300,
                          borderRadius: BorderRadius.circular(100),
                          child: InkWell(
                            splashColor: black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              showTags(context, ref);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_outlined,
                                size: 14,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              for (String tag in user.personalities)
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 4,
                                    right: 4,
                                    bottom: 8,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: () {
                                      user.personalities
                                          .removeWhere((element) => element == tag);
                                      notifier.updateFields(
                                          personalities: user.personalities);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "#${convertPersonalityMap[tag]}",
                                        style: CustomTextStyle.jpText(
                                          12,
                                          black,
                                          FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                */
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: ref.watch(updatingProcessProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Visibility(
              visible: ref.watch(updatingProcessProvider),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
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
                          "プロフィールを更新中",
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
          ),
        ],
      ),
    );
  }
}
