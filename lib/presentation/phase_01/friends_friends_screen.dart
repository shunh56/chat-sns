import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsFriendsScreen extends ConsumerWidget {
  const FriendsFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(friendsFriendListNotifierProvider);
    final requesteds =
        ref.watch(friendRequestedIdListNotifierProvider).asData?.value ?? [];

    final listView = asyncValue.when(
      data: (list) {
        final users =
            list.where((user) => !requesteds.contains(user.userId)).toList();
        if (users.isEmpty) {
          return const Center(
            child: Text("おすすめのユーザーはいません"),
          );
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
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
          "おすすめのユーザー",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: listView,
    );
  }
}
