import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class BlockedProfileScreen extends ConsumerWidget {
  const BlockedProfileScreen({
    super.key,
    required this.user,
    required this.state,
  });
  final UserAccount user;
  final String state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    //final requests = ref.watch(requestIdsProvider);
    final requesteds = []; // ref.watch(requestedIdsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileCard(context, ref),
            if (state == "blocked") ...[
              _buildBlockedInfoCard(),
            ],
            const Expanded(child: SizedBox()),
            if (requesteds.contains(user.userId))
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white.withOpacity(0.1),
                    child: InkWell(
                      splashColor: Colors.black.withOpacity(0.3),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        /*ref
                            .read(deletesIdListNotifierProvider.notifier)
                            .deleteUser(user); */
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          "フレンドリクエストを削除",
                          style: textStyle.w600(
                            fontSize: 14,
                            color: ThemeColor.text,
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
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state == "blocked")
            _buildBlockStatusBanner(
              color: ThemeColor.background,
              iconColor: Colors.red,
              title: 'このユーザーにブロックされています',
              subtitle: 'プロフィールを閲覧できません',
            )
          else if (state == "block")
            _buildBlockStatusBanner(
              color: ThemeColor.background,
              iconColor: Colors.red,
              title: 'このユーザーをブロックしています',
              subtitle: 'ブロックを解除すると、メッセージのやり取りが可能になります',
            ),
          const Gap(16),
          _buildUserInfo(),
          if (state == "block") ...[
            const Gap(16),
            _buildUnblockButton(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildBlockStatusBanner({
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: iconColor,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Stack(
          children: [
            UserIcon(
              user: user,
              width: 72,
              navDisabled: true,
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  //color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block,
                  color: Colors.black.withOpacity(0.7),
                  size: 60,
                ),
              ),
            ),
          ],
        ),
        const Gap(16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUnblockButton(
    BuildContext context,
    WidgetRef ref,
  ) {
    return OutlinedButton(
      onPressed: () => _showUnblockDialog(context, ref),
      child: const Text('ブロックを解除する'),
    );
  }

  Widget _buildBlockedInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ブロックされているユーザーについて',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(
                  'このユーザーからブロックされているため、以下の機能が制限されています：',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Gap(8),
                ...['プロフィールの詳細表示', 'メッセージの送信', '投稿の閲覧'].map((text) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUnblockDialog(BuildContext context, WidgetRef ref) async {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.background,
        title: Text(
          'ブロックを解除しますか？',
          style: textStyle.w600(
            fontSize: 18,
          ),
        ),
        content: Text(
          'ブロックを解除すると、このユーザーとの以下の機能が再び利用可能になります：\n\n'
          '- メッセージのやり取り\n'
          '- グループチャットでの接触\n'
          '- プロフィールの完全表示',
          style: textStyle.w400(
            color: ThemeColor.subText,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ブロックを解除する'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (context.mounted) {
        await ref.read(blocksListNotifierProvider.notifier).unblockUser(user);
      }
    }
  }
}
