import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/invite_code_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class InviteCodeScreen extends ConsumerWidget {
  const InviteCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    final friendIds =
        (ref.watch(friendIdListNotifierProvider).asData?.value ?? [])
            .map((info) => info.userId)
            .toList();
    final myIcon = asyncValue.when(
      data: (me) {
        return UserIcon(user: me);
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    final inviteCode = ref.watch(myInviteCodeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "招待コード",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(12),
            Row(
              children: [
                myIcon,
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "招待コード",
                      style: textStyle.w600(
                        color: ThemeColor.subText,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Opacity(
                          opacity:
                              inviteCode.getStatus == InviteCodeStatus.valid
                                  ? 1
                                  : 0.3,
                          child: Text(
                            inviteCode.code,
                            style: textStyle.w600(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              inviteCode.getStatus == InviteCodeStatus.valid,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: inviteCode.code));
                              showMessage("招待コードをコピーしました");
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.copy_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                (() {
                  switch (inviteCode.getStatus) {
                    case (InviteCodeStatus.valid):
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "有効",
                                    style: textStyle.w600(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " (あと${inviteCode.maxCount - inviteCode.slot.length}人)",
                                    style: textStyle.w600(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    case (InviteCodeStatus.overLimit):
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ThemeColor.stroke,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "使用済み",
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
                        ),
                      );
                    case (InviteCodeStatus.unknownError):
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: ThemeColor.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "エラー",
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                }())
              ],
            ),
            const Gap(24),
            Expanded(
              child: FutureBuilder(
                future: ref
                    .read(allUsersNotifierProvider.notifier)
                    .getUserAccounts(inviteCode.slot),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("使用したユーザーはいません"),
                    );
                  }
                  final data = snapshot.data!;
                  final users = data.reversed.toList();
                  return ListView(
                    children: [
                      Text(
                        "使用したユーザー",
                        style: textStyle.w600(
                          fontSize: 14,
                        ),
                      ),
                      const Gap(4),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final log = inviteCode.logs
                              .where((item) => item["userId"] == user.userId)
                              .first;
                          final usedAt = log["createdAt"] as Timestamp;
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(navigationRouterProvider(context))
                                  .goToProfile(user);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ThemeColor.accent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeColor.stroke,
                                  width: 0.4,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usedAt.toDateStr,
                                    style: textStyle.w400(
                                      color: ThemeColor.subText,
                                    ),
                                  ),
                                  const Gap(8),
                                  Row(
                                    children: [
                                      UserIcon(user: user, width: 40),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyle.w600(
                                                fontSize: 14,
                                                color: ThemeColor.white,
                                              ),
                                            ),
                                            Text(
                                              "@${user.username}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyle.w600(
                                                color: ThemeColor.subText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(12),
                                      if (friendIds.contains(user.userId))
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: ThemeColor.stroke,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "フレンド",
                                            style: textStyle.w600(
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            /*    SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Gap(48),
                  Transform.rotate(
                    angle: -pi / 48,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: me.canvasTheme.boxBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(18, 18),
                            spreadRadius: 4,
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: DottedBorder(
                        color: me
                            .canvasTheme.boxTextColor, //color of dotted/dash line
                        strokeWidth: 3, //thickness of dash/dots
                        dashPattern: const [24, 8],
                        radius: const Radius.circular(12),
                        borderType: BorderType.RRect,
                        child: Container(
                          width: themeSize.screenWidth * 0.66,
                          height: themeSize.screenHeight * 0.5,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                appName,
                                style: TextStyle(
                                  color: me.canvasTheme.boxSecondaryTextColor,
                                  fontSize: 24,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: myIcon,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Transform.rotate(
                                      angle: -pi / 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: me.canvasTheme.bgColor,
                                        ),
                                        child: Icon(
                                          color: me.canvasTheme.profileTextColor,
                                          Icons.confirmation_num_outlined,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onLongPress: () {
                                  HapticFeedback.mediumImpact();
                                  board.setData(
                                      ClipboardData(text: inviteCode.code));
                                  showMessage("招待コードをコピーしました");
                                },Clip
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: DottedBorder(
                                    color: me.canvasTheme
                                        .boxTextColor, //color of dotted/dash line
                                    strokeWidth: 3, //thickness of dash/dots
                                    dashPattern: const [24, 8],
                                    radius: const Radius.circular(8),
                                    borderType: BorderType.RRect,
                                    child: Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          inviteCode.code,
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: me.canvasTheme
                                                .boxSecondaryTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  FutureBuilder(
                    future: ref
                        .read(allUsersNotifierProvider.notifier)
                        .getUserAccounts(inviteCode.slot),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }
        
                      final users = snapshot.data!;
                      const imageHeight = 48.0;
                      return SizedBox(
                        height: imageHeight + 8.4,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12 - 4),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return UserIcon(
                              user:user,
                              width: imageHeight,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 48,
                  ),
                ],
              ),
            ),
          */
          ],
        ),
      ),
    );
  }
}
