import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/usecase/image_uploader_usecase.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final iconImageStateProvider = StateProvider.autoDispose<File?>((ref) => null);
final imageUploadingProvider = StateProvider.autoDispose((ref) => false);

// 追加の状態プロバイダー
final locationStateProvider = StateProvider.autoDispose<String>((ref) => '');
final websiteStateProvider = StateProvider.autoDispose<String>((ref) => '');
final interestsStateProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

class EditProfileScreens extends ConsumerWidget {
  const EditProfileScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double imageHeight = 120.0;

    final notifier = ref.read(myAccountNotifierProvider.notifier);
    final bio = ref.watch(bioStateProvider);

    // 状態の監視
    final name = ref.watch(nameStateProvider);
    final nameNotifier = ref.watch(nameStateProvider.notifier);
    final aboutMe = ref.watch(aboutMeStateProvider);
    final aboutMeNotifier = ref.watch(aboutMeStateProvider.notifier);
    final links = ref.watch(linksStateProvider);
    final linksNotifier = ref.watch(linksStateProvider.notifier);
    final location = ref.watch(locationStateProvider);
    final locationNotifier = ref.watch(locationStateProvider.notifier);

    Widget buildTextField({
      required String label,
      required String value,
      required Function(String) onChanged,
      int? maxLength,
      int maxLines = 1,
      String? hint,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              if (maxLength != null)
                Text(
                  "${value.length}/$maxLength",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            maxLength: maxLength,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              counterText: "",
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    Widget buildSocialLinkField({
      required String platform,
      required String value,
      required Function(String) onChanged,
      required String assetPath,
      required bool isPublic,
      required Function(bool) onToggle,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "URLを入力",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                Switch(
                  value: isPublic,
                  onChanged: onToggle,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      );
    }

    final me = ref.read(myAccountNotifierProvider).asData!.value;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "プロフィールを編集",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (name.isEmpty) {
                showMessage("ニックネームを入力してください。");
                return;
              }
              String? imageUrl;
              final iconImage = ref.watch(iconImageStateProvider);
              ref.read(imageUploadingProvider.notifier).state = true;
              try {
                if (iconImage != null) {
                  imageUrl = await ref
                      .read(imageUploadUsecaseProvider)
                      .uploadIconImage(iconImage);
                }
                notifier.updateBio(
                  name: name,
                  bio: bio,
                  aboutMe: aboutMe,
                  links: links,
                  imageUrl: imageUrl,
                );
                Navigator.pop(context);
              } catch (e) {
                ref.read(imageUploadingProvider.notifier).state = false;
                DebugPrint("error : $e");
                showErrorSnackbar(error: e);
              }
            },
            child: const Text(
              "保存",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プロフィール画像
              Center(
                child: Stack(
                  children: [
                    ref.watch(iconImageStateProvider) != null
                        ? Container(
                            width: imageHeight,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(imageHeight * 2 / 9),
                              image: DecorationImage(
                                image: FileImage(
                                    ref.watch(iconImageStateProvider)!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(imageHeight * 2 / 9),
                            child: Container(
                              height: imageHeight,
                              width: imageHeight,
                              color: ThemeColor.accent,
                              child: me.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: me.imageUrl!,
                                      fadeInDuration:
                                          const Duration(milliseconds: 120),
                                      imageBuilder: (context, imageProvider) =>
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
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final imageFile = await ref
                              .read(imageProcessorNotifierProvider)
                              .getIconImage();
                          ref.read(iconImageStateProvider.notifier).state =
                              imageFile;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: ThemeColor.stroke,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 名前
              buildTextField(
                label: "名前",
                value: name,
                onChanged: (value) => nameNotifier.state = value,
                maxLength: 30,
                hint: "名前を入力",
              ),

              // 自己紹介
              buildTextField(
                label: "自己紹介",
                value: aboutMe,
                onChanged: (value) => aboutMeNotifier.state = value,
                maxLength: 160,
                maxLines: 3,
                hint: "自己紹介を入力",
              ),

              // 居住地
              buildTextField(
                label: "居住地",
                value: location,
                onChanged: (value) => locationNotifier.state = value,
                hint: "場所を入力",
              ),

              // SNSリンク
              const Text(
                "ソーシャルリンク",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              // Instagram
              buildSocialLinkField(
                platform: "Instagram",
                value: links.instagram.path ?? "",
                onChanged: (value) {
                  linksNotifier.state = links.copyWith(
                    instagram: links.instagram.copyWith(path: value),
                  );
                },
                assetPath: links.instagram.assetString,
                isPublic: links.instagram.isShown,
                onToggle: (value) {
                  linksNotifier.state = links.copyWith(
                    instagram: links.instagram.copyWith(isShown: value),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Twitter/X
              buildSocialLinkField(
                platform: "X",
                value: links.x.path ?? "",
                onChanged: (value) {
                  linksNotifier.state = links.copyWith(
                    x: links.x.copyWith(path: value),
                  );
                },
                assetPath: links.x.assetString,
                isPublic: links.x.isShown,
                onToggle: (value) {
                  linksNotifier.state = links.copyWith(
                    x: links.x.copyWith(isShown: value),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
