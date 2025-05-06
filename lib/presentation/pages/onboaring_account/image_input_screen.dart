import 'dart:io';

import 'package:app/core/utils/permissions/photo_permission.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/dialogs/dialogs.dart';
import 'package:app/presentation/providers/onboarding_providers.dart';
import 'package:app/presentation/providers/image/image_processor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputImageUrlScreen extends ConsumerWidget {
  const InputImageUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final image = ref.watch(imageProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Text(
            "プロフィール画像を\n設定しましょう",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              bool isGranted = await PhotoPermissionsHandler().isGranted;
              if (!isGranted) {
                await PhotoPermissionsHandler().request();
                bool permitted = await PhotoPermissionsHandler().isGranted;
                if (!permitted) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        showGalleryPermissionDialog(context, ref),
                  );

                  return;
                }
              }
              final pickedFile =
                  await ref.read(imageProcessorNotifierProvider).getIconImage();
              if (pickedFile != null) {
                ref.read(imageProvider.notifier).state = File(pickedFile.path);
              }
            },
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: ThemeColor.surface,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(
                  color: ThemeColor.stroke,
                  width: 2,
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: ThemeColor.textSecondary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "タップして選択",
                          style: TextStyle(
                            color: ThemeColor.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const Spacer(flex: 2),
          ElevatedButton(
            onPressed: image == null
                ? null
                : () {
                    ref.read(pageControllerProvider).nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primary,
              foregroundColor: ThemeColor.text,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "次へ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
