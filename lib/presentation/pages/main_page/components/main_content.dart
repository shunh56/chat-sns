import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../chat/chat_screen.dart';
import '../../profile/profile_page.dart';
import '../../search/search_users_screen.dart';
import '../../posts/timeline/timeline_page.dart';
import '../providers/main_page_state_notifier.dart';

/// メインページのコンテンツ表示
class MainContent extends ConsumerWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainPageStateProvider.select((state) => state.currentIndex));

    return IndexedStack(
      index: currentIndex,
      children: const [
        SearchUsersScreen(),
        TimelinePage(),
        ChatScreen(),
        ProfileScreen(),
      ],
    );
  }
}