import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/values.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/post_text_input.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/post_media_picker.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/post_header.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/hashtag_display.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/post_action_bar.dart';
import 'package:app/presentation/pages/posts/features/post_creation/components/hashtag_dialog.dart';
import 'package:app/presentation/providers/state/create_post/post.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';

/// 投稿作成画面（リファクタリング版）
///
/// 機能:
/// - テキスト投稿の作成
/// - 画像・メディアの添付
/// - ハッシュタグの追加
/// - プライバシー設定
/// - リアルタイム投稿状態管理
class CreatePostScreenRefactored extends ConsumerWidget {
  const CreatePostScreenRefactored({
    super.key,
    this.community,
  });

  final dynamic community; // Community? community; // Archived

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);

    return asyncValue.when(
      data: (user) =>
          _buildMainContent(context, ref, user, themeSize, textStyle),
      error: (error, stack) => _buildErrorScaffold(),
      loading: () => _buildLoadingScaffold(),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    dynamic themeSize,
    ThemeTextStyle textStyle,
  ) {
    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: _buildAppBar(ref, textStyle),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            _buildScrollableContent(user),
            PostActionBar(
              onHashtagTap: () => HashtagDialog.show(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref, ThemeTextStyle textStyle) {
    return AppBar(
      elevation: 0,
      title: community != null
          ? Text(
              community!.name,
              style: textStyle.w600(fontSize: 16),
            )
          : const Text(
              '今どうしてる？',
              style: TextStyle(
                color: ThemeColor.text,
                fontWeight: FontWeight.w600,
              ),
            ),
      centerTitle: true,
      actions: [
        if (postPrivacyMode && community == null) _buildPrivacyToggle(ref),
      ],
    );
  }

  Widget _buildPrivacyToggle(WidgetRef ref) {
    return IconButton(
      icon: Icon(
        ref.watch(isPublicProvider)
            ? Icons.public_rounded
            : Icons.lock_outline_rounded,
        color: ThemeColor.highlight,
      ),
      onPressed: () {
        ref.read(isPublicProvider.notifier).state =
            !ref.watch(isPublicProvider);
      },
    );
  }

  Widget _buildScrollableContent(dynamic user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120), // Space for action bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(24),
            PostHeader(user: user),
            const Gap(16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PostTextInput(),
            ),
            const Gap(12),
            const PostMediaPicker(),
            const HashtagDisplay(),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return const Scaffold(
      backgroundColor: ThemeColor.background,
      body: Center(
        child: Text(
          'エラーが発生しました',
          style: TextStyle(color: ThemeColor.text),
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return const Scaffold(
      backgroundColor: ThemeColor.background,
      body: Center(
        child: CircularProgressIndicator(color: ThemeColor.highlight),
      ),
    );
  }
}
