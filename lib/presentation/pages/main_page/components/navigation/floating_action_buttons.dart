import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/utils/theme.dart';
import '../../../../routes/page_transition.dart';
import '../../../chat/sub_pages/create_chat_screen.dart';
import '../../../posts/create/create_post_screen/create_post_screen.dart';
import '../../constants/tab_constants.dart';
import '../../providers/main_page_state_notifier.dart';

/// メインページのFloating Action Button管理
class MainFloatingActionButtons extends ConsumerWidget {
  const MainFloatingActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainPageStateProvider.select((state) => state.currentIndex));

    return _buildFloatingActionButton(context, currentIndex);
  }

  /// 現在のタブに応じたFloating Action Buttonを構築
  Widget _buildFloatingActionButton(BuildContext context, int currentIndex) {
    switch (currentIndex) {
      case MainPageTabIndex.home:
        return _buildCreatePostFAB(context);
      case MainPageTabIndex.chat:
        return _buildCreateChatFAB(context);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 投稿作成FAB
  Widget _buildCreatePostFAB(BuildContext context) {
    return FloatingActionButton(
      heroTag: "create_post",
      onPressed: () => _navigateToCreatePost(context),
      backgroundColor: ThemeColor.highlight,
      child: const Icon(
        Icons.edit,
        color: ThemeColor.white,
        size: 30,
      ),
    );
  }

  /// チャット作成FAB
  Widget _buildCreateChatFAB(BuildContext context) {
    return FloatingActionButton(
      heroTag: "create_chat",
      onPressed: () => _navigateToCreateChat(context),
      backgroundColor: ThemeColor.highlight,
      child: const Icon(
        Icons.comment_outlined,
        color: ThemeColor.white,
        size: 28,
      ),
    );
  }

  /// 投稿作成画面への遷移
  void _navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      PageTransitionMethods.slideUp(
        const CreatePostScreen(),
      ),
    );
  }

  /// チャット作成画面への遷移
  void _navigateToCreateChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateChatsScreen(),
      ),
    );
  }
}