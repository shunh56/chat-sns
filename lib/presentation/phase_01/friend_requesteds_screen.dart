import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestedsScreen extends ConsumerWidget {
  const FriendRequestedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final requesteds = ref.watch(requestedIdsProvider);
    final listView = (requesteds.isEmpty)
        ? const Center(
            child: Text("フレンドリクエストはありません"),
          )
        : ListView.builder(
            itemCount: requesteds.length,
            itemBuilder: (context, index) {
              String userId = requesteds[index];
              final user =
                  ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
              return UserRequestWidget(user: user);
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "フレンドリクエスト",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: listView,
    );
  }
}
