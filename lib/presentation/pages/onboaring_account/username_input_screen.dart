import 'package:app/core/extenstions/string_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/onboarding_providers.dart';
import 'package:app/domain/usecases/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputUsernameScreen extends ConsumerWidget {
  const InputUsernameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final username = ref.watch(usernameProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Text(
            "ユーザーネームを\n設定してください",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "半角英数字とアンダースコアが使えます",
            style: TextStyle(
              fontSize: 14,
              color: ThemeColor.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: ThemeColor.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColor.stroke),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              initialValue: username,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: ThemeColor.text,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "ユーザーネーム",
                hintStyle: TextStyle(
                  color: ThemeColor.textTertiary,
                  fontSize: 20,
                ),
                prefixText: "@",
                prefixStyle: TextStyle(
                  color: ThemeColor.textSecondary,
                  fontSize: 20,
                ),
              ),
              onChanged: (value) {
                ref.read(usernameProvider.notifier).state = value;
              },
            ),
          ),
          if (!username.isUsername && username.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                username.usernameError ?? "不正なユーザーネームです",
                style: const TextStyle(
                  color: ThemeColor.error,
                  fontSize: 14,
                ),
              ),
            ),
          const Spacer(flex: 2),
          ElevatedButton(
            onPressed: !username.isUsername ? null : () async {
              final alreadyUsed = await ref
                  .read(userUsecaseProvider)
                  .checkUsername(username);
              if (alreadyUsed) {
                showMessage("そのユーザーネームは既に使用されています");
              } else {
                ref.read(pageControllerProvider).nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
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