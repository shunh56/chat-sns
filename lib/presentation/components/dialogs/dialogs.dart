import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class BasicDialog extends ConsumerWidget {
  const BasicDialog({
    super.key,
    required this.title,
    required this.content,
    this.onPositivePressed,
    this.onNegativePressed,
    this.positiveText = 'OK',
    this.negativeText = '戻る',
    this.negativeTextNotShow = false,
  });
  final String title;
  final String content;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;
  final String positiveText;
  final String negativeText;
  final bool negativeTextNotShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: ThemeColor.background,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(16),
      actionsPadding: const EdgeInsets.all(16),
      //insetPadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,

      //icon: null
      title: Container(
        width: themeSize.screenWidth * 0.8,
        padding: const EdgeInsets.only(top: 24),
        child: Center(
          child: Text(
            title,
            style: textStyle.w600(fontSize: 18),
          ),
        ),
      ),
      content: Text(
        content,
        style: textStyle.w600(
          fontSize: 14,
          color: ThemeColor.subText,
        ),
      ),
      actions: <Widget>[
        if (!negativeTextNotShow)
          GestureDetector(
            onTap: onNegativePressed ?? () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeColor.stroke,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                negativeText,
                style: textStyle.w600(
                  fontSize: 14,
                  color: ThemeColor.subText,
                ),
              ),
            ),
          ),
        const SizedBox(
          width: 24,
        ),
        GestureDetector(
          onTap: onPositivePressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              positiveText,
              style: textStyle.w600(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}

showGalleryPermissionDialog(
  BuildContext context,
  WidgetRef ref,
) {
  return BasicDialog(
    title: "写真へのアクセス",
    content: "写真を選択するには、写真へのアクセス許可が必要です。",
    positiveText: "設定へ",
    onPositivePressed: () {
      Navigator.pop(context);
      openAppSettings(); // 設定画面を開く
    },
  );
}

/*class DialogsProvider {
  Future<void> showNewFriendDialog(UserAccount user) async {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    Timer timer = Timer(const Duration(milliseconds: 2400), () {
      Navigator.of(context).pop();
    });
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      barrierLabel: "CLOSE",
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOutCubic.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: ThemeColor.accent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ref
                          .read(navigationRouterProvider(context))
                          .goToProfile(user);
                    },
                    child: UserIcon(user:user),
                  ),
                  Text(
                    user.name,
                    style: textStyle.w600(fontSize: 14),
                  ),
                  const Gap(16),
                  Text(
                    "とフレンドになりました!",
                    style: textStyle.w600(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ).then((value) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }
}
 */
