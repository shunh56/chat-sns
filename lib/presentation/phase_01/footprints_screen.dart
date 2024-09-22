import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/footprints_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FootprintsScreen extends ConsumerWidget {
  const FootprintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(footprintsListNotifierProvider);
    final listView = asyncValue.when(
      data: (footprints) {
        if (footprints.isEmpty) {
          return ListView(
            children: const [
              Center(
                child: Text("足あとをつけたユーザーはいません。"),
              ),
            ],
          );
        }
        return ListView.builder(
          itemCount: footprints.length,
          itemBuilder: (context, index) {
            final footprint = footprints[index];
            final userId = footprint.userId;
            final user =
                ref.watch(allUsersNotifierProvider).asData!.value[userId]!;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: ThemeColor.highlight,
                highlightColor: ThemeColor.beige.withOpacity(0.3),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChattingScreen(user: user),
                    ),
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(navigationRouterProvider(context))
                              .goToProfile(user);
                        },
                        child: CachedImage.userIcon(
                            user.imageUrl, user.username, 24),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeColor.text,
                                  ),
                                ),
                                Text(
                                  footprint.updatedAt.xxAgo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ThemeColor.text,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              user.aboutMe,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ThemeColor.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "自分がつけた足あと",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(footprintsListNotifierProvider.notifier).refresh();
        },
        child: listView,
      ),
    );
  }
}
