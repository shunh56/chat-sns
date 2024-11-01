import 'package:app/core/utils/permissions/camera_permission.dart';
import 'package:app/core/utils/permissions/photo_permission.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PostContentMenu extends ConsumerWidget {
  const PostContentMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final imageList = ref.watch(imageListNotifierProvider);
    final imageListNotifier = ref.watch(imageListNotifierProvider.notifier);
    return Container(
      color: Colors.white.withOpacity(0.1),
      padding: EdgeInsets.symmetric(
        horizontal: themeSize.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              

              bool isGranted = await PhotoPermissionsHandler().isGranted;
              if (!isGranted) {
                await PhotoPermissionsHandler().request();
                bool permitted = await PhotoPermissionsHandler().isGranted;
                if (!permitted) {
                  showMessage("写真へのアクセスが制限されています。");
                  return;
                }
              }
              if (imageList.length >= 2) {
                showMessage("3枚以上投稿する場合はプレミアムでなければなりません。");
                return;
              }
              primaryFocus?.unfocus();
              final compressedImageFile =
                  await ref.read(imageProcessorNotifierProvider).getPostImage();
              if (compressedImageFile != null) {
                imageListNotifier.addItem(compressedImageFile);
              }
              primaryFocus?.previousFocus();
            },
            child: const Icon(
              Icons.photo_outlined,
              color: ThemeColor.button,
              size: 30,
            ),
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: GestureDetector(
              onTap: () async {
                

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
                final compressedImageFile = await ref
                    .read(imageProcessorNotifierProvider)
                    .getPostImageFromCamera();
                if (compressedImageFile != null) {
                  imageListNotifier.addItem(compressedImageFile);
                }
                primaryFocus?.previousFocus();
              },
              child: const Icon(
                Icons.camera_alt_outlined,
                color: ThemeColor.button,
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
