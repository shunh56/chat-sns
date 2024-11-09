import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/usecase/report_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

enum ContactType {
  feature,
  improvement,
  question,
  other,
}

class ContactTypeConverter {
  static String toJpText(ContactType type) {
    switch (type) {
      case ContactType.feature:
        return "新機能の提案";
      case ContactType.improvement:
        return "既存機能の改善提案";
      case ContactType.question:
        return "使い方の質問";
      case ContactType.other:
        return "その他のお問い合わせ";
    }
  }
}

final contactTypeProvider = StateProvider<ContactType?>((ref) => null);
final contactMessageProvider = StateProvider.autoDispose<String>((ref) => "");
final controllerProvider = Provider((ref) => TextEditingController());

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final typeNotifier = ref.read(contactTypeProvider.notifier);
    final type = ref.watch(contactTypeProvider);

    final controller = ref.read(controllerProvider);
    final message = ref.watch(contactMessageProvider);

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "要望・お問い合わせ",
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
                "お問い合わせ内容を入力してください",
                style: textStyle.w600(),
              ),
              const Gap(16),
              Text(
                "お問い合わせ種類",
                style: textStyle.w600(),
              ),
              Text(
                "下記から該当する種類を選択してください",
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
                                "お問い合わせ種類を選択してください",
                                style: textStyle.w600(),
                              ),
                            ),
                            const Gap(12),
                            const Divider(
                              thickness: 1,
                              color: ThemeColor.stroke,
                            ),
                            _buildTypeOption(
                              context,
                              "新しい機能の提案",
                              "新機能の追加についての提案",
                              ContactType.feature,
                              typeNotifier,
                              textStyle,
                            ),
                            _buildTypeOption(
                              context,
                              "既存機能の改善提案",
                              "現在の機能をより良くするためのアイデア",
                              ContactType.improvement,
                              typeNotifier,
                              textStyle,
                            ),
                            _buildTypeOption(
                              context,
                              "使い方の質問",
                              "アプリの使い方や機能についての質問",
                              ContactType.question,
                              typeNotifier,
                              textStyle,
                            ),
                            _buildTypeOption(
                              context,
                              "その他のお問い合わせ",
                              "上記以外のお問い合わせ",
                              ContactType.other,
                              typeNotifier,
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
                    color: type == null ? ThemeColor.stroke : Colors.blue,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: type != null
                      ? Text(
                          ContactTypeConverter.toJpText(type),
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
                  ref.read(contactMessageProvider.notifier).state = value;
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
                  hintText: _getHintText(type),
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
                  color: (type != null && message.isNotEmpty)
                      ? Colors.blue
                      : ThemeColor.stroke,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100.0),
                    onTap: () {
                      if (type == null) {
                        showMessage("お問い合わせ種類を選択してください。");
                        return;
                      }
                      if (message.isEmpty) {
                        showMessage("詳細を記入してください。");
                        return;
                      }

                      // 送信処理を実装
                      ref.read(reportUsecaseProvider).reportForm(
                            type: ContactTypeConverter.toJpText(type),
                            description: message,
                          );
                      controller.clear();
                      Navigator.pop(context);
                      showMessage("お問い合わせありがとうございます。内容を確認させていただきます。", 2400);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Text(
                        "送信する",
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

  Widget _buildTypeOption(
    BuildContext context,
    String title,
    String description,
    ContactType type,
    StateController<ContactType?> notifier,
    ThemeTextStyle textStyle,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            notifier.state = type;
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(
                  title,
                  style: textStyle.w600(),
                ),
                Text(
                  description,
                  style: textStyle.w400(
                    fontSize: 12,
                    color: ThemeColor.subText,
                  ),
                ),
              ],
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

  String _getHintText(ContactType? type) {
    switch (type) {
      case ContactType.feature:
        return "どのような新機能が欲しいか、具体的に教えてください。";
      case ContactType.improvement:
        return "現在の機能のどのような点を改善したいか、具体的に教えてください。";
      case ContactType.question:
        return "ご不明な点について、具体的に教えてください。";
      case ContactType.other:
        return "お問い合わせ内容を具体的に記入してください。";
      default:
        return "詳細を入力してください。";
    }
  }
}
