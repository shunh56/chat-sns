import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/core/utils/permissions/camera_permission.dart';
import 'package:app/core/utils/permissions/photo_permission.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/dialogs/dialogs.dart';
import 'package:app/presentation/providers/image/image_processor.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';

/// 投稿作成画面のアクションバー
///
/// 機能:
/// - メディア選択ボタン（写真・カメラ・位置情報・ハッシュタグ）
/// - 投稿送信ボタン
/// - 権限チェックとエラーハンドリング
class PostActionBar extends ConsumerWidget {
  const PostActionBar({
    super.key,
    this.onHashtagTap,
  });

  final VoidCallback? onHashtagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider);
    final imageList = ref.watch(imageListNotifierProvider);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: max(MediaQuery.of(context).padding.bottom, 12),
        ),
        color: ThemeColor.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Divider(
                thickness: 0.6,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.photo_outlined,
                    onTap: () => _handlePhotoSelection(context, ref, imageList),
                  ),
                  const Gap(12),
                  _buildActionButton(
                    icon: Icons.camera_alt_outlined,
                    onTap: () =>
                        _handleCameraSelection(context, ref, imageList),
                  ),
                  const Gap(12),
                  _buildActionButton(
                    icon: Icons.location_on_outlined,
                    onTap: () async {
                      // 位置情報機能（将来の実装用）
                    },
                  ),
                  const Gap(12),
                  _buildActionButton(
                    icon: Icons.tag_rounded,
                    onTap: onHashtagTap ?? () {},
                  ),
                  const Spacer(),
                  _buildPostButton(context, ref, postState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColor.white.withOpacity(0.07),
        ),
        child: Icon(
          icon,
          color: ThemeColor.icon,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildPostButton(
    BuildContext context,
    WidgetRef ref,
    dynamic postState,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: postState.isReadyToUpload
            ? () => _handlePostSubmit(context, ref, postState)
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
              "シェア",
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
    );
  }

  void _handlePostSubmit(
    BuildContext context,
    WidgetRef ref,
    dynamic postState,
  ) {
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(allPostsNotifierProvider.notifier).createPost(postState);
    showMessage("シェアしました！");
    Navigator.pop(context);
  }

  void _handlePhotoSelection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> imageList,
  ) async {
    if (imageList.length >= 4) {
      showMessage("5枚以上投稿する場合はプレミアムでなければなりません。");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

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
    FocusManager.instance.primaryFocus?.previousFocus();
  }

  void _handleCameraSelection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> imageList,
  ) async {
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

    FocusManager.instance.primaryFocus?.unfocus();
    final compressedImageFile =
        await ref.read(imageProcessorNotifierProvider).getPostImageFromCamera();
    if (compressedImageFile != null) {
      ref.read(imageListNotifierProvider.notifier).addItem(compressedImageFile);
    }
    FocusManager.instance.primaryFocus?.previousFocus();
  }
}
