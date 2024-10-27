import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/muted_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class MutesScreen extends ConsumerWidget {
  const MutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final mutes = ref.watch(mutesListNotifierProvider).asData?.value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ミュートしたユーザー",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: FutureBuilder(
        future:
            ref.watch(allUsersNotifierProvider.notifier).getUserAccounts(mutes),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text("ミュートしたユーザーはいません。"),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                  UserIcon(
                            user: user,
                            width: 48,
                            isCircle: true,
                          ),
                    const Gap(12),
                    Text(user.username),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        
                        ref
                            .read(mutesListNotifierProvider.notifier)
                            .unMuteUser(user);
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
                        child: const Text(
                          "ミュートを解除",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
