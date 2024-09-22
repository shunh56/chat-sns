import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/settings_screen/account_settings/sub/blocks_screen.dart';
import 'package:app/presentation/pages/settings_screen/account_settings/sub/mutes_screen.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/muted_list.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final ascyncValue = ref.watch(myAccountNotifierProvider);

    final accountInfo = ascyncValue.when(
      data: (me) {
        final username = me.username;
        final createdAt = me.createdAt.toDateStr;
        return _buildContainer(
          "アカウント情報",
          [
            _buildTopTile("ユーザー名", username),
            _buildBottomTile("メンバーになった日", createdAt),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    final blocks = ref.watch(blocksListNotifierProvider);
    final mutes = ref.watch(mutesListNotifierProvider);
    final blockInfo = blocks.when(
      data: (blocks) {
        return mutes.when(
          data: (mutes) {
            return _buildContainer("ユーザー", [
              _buildTopButtonTile(
                context,
                "ブロックしたユーザー",
                blocks.length.toString(),
                page: const BlocksScreen(),
              ),
              _buildBottomButtonTile(
                context,
                "ミュートしたユーザー",
                mutes.length.toString(),
                page: const MutesScreen(),
              ),
            ]);
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    final auth = ref.watch(authProvider);

    final authInfo = _buildContainer(
      "認証情報",
      [
        _buildTopTile("メールアドレス", auth.currentUser!.email ?? "no email"),
        Material(
          color: ThemeColor.accent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              try {
                auth.currentUser!.updateEmail("");
              } catch (e) {
                showMessage("error : $e");
              }
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: const BoxDecoration(),
              child: const Row(
                children: [
                  Text("メールアドレスを変更する"),
                ],
              ),
            ),
          ),
        ),
        const Divider(
          height: 0,
          color: ThemeColor.beige,
          thickness: 0.2,
        ),
        Material(
          color: ThemeColor.accent,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              try {
                auth.currentUser!.updatePassword("");
              } catch (e) {
                showMessage("error : $e");
              }
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: const BoxDecoration(),
              child: const Row(
                children: [
                  Text(
                    "パスワードを変更する",
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: ThemeColor.icon,
        ),
        title: const Text(
          "アカウント",
          style: TextStyle(
            fontSize: 16,
            color: ThemeColor.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: themeSize.horizontalPadding,
        ),
        children: [
          accountInfo,
          const Gap(32),
          if (kDebugMode)
            Column(
              children: [
                authInfo,
                const Gap(32),
              ],
            ),
          blockInfo,
          const Gap(32),
          _buildContainer(
            "アカウント管理",
            [
              Material(
                color: ThemeColor.accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    ref.read(myAccountNotifierProvider.notifier).onClosed();
                    Navigator.popUntil(context, (route) => route.isFirst);
                    await Future.delayed(const Duration(milliseconds: 30));
                    ref.watch(authProvider).signOut();
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    decoration: const BoxDecoration(),
                    child: const Row(
                      children: [
                        Text("アカウントからサインアウト"),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 0,
                color: ThemeColor.beige,
                thickness: 0.2,
              ),
              Material(
                color: ThemeColor.accent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    decoration: const BoxDecoration(),
                    child: const Row(
                      children: [
                        Text(
                          "アカウントを削除する",
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const Gap(4),
        ...children,
      ],
    );
  }

  Widget _buildTopTile(String title, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: const BoxDecoration(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(text),
            ],
          ),
        ),
        const Divider(
          height: 0,
          color: ThemeColor.beige,
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildTile(String title, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: const BoxDecoration(
            color: ThemeColor.accent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(text),
            ],
          ),
        ),
        const Divider(
          height: 0,
          color: ThemeColor.beige,
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildBottomTile(String title, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: const BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTopButtonTile(BuildContext context, String title, String text,
      {Widget? page}) {
    return Column(
      children: [
        Material(
          color: ThemeColor.accent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              }
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title),
                        Text(text),
                      ],
                    ),
                  ),
                  const Gap(8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: ThemeColor.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(
          height: 0,
          color: ThemeColor.beige,
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildBottomButtonTile(BuildContext context, String title, String text,
      {Widget? page}) {
    return Material(
      color: ThemeColor.accent,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: const BoxDecoration(),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title),
                    Text(text),
                  ],
                ),
              ),
              const Gap(8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ThemeColor.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
