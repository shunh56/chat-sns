/*import 'package:app/presentation/pages/playground_page/widgets/freechat_feed.dart';
import 'package:app/presentation/pages/playground_page/widgets/imahima_feed.dart';
import 'package:app/presentation/pages/playground_page/widgets/top_bar.dart';
import 'package:app/presentation/providers/provider/users/hima_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PlaygroundScreen extends ConsumerWidget {
  const PlaygroundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(himaUserIdListNotifierProvider.notifier).refresh();
          },
          child: const Column(
            children: [
              Gap(8),
              TopBar(),
              //Gap(8),
              //VoiceRoomFeed(),
              Gap(24),
              HimaUsersFeed(),
              Gap(24),
              Expanded(child: FreeChatFeed()),
              Gap(12),
            ],
          ),
        ),
      ),
    );
  }
}
 */