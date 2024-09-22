import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final selectedUserIdsStateProvider = StateProvider<List<String>>((ref) => []);

class EditNowWithScreen extends HookConsumerWidget {
  const EditNowWithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final currentStatus = ref.watch(currentStatusStateProvider);
    final currentStatusNotifier =
        ref.watch(currentStatusStateProvider.notifier);
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final friendIds = friendInfos.map((item) => item.userId).toList();
    List users = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => friendIds.contains(user.userId))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "一緒にいる友達を編集",
        ),
        actions: [
          GestureDetector(
            onTap: () {
              currentStatusNotifier.state = currentStatus.copyWith(
                nowWith: ref.watch(selectedUserIdsStateProvider),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "変更する",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(24),
              const Text(
                "選択中の友達",
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Wrap(
                children: users
                    .where((user) => ref
                        .watch(selectedUserIdsStateProvider)
                        .contains(user.userId))
                    .map(
                      (user) => GestureDetector(
                        onTap: () {
                          final list = ref
                              .watch(selectedUserIdsStateProvider)
                              .where((item) => item != user.userId)
                              .toList();

                          ref
                              .read(selectedUserIdsStateProvider.notifier)
                              .state = list;
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: (themeSize.screenWidth -
                                          2 * themeSize.horizontalPadding -
                                          24 -
                                          6 * 8) /
                                      5,
                                  width: (themeSize.screenWidth -
                                          2 * themeSize.horizontalPadding -
                                          24 -
                                          6 * 8) /
                                      5,
                                  child: CachedNetworkImage(
                                    imageUrl: user.imageUrl!,
                                    fadeInDuration:
                                        const Duration(milliseconds: 120),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: (themeSize.screenWidth -
                                              2 * themeSize.horizontalPadding -
                                              24 -
                                              6 * 8) /
                                          5,
                                      width: (themeSize.screenWidth -
                                              2 * themeSize.horizontalPadding -
                                              24 -
                                              6 * 8) /
                                          5,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const SizedBox(),
                                    errorWidget: (context, url, error) =>
                                        const SizedBox(),
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                user.username,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.text,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Gap(24),
              const Text(
                "他の友達",
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Wrap(
                children: users
                    .where((user) => !ref
                        .watch(selectedUserIdsStateProvider)
                        .contains(user.userId))
                    .map(
                      (user) => GestureDetector(
                        onTap: () {
                          if (ref.watch(selectedUserIdsStateProvider).length >=
                              10) {
                            showMessage("10人までしか選択できません。");
                            return;
                          }
                          ref
                              .read(selectedUserIdsStateProvider.notifier)
                              .state = [
                            ...ref.watch(selectedUserIdsStateProvider),
                            user.userId
                          ];
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: (themeSize.screenWidth -
                                          2 * themeSize.horizontalPadding -
                                          24 -
                                          6 * 8) /
                                      5,
                                  width: (themeSize.screenWidth -
                                          2 * themeSize.horizontalPadding -
                                          24 -
                                          6 * 8) /
                                      5,
                                  child: CachedNetworkImage(
                                    imageUrl: user.imageUrl!,
                                    fadeInDuration:
                                        const Duration(milliseconds: 120),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: (themeSize.screenWidth -
                                              2 * themeSize.horizontalPadding -
                                              24 -
                                              6 * 8) /
                                          5,
                                      width: (themeSize.screenWidth -
                                              2 * themeSize.horizontalPadding -
                                              24 -
                                              6 * 8) /
                                          5,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const SizedBox(),
                                    errorWidget: (context, url, error) =>
                                        const SizedBox(),
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                user.username,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.text,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
