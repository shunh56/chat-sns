import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class InputNameScreen extends ConsumerWidget {
  const InputNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final name = ref.watch(nameProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Text(
            "あなたのお名前を\n教えてください",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
              height: 1.4,
            ),
          ),
          const Gap(32),
          Container(
            decoration: BoxDecoration(
              color: ThemeColor.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColor.stroke),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              initialValue: name,
              autofocus: true,
              textAlign: TextAlign.center,
              maxLength: 16,
              style: const TextStyle(
                fontSize: 20,
                color: ThemeColor.text,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: "名前を入力",
                hintStyle: TextStyle(
                  color: ThemeColor.textTertiary,
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                ref.read(nameProvider.notifier).state = value;
              },
            ),
          ),
          const Spacer(flex: 2),
          ElevatedButton(
            onPressed: name.isEmpty ? null : () {
              ref.read(pageControllerProvider).nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primary,
              foregroundColor: ThemeColor.text,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "次へ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}