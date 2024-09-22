/*import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/sub_pages/hima_users_screen.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/hima_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class HimaUsersFeed extends ConsumerWidget {
  const HimaUsersFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double cardHeight = 48;
    final himaUsersList = ref.watch(himaUserIdListNotifierProvider);
    final listView = himaUsersList.when(
      data: (list) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: list.length + 1,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(himaUserIdListNotifierProvider.notifier)
                            .addMe();
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: ThemeColor.highlight,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: ThemeColor.beige,
                        ),
                      ),
                    ),
                    const Gap(8),
                    const VerticalDivider(
                      width: 1.2,
                      color: ThemeColor.highlight,
                    ),
                  ],
                ),
              );
            }
            final user = ref
                .read(allUsersNotifierProvider)
                .asData!
                .value[list[index - 1]]!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfilePage(user: user),
                    ),
                  );
                },
                child: CachedImage.userIcon(user.imageUrl, user.username, 24),
              ),
            );
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HimaUsersScreen(),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              "いまひま",
              style: TextStyle(
                fontSize: 20,
                color: ThemeColor.headline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const Gap(6),
        SizedBox(
          height: cardHeight,
          child: listView,
        )
      ],
    );
  }
}
 */