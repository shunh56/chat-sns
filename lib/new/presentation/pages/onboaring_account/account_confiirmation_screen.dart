import 'package:app/core/extenstions/string_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/onboarding/providers/providers.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountConfirmScreen extends ConsumerWidget {
  const AccountConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final username = ref.watch(usernameProvider);
    final name = ref.watch(nameProvider);
    final image = ref.watch(imageProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
      child: Column(
        children: [
          const Spacer(),
          const Text(
            "入力内容の確認",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
            ),
          ),
          const SizedBox(height: 32),

          // プロフィール画像
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ThemeColor.surface,
              shape: BoxShape.circle,
              border: Border.all(color: ThemeColor.stroke, width: 2),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 48,
                    color: ThemeColor.textSecondary,
                  ),
          ),
          const SizedBox(height: 32),

          // 入力内容確認リスト
          Container(
            decoration: BoxDecoration(
              color: ThemeColor.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColor.stroke),
            ),
            child: Column(
              children: [
                _buildInfoItem(
                  title: "名前",
                  content: name,
                  onTap: () => _goToPage(ref, 0),
                ),
                const Divider(color: ThemeColor.stroke, height: 1),
                _buildInfoItem(
                  title: "ユーザーネーム",
                  content: "@$username",
                  onTap: () => _goToPage(ref, 1),
                ),
              ],
            ),
          ),
          const Spacer(),

          const SizedBox(height: 16),

          // アカウント作成ボタン
          ElevatedButton(
            onPressed: () async {
              if (username.isUsername && name.isNotEmpty) {
                ref.read(creatingProcessProvider.notifier).state = true;
                try {
                  final alreadyUsed = await ref
                      .read(userUsecaseProvider)
                      .checkUsername(username);
                  if (alreadyUsed) {
                    ref.read(creatingProcessProvider.notifier).state = false;
                    showMessage("そのユーザーネームは既に使用されています");
                    _goToPage(ref, 1);
                    return;
                  }
                  await ref
                      .read(myAccountNotifierProvider.notifier)
                      .createUser(username, name, image, "");

                  ref.read(creatingProcessProvider.notifier).state = false;
                } catch (e) {
                  ref.read(creatingProcessProvider.notifier).state = false;
                  showErrorSnackbar(error: e);
                }
              } else {
                showMessage('必須項目を入力してください');
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
              "アカウントを作成",
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

  Widget _buildInfoItem({
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: ThemeColor.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ThemeColor.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _goToPage(WidgetRef ref, int page) {
    ref.read(pageControllerProvider).animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
  }
}
