import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

showQuitRequestDialog(
  BuildContext context,
  WidgetRef ref,
  UserAccount user,
) {
  return BasicDialog(
    title: "リクエストをキャンセル",
    content: "${user.name}へのフレンドリクエストをキャンセルしてよろしいですか？",
    onPositivePressed: () {
      ref
          .read(friendRequestIdListNotifierProvider.notifier)
          .cancelFriendRequest(user.userId);
      Navigator.pop(context);
    },
  );
}

showFriendRequestDialog(
  BuildContext context,
  WidgetRef ref,
  UserAccount user,
) {
  return BasicDialog(
    title: "フレンドリクエスト",
    content: "${user.name}さんからフレンドリクエストが届いています。",
    positiveText: "承認",
    negativeText: "削除",
    onPositivePressed: () {
      ref
          .read(friendRequestedIdListNotifierProvider.notifier)
          .admitFriendRequested(user);
      Navigator.pop(context);
    },
    onNegativePressed: () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => showDeleteRequestDialog(context, ref, user),
      );
    },
  );
}

showDeleteRequestDialog(
  BuildContext context,
  WidgetRef ref,
  UserAccount user,
) {
  return BasicDialog(
    title: "リクエストを削除",
    content: "${user.name}からのフレンドリクエストを削除してよろしいですか？",
    positiveText: "削除",
    onPositivePressed: () {
      ref
          .read(friendRequestedIdListNotifierProvider.notifier)
          .deleteRequested(user);
      ref.read(deletesIdListNotifierProvider.notifier).deleteUser(user);
      Navigator.pop(context);
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