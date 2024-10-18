import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserImageBottomSheet {
  final BuildContext context;
  UserImageBottomSheet(this.context);

  showImageMenu(UserImage image) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final myId = ref.watch(authProvider).currentUser!.uid;
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: themeSize.horizontalPadding,
                right: themeSize.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //ios design
                  Container(
                    height: 4,
                    width: MediaQuery.sizeOf(context).width / 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const Gap(24),

                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColor.stroke,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref
                                .read(userImagesNotiferProvider(myId).notifier)
                                .removeImage(image);
                            Navigator.pop(context);
                            showMessage("写真を削除しました");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "削除",
                                  style: textStyle.w600(
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  color: ThemeColor.icon,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
