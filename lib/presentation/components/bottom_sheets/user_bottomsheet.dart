import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/auth_notifier.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/users/blocks_list.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserBottomModelSheet {
  UserBottomModelSheet(this.context);
  final BuildContext context;

/*  quitFriendBottomSheet(UserAccount user, {int count = 1}) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
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

                  UserIcon(user: user, width: 72),
                  const Gap(12),

                  Text(
                    "フレンドを解除しますか？",
                    style: textStyle.w600(
                      fontSize: 18,
                    ),
                  ),

                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "・このユーザーと$appName上でDMをすることができなくなります。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        "・フレンド解除したことは相手に通知されません。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),
                  Divider(
                    height: 0,
                    thickness: 0.4,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding,
                    ),
                    child: Material(
                      color: ThemeColor.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          int cnt = 0;
                          Navigator.popUntil(context, (route) {
                            cnt += 1;
                            return cnt == (count + 1);
                          });
                          ref
                              .read(friendsUsecaseProvider)
                              .deleteFriend(user.userId);

                          ref
                              .read(dmOverviewListNotifierProvider.notifier)
                              .leaveChat(user);

                          await Future.delayed(const Duration(seconds: 1));
                          showMessage("フレンド解除しました。");
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "フレンド解除",
                              textAlign: TextAlign.center,
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  } */

  blockUserBottomSheet(UserAccount user, {int count = 1}) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
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

                  UserIcon(user: user, r: 54),
                  const Gap(12),

                  Text(
                    "${user.name}をブロックしますか？",
                    style: textStyle.w600(
                      fontSize: 18,
                    ),
                  ),

                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "このユーザーは$appName上であなたのプロフィールやコンテンツを閲覧できなくなります。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        "ブロックしたことは相手に通知されません。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),
                  Divider(
                    height: 0,
                    thickness: 0.4,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding,
                    ),
                    child: Material(
                      color: ThemeColor.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          int cnt = 0;
                          Navigator.popUntil(context, (route) {
                            cnt += 1;
                            return cnt == (count + 1);
                          });
                          ref
                              .read(blocksListNotifierProvider.notifier)
                              .blockUser(user);
                          ref
                              .read(dmOverviewListNotifierProvider.notifier)
                              .closeChat(user);
                          await Future.delayed(const Duration(seconds: 1));
                          showMessage("ユーザーをブロックしました。");
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "ブロック",
                              textAlign: TextAlign.center,
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.background,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  admitNonMutualUserBottomSheet(UserAccount user) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
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

                  UserIcon(user: user, r: 72),
                  const Gap(12),

                  Text(
                    "PROプランに加入しよう",
                    style: textStyle.w600(
                      fontSize: 18,
                    ),
                  ),

                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "・このユーザーとは共通の友達がいないため、フリープランではリクエストを承認できません。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),
                  Divider(
                    height: 0,
                    thickness: 0.4,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding,
                    ),
                    child: Material(
                      color: ThemeColor.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "サブスクする",
                              textAlign: TextAlign.center,
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.background,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  signoutBottomSheet(UserAccount user, {int count = 1}) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
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

                  UserIcon(user: user, r: 72),
                  const Gap(12),

                  Text(
                    "サインアウトしますか？",
                    style: textStyle.w600(
                      fontSize: 18,
                      color: ThemeColor.error,
                    ),
                  ),

                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "・サインアウト後も、アカウントや保存されたデータは保持されます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "・再度ログインすることで、すべてのデータやアカウント情報にアクセスできます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "・セキュリティ保護のため、共有端末でサインアウトを行う際には、必ずサインアウトを完了したことを確認してください。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),
                  Divider(
                    height: 0,
                    thickness: 0.4,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding,
                    ),
                    child: Material(
                      color: ThemeColor.error,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          ref
                              .read(myAccountNotifierProvider.notifier)
                              .onClosed();
                          ref.read(authNotifierProvider).signout();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "サインアウト",
                              textAlign: TextAlign.center,
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.white,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  deleteAccountBottomSheet(UserAccount user, {int count = 1}) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final themeSize = ref.watch(themeSizeProvider(context));
            final textStyle = ThemeTextStyle(themeSize: themeSize);

            return Container(
              width: themeSize.screenWidth,
              padding: EdgeInsets.only(
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
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

                  UserIcon(user: user, r: 72),
                  const Gap(12),

                  Text(
                    "本当に削除しますか？",
                    style: textStyle.w600(
                      fontSize: 18,
                      color: ThemeColor.error,
                    ),
                  ),

                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "・アカウントを削除すると、すべてのデータが削除されます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "・アプリからはログアウトされます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "・再度ログインするとアカウントを復旧することができます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "・アカウントを削除した後でも、App Storeからサブスクリプションをキャンセルできます。",
                        style: textStyle.w400(
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),

                  const Gap(24),
                  Divider(
                    height: 0,
                    thickness: 0.4,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: themeSize.horizontalPadding,
                    ),
                    child: Material(
                      color: ThemeColor.error,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          ref.read(authNotifierProvider).signout();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "アカウントを削除",
                              textAlign: TextAlign.center,
                              style: textStyle.w600(
                                fontSize: 14,
                                color: ThemeColor.white,
                              ),
                            ),
                          ),
                        ),
                      ),
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
