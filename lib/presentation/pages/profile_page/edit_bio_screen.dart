import 'dart:io';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/usecase/image_uploader_usecase.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gap/gap.dart';

final iconImageStateProvider = StateProvider.autoDispose<File?>((ref) => null);
final imageUploadingProvider = StateProvider.autoDispose((ref) => false);

class EditBioScreen extends ConsumerWidget {
  const EditBioScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    const imageHeight = 100.0;
    final notifier = ref.read(myAccountNotifierProvider.notifier);
    final bio = ref.watch(bioStateProvider);
    final bioStateNotifier = ref.watch(bioStateProvider.notifier);

    final links = ref.watch(linksStateProvider);
    final linksStateNotifier = ref.watch(linksStateProvider.notifier);
    final aboutMe = ref.watch(aboutMeStateProvider);
    final aboutMeStateNotifier = ref.watch(aboutMeStateProvider.notifier);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    final listView = asyncValue.when(
      data: (me) {
        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
          child: ListView(
            padding: const EdgeInsets.only(top: 72),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //icon
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final imageFile = await ref
                            .read(imageProcessorNotifierProvider)
                            .getIconImage();
                        ref.read(iconImageStateProvider.notifier).state =
                            imageFile;
                      },
                      child: ref.watch(iconImageStateProvider) != null
                          ? Container(
                              width: imageHeight,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    me.canvasTheme.iconRadius * 1.25),
                                image: DecorationImage(
                                  image: FileImage(
                                    ref.watch(iconImageStateProvider)!,
                                  ),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                me.canvasTheme.iconRadius * 1.25,
                              ),
                              child: Container(
                                height: imageHeight,
                                width: imageHeight,
                                color: ThemeColor.accent,
                                child: me.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: me.imageUrl!,
                                        fadeInDuration:
                                            const Duration(milliseconds: 120),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: imageHeight,
                                          width: imageHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            const SizedBox(),
                                        errorWidget: (context, url, error) =>
                                            const SizedBox(),
                                      )
                                    : const Icon(
                                        Icons.person_outline,
                                        size: imageHeight * 0.8,
                                        color: ThemeColor.stroke,
                                      ),
                              ),
                            ),
                    ),
                  ),
                  const Gap(36),
                  //username
                  /*   Text(
                    "username",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Gap(6),
                  TextFormField(
                    //controller: controller,
                    keyboardType: TextInputType.text,
                    maxLength: 12,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      // text.value = value;
                    },
                    decoration: InputDecoration(
                      hintText: "ユーザー名を入力",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  Gap(24), */

                  //bio
                  const Text(
                    "ひとこと",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: aboutMe,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 120,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      aboutMeStateNotifier.state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "あなたについて教えて!",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),

                  //

                  const Text(
                    "リンク",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  /*Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ThemeColor.stroke,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Image.asset(
                                links.line.assetString,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                linksStateNotifier.state = links.copyWith(
                                    line: links.line.copyWith(
                                        isShown: !links.line.isShown));
                              },
                              child: links.line.isShown
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開中",
                                        style: textStyle.w600(),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開",
                                        style: textStyle.w600(),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              links.line.urlScheme,
                              style: textStyle.w600(),
                            ),
                            Expanded(
                              child: TextField(
                                style: textStyle.w600(),
                                onChanged: (value) {
                                  linksStateNotifier.state = links.copyWith(
                                      line: links.line.copyWith(path: value));
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ), */
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ThemeColor.stroke,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Image.asset(
                                links.instagram.assetString,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                linksStateNotifier.state = links.copyWith(
                                    instagram: links.instagram.copyWith(
                                        isShown: !links.instagram.isShown));
                              },
                              child: links.instagram.isShown
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開中",
                                        style: textStyle.w600(
                                          color: ThemeColor.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開",
                                        style: textStyle.w600(),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              links.instagram.urlScheme,
                              style: textStyle.w600(),
                            ),
                            Expanded(
                              child: TextFormField(
                                style: textStyle.w600(),
                                initialValue: links.instagram.path,
                                onChanged: (value) {
                                  linksStateNotifier.state = links.copyWith(
                                      instagram: links.instagram
                                          .copyWith(path: value));
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ThemeColor.stroke,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 20,
                              child: Image.asset(
                                links.x.assetString,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                linksStateNotifier.state = links.copyWith(
                                    x: links.x
                                        .copyWith(isShown: !links.x.isShown));
                              },
                              child: links.x.isShown
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開中",
                                        style: textStyle.w600(
                                          color: ThemeColor.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        "公開",
                                        style: textStyle.w600(),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              links.x.urlScheme,
                              style: textStyle.w600(),
                            ),
                            Expanded(
                              child: TextFormField(
                                style: textStyle.w600(),
                                initialValue: links.x.path,
                                onChanged: (value) {
                                  linksStateNotifier.state = links.copyWith(
                                      x: links.x.copyWith(path: value));
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),
                  //age
                  const Text(
                    "年齢",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: bio.age?.toString(),
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        bioStateNotifier.state =
                            bio.copyWith(age: int.parse(value));
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "年齢を入力",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),
                  //birthday
                  const Text(
                    "誕生日",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            bio.birthday?.toDate() ?? DateTime(2010, 1, 1),
                        firstDate: DateTime(1900, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        bioStateNotifier.state =
                            bio.copyWith(birthday: Timestamp.fromDate(picked));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Timestamp.fromDate(
                          bio.birthday?.toDate() ?? DateTime(2010, 1, 1),
                        ).toDateStr,
                      ),
                    ),
                  ),
                  const Gap(24),
                  //性別
                  const Text(
                    "性別",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FocusedMenuHolder(
                        onPressed: () {
                          
                        },
                        menuWidth: 120,
                        blurSize: 0,

                        //menuItemExtent: 40.sp,
                        animateMenuItems: false,
                        openWithTap: true,
                        menuBoxDecoration:
                            const BoxDecoration(color: Colors.black),
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "---",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(gender: "system_null");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "男性",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(gender: "system_male");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "女性",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(gender: "system_female");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "カスタム",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(gender: "system_custom");
                            },
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: (() {
                            if (bio.gender == null) {
                              return const Text(
                                "---",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                ),
                              );
                            }
                            if (bio.gender!.startsWith("system_custom")) {
                              return const Text(
                                "カスタム",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                ),
                              );
                            }
                            switch (bio.gender) {
                              case "system_male":
                                return const Text(
                                  "男性",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              case "system_female":
                                return const Text(
                                  "女性",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              case "system_null":
                                return const Text(
                                  "---",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              default:
                                return const Text(
                                  "---",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                            }
                          }()),
                        ),
                      ),
                      const Gap(12),
                      if (bio.gender != null &&
                          bio.gender!.startsWith("system_custom"))
                        Expanded(
                          child: TextFormField(
                            initialValue:
                                bio.gender?.substring(13, bio.gender?.length),
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            maxLength: 12,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.text,
                            ),
                            onChanged: (value) {
                              bioStateNotifier.state =
                                  bio.copyWith(gender: "system_custom$value");
                            },
                            decoration: InputDecoration(
                              hintText: "性別",
                              filled: true,
                              isDense: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                color: ThemeColor.beige,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(24),
                  //興味
                  const Text(
                    "興味",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FocusedMenuHolder(
                        onPressed: () {
                          
                        },
                        menuWidth: 120,
                        blurSize: 0,

                        //menuItemExtent: 40.sp,
                        animateMenuItems: false,
                        openWithTap: true,
                        menuBoxDecoration:
                            const BoxDecoration(color: Colors.black),
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "---",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(interestedIn: "system_null");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "男性",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(interestedIn: "system_male");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "女性",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(interestedIn: "system_female");
                            },
                          ),
                          FocusedMenuItem(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            title: const Text(
                              "カスタム",
                            ),
                            onPressed: () {
                              
                              bioStateNotifier.state =
                                  bio.copyWith(interestedIn: "system_custom");
                            },
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: (() {
                            if (bio.interestedIn == null) {
                              return const Text(
                                "---",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                ),
                              );
                            }
                            if (bio.interestedIn!.startsWith("system_custom")) {
                              return const Text(
                                "カスタム",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                ),
                              );
                            }
                            switch (bio.interestedIn) {
                              case "system_male":
                                return const Text(
                                  "男性",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              case "system_female":
                                return const Text(
                                  "女性",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              case "system_null":
                                return const Text(
                                  "---",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                              default:
                                return const Text(
                                  "---",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ThemeColor.text,
                                  ),
                                );
                            }
                          }()),
                        ),
                      ),
                      const Gap(12),
                      if (bio.interestedIn != null &&
                          bio.interestedIn!.startsWith("system_custom"))
                        Expanded(
                          child: TextFormField(
                            initialValue: bio.interestedIn
                                ?.substring(13, bio.interestedIn?.length),
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            maxLength: 12,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.text,
                            ),
                            onChanged: (value) {
                              bioStateNotifier.state = bio.copyWith(
                                  interestedIn: "system_custom$value");
                            },
                            decoration: InputDecoration(
                              hintText: "興味の対象",
                              filled: true,
                              isDense: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintStyle: const TextStyle(
                                fontSize: 16,
                                color: ThemeColor.beige,
                                fontWeight: FontWeight.w400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(60),
                ],
              ),
            ],
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              "Bioを編集",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  String? imageUrl;
                  final iconImage = ref.watch(iconImageStateProvider);
                  if (iconImage != null) {
                    ref.read(imageUploadingProvider.notifier).state = true;
                    imageUrl = await ref
                        .read(imageUploadUsecaseProvider)
                        .uploadIconImage(iconImage);
                  }
                  notifier.updateBio(bio, aboutMe, links, imageUrl: imageUrl);
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.blue,
                  ),
                  child: const Text(
                    "保存する",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Gap(themeSize.horizontalPadding),
            ],
          ),
          body: listView,
        ),
        Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: ref.watch(imageUploadingProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Visibility(
              visible: ref.watch(imageUploadingProvider),
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
    );
  }
}
