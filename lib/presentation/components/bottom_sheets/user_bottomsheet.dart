import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserBottomModelSheet {
  UserBottomModelSheet(this.context);
  final BuildContext context;

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

                  UserIcon.tileIcon(user, width: 72),
                  const Gap(12),

                  Text(
                    "${user.name}をブロックしますか？",
                    style: textStyle.w600(
                      fontSize: 18,
                    ),
                  ),

                  const Gap(12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: themeSize.horizontalPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "・このユーザーは$appName上であなたのプロフィールやコンテンツを閲覧できなくなります。",
                          style: textStyle.w400(
                            color: ThemeColor.subText,
                          ),
                        ),
                        const Gap(12),
                        Text(
                          "・ブロックしたことは相手に通知されません。",
                          style: textStyle.w400(
                            color: ThemeColor.subText,
                          ),
                        ),
                      ],
                    ),
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
                          HapticFeedback.lightImpact();
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
}
