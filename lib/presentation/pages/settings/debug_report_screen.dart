// lib/screens/debug_report_screen.dart

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/domain/usecases/report_usecase.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final controllerProvider = Provider((ref) => TextEditingController());
final descriptionProvider = StateProvider.autoDispose<String>((ref) => "");

class DebugReportScreen extends ConsumerWidget {
  const DebugReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final reasonNotifier = ref.read(debugReportReasonProvider.notifier);
    final reason = ref.watch(debugReportReasonProvider);

    final controller = ref.read(controllerProvider);
    final description = ref.watch(descriptionProvider);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "バグを報告",
            style: textStyle.appbarText(japanese: true),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            _buildReasonOption(
                              context,
                              "アプリがクラッシュする",
                              DebugReportReason.crash,
                              reasonNotifier,
                              textStyle,
                            ),
                            _buildReasonOption(
                              context,
                              "画面表示の不具合",
                              DebugReportReason.uiIssue,
                              reasonNotifier,
                              textStyle,
                            ),
                            _buildReasonOption(
                              context,
                              "機能が正常に動作しない",
                              DebugReportReason.functionalIssue,
                              reasonNotifier,
                              textStyle,
                            ),
                            _buildReasonOption(
                              context,
                              "パフォーマンスの問題",
                              DebugReportReason.performance,
                              reasonNotifier,
                              textStyle,
                            ),
                            _buildReasonOption(
                              context,
                              "その他の問題",
                              DebugReportReason.other,
                              reasonNotifier,
                              textStyle,
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
                    color: reason == null ? ThemeColor.stroke : Colors.blue,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: reason != null
                      ? Text(
                          DebugReportReasonConverter.toJpText(reason),
                          style: textStyle.w600(
                            fontSize: 14,
                            color: Colors.white,
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
                controller: controller,
                minLines: 4,
                maxLines: 10,
                cursorColor: ThemeColor.text,
                style: textStyle.w600(),
                onChanged: (value) {
                  ref.read(descriptionProvider.notifier).state = value;
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
                  color: (reason != null && description.isNotEmpty)
                      ? Colors.blue
                      : ThemeColor.stroke,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100.0),
                    onTap: () {
                      if (reason == null) {
                        showMessage("報告理由が選択されていません。");
                        return;
                      }
                      if (description.isEmpty) {
                        showMessage("報告理由の詳細を記入してください。");
                        return;
                      }

                      // 報告処理を実装
                      ref.read(reportUsecaseProvider).reportBug(
                            reason: DebugReportReasonConverter.toJpText(reason),
                            description: description,
                          );
                      controller.clear();
                      Navigator.pop(context);
                      showMessage("バグ報告ありがとうございます。改善に向けて対応いたします。", 2400);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        "報告する",
                        style: textStyle.w600(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonOption(
    BuildContext context,
    String text,
    DebugReportReason reason,
    StateController<DebugReportReason?> notifier,
    ThemeTextStyle textStyle,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            notifier.state = reason;
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              text,
              style: textStyle.w600(),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          color: ThemeColor.stroke,
        ),
      ],
    );
  }
}

// 列挙型の定義
enum DebugReportReason {
  crash,
  uiIssue,
  functionalIssue,
  performance,
  other,
}

// 列挙型の変換クラス
class DebugReportReasonConverter {
  static String toJpText(DebugReportReason reason) {
    switch (reason) {
      case DebugReportReason.crash:
        return "アプリがクラッシュする";
      case DebugReportReason.uiIssue:
        return "画面表示の不具合";
      case DebugReportReason.functionalIssue:
        return "機能が正常に動作しない";
      case DebugReportReason.performance:
        return "パフォーマンスの問題";
      case DebugReportReason.other:
        return "その他の問題";
    }
  }
}

// Provider
final debugReportReasonProvider =
    StateProvider<DebugReportReason?>((ref) => null);
