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
    final friendIds = ref.watch(friendIdsProvider);
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
                              inviteCode.getStatus == InviteCodeStatus.valid ||
                                      inviteCode.getStatus ==
                                          InviteCodeStatus.usedByMe
                                  ? 1
                                  : 0.3,
                          child: Text(
                            inviteCode.id,
                            style: textStyle.w600(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: inviteCode.getStatus ==
                                  InviteCodeStatus.valid ||
                              inviteCode.getStatus == InviteCodeStatus.usedByMe,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: inviteCode.id,
                                ),
                              );
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
                _buildStatusWidget(inviteCode.getStatus, textStyle)
              ],
            ),
            const Gap(24),
            Expanded(
              child: FutureBuilder(
                future: ref
                    .read(allUsersNotifierProvider.notifier)
                    .getUserAccounts(inviteCode.logs
                        .map((e) => e["userId"] as String)
                        .toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || inviteCode.logs.isEmpty) {
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
                          final log = inviteCode.logs.firstWhere(
                              (item) => item["userId"] == user.userId);
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(InviteCodeStatus status, ThemeTextStyle textStyle) {
    switch (status) {
      case InviteCodeStatus.valid:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "有効",
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        );
      case InviteCodeStatus.usedByMe:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "自分の招待コード",
            style: textStyle.w600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        );
      case InviteCodeStatus.overLimit:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      case InviteCodeStatus.unknownError:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  }
}
