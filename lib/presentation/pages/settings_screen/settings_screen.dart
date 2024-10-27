import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/bottom_sheets/user_bottomsheet.dart';
import 'package:app/presentation/pages/profile_page/invite_code_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/settings_screen/account_settings/account_screen.dart';
import 'package:app/presentation/pages/settings_screen/notification_settings/current_status_posts_screen.dart';
import 'package:app/presentation/pages/settings_screen/notification_settings/direct_messages_screen.dart';
import 'package:app/presentation/pages/settings_screen/notification_settings/friend_requests_screen.dart';
import 'package:app/presentation/pages/settings_screen/notification_settings/posts_screen.dart';
import 'package:app/presentation/pages/settings_screen/notification_settings/voice_chats_screen.dart';
import 'package:app/presentation/pages/settings_screen/privacy_settings/contents_publicity_screen.dart';
import 'package:app/presentation/pages/settings_screen/privacy_settings/friend_requests_screen.dart';
import 'package:app/presentation/pages/settings_screen/privacy_settings/private_mode_screen.dart';
import 'package:app/presentation/phase_01/friend_requesteds_screen.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final me = ref.watch(myAccountNotifierProvider).asData!.value;
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
              _buildTile(
                context,
                _tileContent(
                  Icons.people_outline_rounded,
                  "フレンド申請",
                ),
                page: const FriendRequestedsScreen(),
              ),
              _buildBottomTile(
                context,
                _tileContent(
                  Icons.confirmation_num_outlined,
                  "招待コード",
                ),
                page: const InviteCodeScreen(),
              ),
            ],
          ),
          const Gap(32),
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
              _buildTile(
                context,
                _tileContent(Icons.public_rounded, "コンテンツの公開範囲"),
                page: const ContentRangeScreen(),
                function: () {
                  ref.read(privacyProvider.notifier).state = me.privacy;
                },
              ),
              _buildBottomTile(
                context,
                _tileContent(Icons.people_outline_rounded, "フレンド申請"),
                page: const RequestRangeScreen(),
                function: () {
                  ref.read(privacyProvider.notifier).state = me.privacy;
                },
              ),
            ],
          ),
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
              _buildTile(
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
              ),
              _buildBottomTile(
                context,
                _tileContent(Icons.people_outline_rounded, "フレンド申請"),
                page: const FriendRequestNotificationScreen(),
                function: () {
                  ref.read(notificationDataProvider.notifier).state =
                      me.notificationData;
                },
              ),
            ],
          ),
          const Gap(32),
          _buildContainer(
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
          const Gap(32),
          _buildContainer(
            "新着情報",
            [
              _buildTopTile(
                context,
                _tileContent(Icons.newspaper_rounded, "新着情報"),
              ),
              _buildBottomTile(
                context,
                _tileContent(Icons.info_outline_rounded, "About Us",
                    showArrow: false),
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
        ],
      ),
    );
  }

  Widget _tileContent(
    IconData icon,
    String text, {
    bool showArrow = true,
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
          if (showArrow)
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
              

              if (page != null) {
                if (function != null) {
                  function();
                }
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
              
              if (page != null) {
                if (function != null) {
                  function();
                }
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
          
          if (page != null) {
            if (function != null) {
              function();
            }
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
}
