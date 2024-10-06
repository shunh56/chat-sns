import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/domain/entity/invite_code.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/invite_code_usecase.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inviteCodeProvider =
    StateProvider<InviteCode>((ref) => InviteCode.init());

class InviteCodeScreen extends ConsumerWidget {
  const InviteCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final asyncValue = ref.watch(myAccountNotifierProvider);
    final me = ref.watch(myAccountNotifierProvider).asData!.value;
    final myIcon = asyncValue.when(
      data: (me) {
        return UserIcon.tileIcon(
          me,
          width: themeSize.screenWidth * 0.35,
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    getCode() async {
      ref.read(inviteCodeProvider.notifier).state =
          await ref.read(inviteCodeUsecaseProvider).getMyCode();
    }

    final inviteCode = ref.watch(inviteCodeProvider);
    getCode();
    return Scaffold(
      backgroundColor: me.canvasTheme.bgColor,
      appBar: AppBar(
        backgroundColor: me.canvasTheme.bgColor,
        iconTheme: IconThemeData(
          color: me.canvasTheme.profileTextColor,
        ),
      ),
      body: inviteCode.getStatus == InviteCodeStatus.notFound
          ? SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Gap(48),
                  Transform.rotate(
                    angle: -pi / 48,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(12, 18),
                            spreadRadius: 4,
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: DottedBorder(
                        color: Colors.black, //color of dotted/dash line
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
                                  color: Colors.white,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: ThemeColor.background,
                                        ),
                                        child: const Icon(
                                          color: Colors.white,
                                          Icons.confirmation_num_outlined,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: DottedBorder(
                                  color:
                                      Colors.black, //color of dotted/dash line
                                  strokeWidth: 3, //thickness of dash/dots
                                  dashPattern: const [24, 8],
                                  radius: const Radius.circular(8),
                                  borderType: BorderType.RRect,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
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
                  const Expanded(child: SizedBox()),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Material(
                      color: Colors.cyan,
                      child: InkWell(
                        splashColor: Colors.black.withOpacity(0.3),
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          ref.read(inviteCodeProvider.notifier).state =
                              await ref
                                  .read(inviteCodeUsecaseProvider)
                                  .generateInviteCode();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Text(
                            "招待コードを生成",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(60),
                ],
              ),
            )
          : SizedBox(
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
                        color: me.canvasTheme
                            .boxTextColor, //color of dotted/dash line
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: me.canvasTheme.bgColor,
                                        ),
                                        child: Icon(
                                          color:
                                              me.canvasTheme.profileTextColor,
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
                                  Clipboard.setData(
                                      ClipboardData(text: inviteCode.code));
                                  showMessage("招待コードをコピーしました");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
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
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
    );
  }
}
