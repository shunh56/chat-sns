// Flutter imports:
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/state/report_form.dart';
import 'package:app/usecase/report_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ReportUserScreen extends ConsumerWidget {
  const ReportUserScreen(
    this.user, {
    super.key,
  });
  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final form = ref.watch(userReportFormProvider(user.userId));
    //
    final reason = ref.watch(userReportFormReasonProvider);
    final reasonNotifier = ref.read(userReportFormReasonProvider.notifier);
    final message = ref.watch(userReportFormMessageProvider);
    final messageNotifier = ref.read(userReportFormMessageProvider.notifier);

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "ユーザーを報告",
            style: textStyle.appbarText(japanese: true),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserIcon(user: user),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: textStyle.w600(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "@${user.username}",
                        style: textStyle.w600(
                          fontSize: 14,
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(32),
              Text(
                "報告内容を入力してください",
                style: textStyle.w600(),
              ),
              const Gap(16),
              Text(
                "報告理由",
                style: textStyle.w600(),
              ),
              Text(
                "下記から該当する報告理由を選択してください",
                style: textStyle.w600(),
              ),
              const Gap(24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: ThemeColor.accent,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                "報告理由を選択してください",
                                style: textStyle.w600(),
                              ),
                            ),
                            const Gap(12),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state = ReportReason.adult;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "アダルト",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state = ReportReason.harassment;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "嫌がらせ行為",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state =
                                    ReportReason.dangerousAct;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "危険行為",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state =
                                    ReportReason.meetingPurpose;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "出会い目的",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state =
                                    ReportReason.sexualHarassment;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "セクハラ",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state =
                                    ReportReason.invasionOfPrivacy;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "プライバシー侵害",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state =
                                    ReportReason.scamOrCommercialPurpose;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "詐欺/営利目的の行為",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                reasonNotifier.state = ReportReason.other;

                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "その他の違反行為",
                                  style: textStyle.w600(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: reason == null ? ThemeColor.stroke : Colors.pink,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: reason != null
                      ? Text(
                          ReportReasonConverter.toJpText(reason),
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          "選択してください",
                          style: textStyle.w600(),
                        ),
                ),
              ),
              const Gap(32),
              Text(
                "詳細",
                style: textStyle.w600(),
              ),
              const Gap(8),
              TextField(
                minLines: 4,
                maxLines: 10,
                cursorColor: ThemeColor.text,
                style: textStyle.w600(),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    messageNotifier.state = text;
                  } else {
                    messageNotifier.state = null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  hintText: "詳細を入力してください。",
                  hintStyle: textStyle.w600(
                    color: ThemeColor.subText,
                  ),
                  fillColor: ThemeColor.stroke,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
              ),
              const Expanded(child: SizedBox()),
              Center(
                child: Material(
                  borderRadius: BorderRadius.circular(100),
                  color: form.isReady ? Colors.pink : ThemeColor.stroke,
                  child: InkWell(
                    // splashColor: black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100.0),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(userReportFormUserIdProvider.notifier).state =
                          user.userId;
                      if (reason == null) {
                        showMessage("報告理由が選択されていません。");
                        return;
                      }
                      if (message == null) {
                        showMessage("報告理由の詳細を記入してください。");
                        return;
                      }

                      ref.read(reportUsecaseProvider).reportUser(form);

                      Navigator.pop(context);
                      /*  SlackApiMethods.sendUserReport(
                          "${DateTime.now().toString().substring(0, 19)}\nFrom: ${me.name} (id:${me.userId})\nTo : ${user.name} (id:${user.userId})\nReason : ${ReportReasonFactoryImpl().toJpText(reason!)}\nMessage : ${reportForm["message"]}");
                      */
                      showMessage(
                          "ユーザーへの報告が完了しました。コミュニティ改善へのご協力ありがとうございます。", 2400);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        "報告する",
                        style: textStyle.w600(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: kToolbarHeight,
              )
            ],
          ),
        ),
      ),
    );
  }
}
