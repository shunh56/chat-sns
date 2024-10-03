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
    final asyncValue = ref.watch(friendRequestedIdListNotifierProvider);
    final listView = asyncValue.when(
      data: (userIds) {
        if (userIds.isEmpty) {
          return const Center(
            child: Text("フレンドリクエストはありません"),
          );
        }
        return ListView.builder(
          itemCount: userIds.length,
          itemBuilder: (context, index) {
            String userId = userIds[index];
            final user =
                ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
            return UserRequestWidget(user: user);
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
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
