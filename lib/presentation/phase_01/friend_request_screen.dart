import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestScreen extends ConsumerWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(friendRequestIdListNotifierProvider);
    final listView = asyncValue.when(
      data: (requestIds) {
        if (requestIds.isEmpty) {
          return const Center(
            child: Text("リクエスト済みのユーザーはいません。"),
          );
        }
        return ListView.builder(
          itemCount: requestIds.length,
          itemBuilder: (context, index) {
            String userId = requestIds[index];
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
          "リクエスト済みユーザー",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: listView,
    );
  }
}
