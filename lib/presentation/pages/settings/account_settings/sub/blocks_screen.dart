import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/presentation/providers/users/blocks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ブロックしたユーザー",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: FutureBuilder(
        future: ref
            .watch(allUsersNotifierProvider.notifier)
            .getUserAccounts(blocks),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text("ブロックしたユーザーはいません。"),
            );
          }
          return ListView.builder(
            itemCount: users.length,
            padding: EdgeInsets.symmetric(
              horizontal: themeSize.horizontalPadding,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                  
                    UserIcon(
                            user: user,
                            width: 48,
                            isCircle: true,
                          ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "@${user.username}",
                          style: textStyle.w600(
                            color: ThemeColor.subText,
                          ),
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        
                        ref
                            .read(blocksListNotifierProvider.notifier)
                            .unblockUser(user);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue,
                        ),
                        child: Text(
                          "ブロックを解除",
                          style: textStyle.w600(
                            color: ThemeColor.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
