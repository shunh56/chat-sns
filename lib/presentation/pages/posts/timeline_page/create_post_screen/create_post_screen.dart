import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/pages/posts/timeline_page/create_post_screen/images_widget.dart';
import 'package:app/presentation/pages/posts/timeline_page/create_post_screen/post_content_menu_widget.dart';
import 'package:app/presentation/pages/posts/timeline_page/create_post_screen/post_text_input_widget.dart';
import 'package:app/presentation/providers/provider/posts/all_posts.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({
    super.key,
    this.community,
  });
  final Community? community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            primaryFocus?.unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: themeSize.horizontalPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              primaryFocus?.unfocus();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "キャンセル",
                              style: textStyle.w400(
                                fontSize: 14,
                                color: ThemeColor.subText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: community != null
                                ? Center(
                                    child: Text(
                                      community!.name,
                                      style:
                                          textStyle.appbarText(isSmall: true),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          GestureDetector(
                            onTap: () async {
                              /*if (community != null) {
                                ref.read(communityIdProvider.notifier).state =
                                    community!.id;
                                ref.read(isPublicProvider.notifier).state = true;
                              } */
                              final postState = ref.read(postStateProvider);
                              if (postState.isReadyToUpload) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                ref
                                    .read(allPostsNotifierProvider.notifier)
                                    .createPost(postState);
                                showMessage("送信を開始しました。");
                                Navigator.pop(context);
                              } else {
                                showMessage("タイトルを入力してください。");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: ThemeColor.highlight,
                              ),
                              child: Text(
                                "送信",
                                style: TextStyle(
                                  color: ref
                                          .watch(postStateProvider)
                                          .isReadyToUpload
                                      ? ThemeColor.white
                                      : Colors.white.withOpacity(0.3),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: themeSize.horizontalPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(24),
                                // タイトル入力
                                TextField(
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  maxLength: 24,
                                  style: textStyle.w700(
                                    fontSize: 16,
                                  ),
                                  onChanged: (text) {
                                    ref.read(titleTextProvider.notifier).state =
                                        text;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    hintText: "タイトルを入力...",
                                    hintStyle: textStyle.w700(
                                      fontSize: 16,
                                      color: ThemeColor.subText,
                                    ),
                                    counterStyle: textStyle.numText(
                                      color: ThemeColor.subText,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                                const Gap(16),
                                // 本文入力
                                const PostTextInputWidget(),
                              ],
                            ),
                          ),
                          const PostImagesWidget(),
                          const Gap(16),
                          // ハッシュタグ入力
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: themeSize.horizontalPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHashtagInput(context, ref, textStyle),
                                const Gap(16),
                                // メンション入力
                                _buildMentionInput(context, ref, textStyle),
                                const Gap(16),
                              ],
                            ),
                          )
                          // 画像
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (postPrivacyMode) _buildPublicityLabel(ref),
              const Gap(8),
              const PostContentMenu(),
            ],
          ),
        ),
      ),
    );
  }

  // ハッシュタグ入力ウィジェット
  Widget _buildHashtagInput(
      BuildContext context, WidgetRef ref, ThemeTextStyle textStyle) {
    final hashtags = ref.watch(hashtagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ハッシュタグ',
          style: textStyle.w400(fontSize: 14, color: ThemeColor.subText),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...hashtags.map((tag) => Chip(
                  label: Text('#$tag',
                      style: const TextStyle(color: ThemeColor.text)),
                  backgroundColor: ThemeColor.surface,
                  deleteIcon:
                      const Icon(Icons.close, size: 16, color: ThemeColor.text),
                  onDeleted: () {
                    final updatedTags = List<String>.from(hashtags);
                    updatedTags.remove(tag);
                    ref.read(hashtagsProvider.notifier).state = updatedTags;
                  },
                )),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: ThemeColor.primary),
              onPressed: () {
                _showAddHashtagDialog(context, ref);
              },
            ),
          ],
        ),
      ],
    );
  }

  // メンション入力ウィジェット
  Widget _buildMentionInput(
      BuildContext context, WidgetRef ref, ThemeTextStyle textStyle) {
    final mentions = ref.watch(mentionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'メンション',
          style: textStyle.w400(fontSize: 14, color: ThemeColor.subText),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...mentions.map((mention) => Chip(
                  label: Text('@$mention',
                      style: const TextStyle(color: ThemeColor.text)),
                  backgroundColor: ThemeColor.surface,
                  deleteIcon:
                      const Icon(Icons.close, size: 16, color: ThemeColor.text),
                  onDeleted: () {
                    final updatedMentions = List<String>.from(mentions);
                    updatedMentions.remove(mention);
                    ref.read(mentionsProvider.notifier).state = updatedMentions;
                  },
                )),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: ThemeColor.primary),
              onPressed: () {
                _showAddMentionDialog(context, ref);
              },
            ),
          ],
        ),
      ],
    );
  }

  // ハッシュタグ追加ダイアログ
  void _showAddHashtagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        title:
            const Text('ハッシュタグを追加', style: TextStyle(color: ThemeColor.text)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: ThemeColor.text),
          decoration: const InputDecoration(
            prefixText: '#',
            hintText: 'タグを入力（スペースなし）',
            hintStyle: TextStyle(color: ThemeColor.subText),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ThemeColor.divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ThemeColor.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル',
                style: TextStyle(color: ThemeColor.subText)),
          ),
          TextButton(
            onPressed: () {
              final tag = controller.text.trim().replaceAll(' ', '');
              if (tag.isNotEmpty) {
                final currentTags = ref.read(hashtagsProvider);
                if (!currentTags.contains(tag)) {
                  ref.read(hashtagsProvider.notifier).state = [
                    ...currentTags,
                    tag
                  ];
                }
              }
              Navigator.pop(context);
            },
            child:
                const Text('追加', style: TextStyle(color: ThemeColor.primary)),
          ),
        ],
      ),
    );
  }

  // メンション追加ダイアログ
  void _showAddMentionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        title: const Text('メンションを追加', style: TextStyle(color: ThemeColor.text)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: ThemeColor.text),
          decoration: const InputDecoration(
            prefixText: '@',
            hintText: 'ユーザー名を入力',
            hintStyle: TextStyle(color: ThemeColor.subText),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ThemeColor.divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ThemeColor.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル',
                style: TextStyle(color: ThemeColor.subText)),
          ),
          TextButton(
            onPressed: () {
              final mention = controller.text.trim();
              if (mention.isNotEmpty) {
                final currentMentions = ref.read(mentionsProvider);
                if (!currentMentions.contains(mention)) {
                  ref.read(mentionsProvider.notifier).state = [
                    ...currentMentions,
                    mention
                  ];
                }
              }
              Navigator.pop(context);
            },
            child:
                const Text('追加', style: TextStyle(color: ThemeColor.primary)),
          ),
        ],
      ),
    );
  }

  _buildPublicityLabel(WidgetRef ref) {
    final isPublic = ref.watch(isPublicProvider);
    if (community != null) return const SizedBox();
    return GestureDetector(
      onTap: () {
        ref.read(isPublicProvider.notifier).state = !isPublic;
      },
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
        child: isPublic
            ? const Row(
                children: [
                  Icon(
                    size: 18,
                    Icons.public_rounded,
                    color: Colors.blueAccent,
                  ),
                  Gap(4),
                  Text(
                    "公開",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              )
            : const Row(
                children: [
                  Icon(
                    size: 18,
                    Icons.lock_outline_rounded,
                    color: Colors.blueAccent,
                  ),
                  Gap(4),
                  Text(
                    "友達のみ",
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
