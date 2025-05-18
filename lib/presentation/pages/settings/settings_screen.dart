import 'package:app/core/utils/flavor.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/main.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/settings/account_settings/account_screen.dart';
import 'package:app/presentation/pages/settings/contact_screen.dart';
import 'package:app/presentation/pages/settings/debug_report_screen.dart';
import 'package:app/presentation/pages/settings/notification_settings/direct_messages_screen.dart';
import 'package:app/presentation/pages/settings/notification_settings/friend_requests_screen.dart';
import 'package:app/presentation/pages/version/version_manager.dart';
import 'package:app/presentation/providers/theme_provider.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final me = ref.watch(myAccountNotifierProvider).asData?.value;

    if (me == null) return const Scaffold();

    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: ThemeColor.icon,
        ),
        title: const Text(
          "設定",
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
          _buildContainer(
            "アカウント設定",
            [
              _buildTopTile(
                context,
                _tileContent(
                  Icons.person_outline_rounded,
                  "アカウント",
                ),
                page: const AccountScreen(),
              ),
              /*  _buildTile(
                context,
                _tileContent(
                  Icons.people_outline_rounded,
                  "フレンド申請",
                ),
                page: const FriendRequestedsScreen(),
              ), */
              /*_buildBottomTile(
                context,
                _tileContent(
                  Icons.confirmation_num_outlined,
                  "招待コード",
                ),
                page: const InviteCodeScreen(),
              ), */
            ],
          ),
          /* const Gap(32),
          _buildContainer(
            "招待",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.lock_outline, "機能の解放"),
                page: const MileStoneScreen(),
              ),
              _buildBottomTile(
                context,
                _tileContent(Icons.confirmation_num_outlined, "招待コートを使用"),
                page: const UseInviteCodeScreen(),
              ),
            ],
          ), */
          /*const Gap(32),
          _buildContainer(
            "プライバシー設定",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.lock_outline_rounded, "プライベートモード"),
                page: const PrivateModeScreen(),
                function: () {
                  ref.read(privacyProvider.notifier).state = me.privacy;
                },
              ),
              /*
              _buildTile(
                context,
                _tileContent(Icons.public_rounded, "プロフィールの公開範囲"),
              ),*/
              /*  _buildTile(
                context,
                _tileContent(Icons.public_rounded, "コンテンツの公開範囲"),
                page: const ContentRangeScreen(),
                function: () {
                  ref.read(privacyProvider.notifier).state = me.privacy;
                },
              ), */
              _buildBottomTile(
                context,
                _tileContent(Icons.people_outline_rounded, "フレンド申請"),
                page: const RequestRangeScreen(),
                function: () {
                  ref.read(privacyProvider.notifier).state = me.privacy;
                },
              ),
            ],
          ), */
          const Gap(32),
          _buildContainer(
            "通知設定",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.chat_bubble_outline_outlined, "ダイレクトメッセージ"),
                page: const DirectMessageNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ),
              /* _buildTile(
                context,
                _tileContent(Icons.post_add_rounded, "ステータス投稿"),
                page: const CurrentStatusPostNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ),
              _buildTile(
                context,
                _tileContent(Icons.post_add_rounded, "投稿"),
                page: const PostNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ),
              _buildTile(
                context,
                _tileContent(Icons.graphic_eq_rounded, "ボイスチャット"),
                page: const VoiceChatNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ), */
              _buildBottomTile(
                context,
                _tileContent(Icons.people_outline_rounded, "フォロー"),
                page: const FriendRequestNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ),
            ],
          ),
          /*const Gap(32),
          _buildContainer(
            "表示設定",
            [
              _buildTopTile(
                context,
                _tileContent(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  "ダークモード",
                  showArrow: false,
                  trailing: SizedBox(
                    height: 28,
                    child: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        if (true) {
                          //TODO  Currently Only Dark Mode
                          ref.read(isDarkModeProvider.notifier).state = value;
                        }
                      },
                      trackOutlineColor: WidgetStateColor.transparent,
                      inactiveTrackColor: ThemeColor.stroke,
                      inactiveThumbColor: Colors.white,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              _buildBottomTile(
                context,
                _tileContent(
                  Icons.font_download_outlined,
                  "フォントサイズ",
                ),
                // フォントサイズ設定画面への遷移はここに実装
              ),
            ],
          ), */
          const Gap(32),
          /*  _buildContainer(
            "サブスクリプション設定",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.sync_outlined, "サブスクリプションを復元"),
              ),
              _buildTile(
                context,
                _tileContent(Icons.payment_rounded, "サブスクリプションを購入"),
              ),
              _buildBottomTile(
                context,
                _tileContent(Icons.wallet_giftcard_rounded, "サブスクリプションをギフト"),
              ),
            ],
          ),
          const Gap(32), */
          _buildContainer(
            "新着情報",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.newspaper_rounded, "新着情報"),
                function: () {
                  launchUrl(
                    Uri.parse("https://blank-pj.vercel.app"),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              _buildBottomTile(
                context,
                _tileContent(
                  Icons.info_outline_rounded,
                  "About Us",
                  showArrow: false,
                ),
                function: () {
                  launchUrl(
                    Uri.parse("https://blank-pj.vercel.app"),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ],
          ),
          const Gap(32),
          _buildContainer(
            "アプリ改善",
            [
              _buildTopTile(
                context,
                _tileContent(
                  Icons.bug_report_outlined,
                  "バグを報告",
                ),
                function: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DebugReportScreen(),
                    ),
                  );
                },
              ),
              _buildBottomTile(
                context,
                _tileContent(
                  Icons.question_answer_outlined,
                  "要望・お問い合わせ",
                ),
                function: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(32),
          Material(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                UserBottomModelSheet(context).signoutBottomSheet(me);
              },
              child: _tileContent(Icons.logout_rounded, "サインアウト",
                  showArrow: false),
            ),
          ),
          const Gap(32),
          _infoFooter(context, ref),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _tileContent(
    IconData icon,
    String text, {
    bool showArrow = true,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ThemeColor.white,
                ),
                const Gap(8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ThemeColor.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else if (showArrow)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ThemeColor.white,
              size: 16,
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

  Widget _buildTopTile(BuildContext context, Widget child,
      {Widget? page, Function? function}) {
    return Column(
      children: [
        Material(
          color: ThemeColor.accent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            onTap: () {
              if (function != null) {
                function();
              }
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              }
            },
            child: child,
          ),
        ),
        Divider(
          height: 0,
          color: ThemeColor.white.withOpacity(0.5),
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, Widget child,
      {Widget? page, Function? function}) {
    return Column(
      children: [
        Material(
          color: ThemeColor.accent,
          child: InkWell(
            onTap: () {
              if (function != null) {
                function();
              }
              if (page != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
              }
            },
            child: child,
          ),
        ),
        Divider(
          height: 0,
          color: ThemeColor.white.withOpacity(0.5),
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildBottomTile(BuildContext context, Widget child,
      {Widget? page, Function? function}) {
    return Material(
      color: ThemeColor.accent,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        onTap: () {
          if (function != null) {
            function();
          }
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        child: child,
      ),
    );
  }

  Widget _infoFooter(BuildContext context, WidgetRef ref) {
    return FutureBuilder<VersionStatus>(
      future: ref.watch(versionStatusProvider.future),
      builder: (context, versionSnapshot) {
        return FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final info = snapshot.data!;
            final isUpdateAvailable =
                versionSnapshot.data == VersionStatus.updateAvailable;
            final isUpdateRequired =
                versionSnapshot.data == VersionStatus.requiresUpdate;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/icon_circle_bg_white.png',
                      height: 24,
                      width: 24,
                    ),
                    const Gap(8),
                    Text(
                      info.appName,
                      style: const TextStyle(
                        color: ThemeColor.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Version ${info.version}",
                      style: TextStyle(
                        color: ThemeColor.text.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    if (isUpdateAvailable || isUpdateRequired) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isUpdateRequired ? Colors.red : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isUpdateRequired ? "アップデートが必要です" : "新しいバージョンがあります",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!Flavor.isAppStoreEnv) ...[
                  const Gap(4),
                  Text(
                    info.packageName,
                    style: TextStyle(
                      color: ThemeColor.text.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
