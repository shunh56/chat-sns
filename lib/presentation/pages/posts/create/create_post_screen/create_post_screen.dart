import 'package:app/core/utils/permissions/camera_permission.dart';
import 'package:app/core/utils/permissions/photo_permission.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/components/dialogs/dialogs.dart';
import 'package:app/presentation/pages/posts/create/create_post_screen/images_widget.dart';
import 'package:app/presentation/pages/posts/create/create_post_screen/post_text_input_widget.dart';
import 'package:app/presentation/providers/image/image_processor.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
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
    final postState = ref.watch(postStateProvider);
    final imageList = ref.watch(imageListNotifierProvider);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        backgroundColor: ThemeColor.surface,
        elevation: 0,
        title: community != null
            ? Text(
                community!.name,
                style: textStyle.w600(fontSize: 16),
              )
            : const Text('新規投稿',
                style: TextStyle(
                    color: ThemeColor.text, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (postPrivacyMode && community == null)
            IconButton(
              icon: Icon(
                ref.watch(isPublicProvider)
                    ? Icons.public_rounded
                    : Icons.lock_outline_rounded,
                color: ThemeColor.highlight,
              ),
              onPressed: () {
                ref.read(isPublicProvider.notifier).state =
                    !ref.watch(isPublicProvider);
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Content Card
                    Card(
                      margin: EdgeInsets.all(themeSize.horizontalPadding),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: ThemeColor.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Input with animation
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                // color: ThemeColor.inputBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeColor.divider.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                maxLength: 24,
                                style: textStyle.w700(fontSize: 16),
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
                            ),
                            const Gap(16),
                            // Content divider
                            Divider(color: ThemeColor.divider.withOpacity(0.5)),
                            const Gap(8),
                            // Post content input
                            const PostTextInputWidget(),
                          ],
                        ),
                      ),
                    ),

                    // Images Section with improved UI
                    if (imageList.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: themeSize.horizontalPadding,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.photo_library,
                                    color: ThemeColor.highlight, size: 20),
                                const Gap(8),
                                Text(
                                  "添付画像",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                    color: ThemeColor.text,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${imageList.length}/4",
                                  style: textStyle.w400(
                                    fontSize: 14,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            const PostImagesWidget(),
                          ],
                        ),
                      ),

                    // Tags Card - Combining Hashtags and Mentions
                    Card(
                      margin: EdgeInsets.all(themeSize.horizontalPadding),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: ThemeColor.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hashtags section
                            _buildHashtagSection(context, ref, textStyle),
                            const Gap(16),
                            const Divider(),
                            const Gap(16),
                            // Mentions section
                            _buildMentionSection(context, ref, textStyle),
                          ],
                        ),
                      ),
                    ),
                    // Extra space at bottom for the floating menu
                    const Gap(80),
                  ],
                ),
              ),

              // Bottom Menu - Floating design
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Image Button
                      _buildMenuButton(
                        icon: Icons.photo_outlined,
                        label: '画像',
                        onTap: () async {
                          if (imageList.length >= 4) {
                            showMessage("5枚以上投稿する場合はプレミアムでなければなりません。");
                            return;
                          }
                          _handlePhotoSelection(context, ref);
                        },
                      ),
                      const Gap(12),
                      // Camera Button
                      _buildMenuButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'カメラ',
                        onTap: () async {
                          _handleCameraSelection(context, ref);
                        },
                      ),
                      const Spacer(),
                      // Send Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: postState.isReadyToUpload
                              ? () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  ref
                                      .read(allPostsNotifierProvider.notifier)
                                      .createPost(postState);
                                  showMessage("送信を開始しました。");
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.highlight,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.send, size: 16),
                              const Gap(8),
                              Text(
                                "送信",
                                style: TextStyle(
                                  color: postState.isReadyToUpload
                                      ? ThemeColor.white
                                      : Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
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
      ),
    );
  }

  // Modern hashtag section
  Widget _buildHashtagSection(
      BuildContext context, WidgetRef ref, ThemeTextStyle textStyle) {
    final hashtags = ref.watch(hashtagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tag, color: ThemeColor.highlight, size: 20),
            const Gap(8),
            Text(
              'ハッシュタグ',
              style: textStyle.w600(fontSize: 14, color: ThemeColor.text),
            ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...hashtags.map((tag) => _buildChip(
                  context,
                  text: '#$tag',
                  onDelete: () {
                    final updatedTags = List<String>.from(hashtags);
                    updatedTags.remove(tag);
                    ref.read(hashtagsProvider.notifier).state = updatedTags;
                  },
                )),
            _buildAddChip(
              onTap: () => _showAddHashtagDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  // Modern mention section
  Widget _buildMentionSection(
      BuildContext context, WidgetRef ref, ThemeTextStyle textStyle) {
    final mentions = ref.watch(mentionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: ThemeColor.highlight, size: 20),
            const Gap(8),
            Text(
              'メンション',
              style: textStyle.w600(fontSize: 14, color: ThemeColor.text),
            ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...mentions.map((mention) => _buildChip(
                  context,
                  text: '@$mention',
                  onDelete: () {
                    final updatedMentions = List<String>.from(mentions);
                    updatedMentions.remove(mention);
                    ref.read(mentionsProvider.notifier).state = updatedMentions;
                  },
                )),
            _buildAddChip(
              onTap: () => _showAddMentionDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  // Modern chip design
  Widget _buildChip(BuildContext context,
      {required String text, required VoidCallback onDelete}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColor.highlight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColor.highlight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: ThemeColor.highlight,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const Gap(4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close,
              size: 16,
              color: ThemeColor.highlight,
            ),
          ),
        ],
      ),
    );
  }

  // Add chip button
  Widget _buildAddChip({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeColor.divider,
            width: 1,
            //style: BorderStyle.dashed,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: ThemeColor.subText,
            ),
            Gap(4),
            Text(
              "追加",
              style: TextStyle(
                color: ThemeColor.subText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menu button with label
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // color: ThemeColor.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: ThemeColor.highlight,
              size: 20,
            ),
            const Gap(6),
            Text(
              label,
              style: const TextStyle(
                color: ThemeColor.highlight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern hashtag dialog
  void _showAddHashtagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.tag, color: ThemeColor.highlight, size: 20),
            Gap(8),
            Text('ハッシュタグを追加', style: TextStyle(color: ThemeColor.text)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: ThemeColor.text),
          decoration: InputDecoration(
            prefixText: '#',
            prefixStyle: const TextStyle(
              color: ThemeColor.highlight,
              fontWeight: FontWeight.bold,
            ),
            hintText: 'タグを入力（スペースなし）',
            hintStyle: const TextStyle(color: ThemeColor.subText),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: ThemeColor.divider.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ThemeColor.highlight),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル',
                style: TextStyle(color: ThemeColor.subText)),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.highlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('追加', style: TextStyle(color: ThemeColor.white)),
          ),
        ],
      ),
    );
  }

  // Modern mention dialog
  void _showAddMentionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.person, color: ThemeColor.highlight, size: 20),
            Gap(8),
            Text('メンションを追加', style: TextStyle(color: ThemeColor.text)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: ThemeColor.text),
          decoration: InputDecoration(
            prefixText: '@',
            prefixStyle: const TextStyle(
              color: ThemeColor.highlight,
              fontWeight: FontWeight.bold,
            ),
            hintText: 'ユーザー名を入力',
            hintStyle: const TextStyle(color: ThemeColor.subText),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: ThemeColor.divider.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ThemeColor.highlight),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル',
                style: TextStyle(color: ThemeColor.subText)),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.highlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('追加', style: TextStyle(color: ThemeColor.white)),
          ),
        ],
      ),
    );
  }

  // Helper method for photo selection
  void _handlePhotoSelection(BuildContext context, WidgetRef ref) async {
    primaryFocus?.unfocus();

    // Check photo permissions here
    // This is a placeholder - you'll need to adapt this based on your actual permission handler
    bool isGranted = await PhotoPermissionsHandler().isGranted;
    if (!isGranted) {
      await PhotoPermissionsHandler().request();
      bool permitted = await PhotoPermissionsHandler().isGranted;
      if (!permitted) {
        showDialog(
          context: context,
          builder: (context) => showGalleryPermissionDialog(context, ref),
        );
        return;
      }
    }

    final imageProcessor = ref.read(imageProcessorNotifierProvider);
    final compressedImageFile = await imageProcessor.getPostImage();
    if (compressedImageFile != null) {
      ref.read(imageListNotifierProvider.notifier).addItem(compressedImageFile);
    }
    if (primaryFocus != null) {
      primaryFocus?.previousFocus();
    }
  }

  // Helper method for camera selection
  void _handleCameraSelection(BuildContext context, WidgetRef ref) async {
    final imageList = ref.watch(imageListNotifierProvider);

    // Check camera permissions
    bool isGranted = await CameraPermissionsHandler().isGranted;
    if (!isGranted) {
      await CameraPermissionsHandler().request();
      bool permitted = await CameraPermissionsHandler().isGranted;
      if (!permitted) {
        showMessage("カメラへのアクセスが制限されています。");
        return;
      }
    }

    if (imageList.length >= 2) {
      showMessage("3枚以上投稿する場合はプレミアムでなければなりません。");
      return;
    }

    primaryFocus?.unfocus();
    final compressedImageFile =
        await ref.read(imageProcessorNotifierProvider).getPostImageFromCamera();
    if (compressedImageFile != null) {
      ref.read(imageListNotifierProvider.notifier).addItem(compressedImageFile);
    }
    primaryFocus?.previousFocus();
  }
}
