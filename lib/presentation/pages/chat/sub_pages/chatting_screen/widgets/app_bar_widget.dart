import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/follow/followers_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/voice_chat/voice_chat_screen.dart';
import 'package:app/presentation/providers/users/blocks_list.dart';
import 'package:app/domain/usecases/voip_usecase.dart';

/// チャット画面のアプリバーウィジェット
class ChatAppBar extends ConsumerWidget {
  final UserAccount user;

  const ChatAppBar({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          title: Row(
            children: [
              // ユーザーアイコン（タップでプロフィールへ）
              UserIcon(
                user: user,
                r: 18,
              ),
              const SizedBox(width: 8),

              // ユーザー情報
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(4),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: ThemeColor.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      // バッジステータス表示
                      user.greenBadge
                          ? Text(
                              user.badgeStatus,
                              style: textStyle.w400(
                                fontSize: 11,
                                color: Colors.green,
                              ),
                            )
                          : Text(
                              user.badgeStatus,
                              style: textStyle.w400(
                                fontSize: 11,
                                color: ThemeColor.subText,
                              ),
                            )
                    ],
                  ),
                ),
              ),

              // 通話ボタン
              GestureDetector(
                onTap: () => _handleCallButtonTap(context, ref),
                child: const Icon(Icons.phone),
              ),
              Gap(themeSize.horizontalPadding)
            ],
          ),
        ),
        const Gap(4),
        Divider(
          height: 0,
          color: Colors.white.withOpacity(0.2),
          thickness: 0.4,
        ),
      ],
    );
  }

  /// 通話ボタンタップ時の処理
  Future<void> _handleCallButtonTap(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();

    final isFollowing = ref.watch(isFollowerProvider(user.userId));
    final isFollowed = ref.watch(isFollowerProvider(user.userId));
    final isMutualFollow = isFollowing && isFollowed;

    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final filters = blocks + blockeds;

    if (filters.contains(user.userId)) {
      showMessage("エラーが起きました。");
      return;
    }

    //TODO
    if (isMutualFollow || true) {
      final vc = await ref.read(voipUsecaseProvider).callUser(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceChatScreen(id: vc.id),
        ),
      );
    }
  }
}
