/*import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditTopFriendsScreen extends HookConsumerWidget {
  const EditTopFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));

    final notifier = ref.read(myAccountNotifierProvider.notifier);
    final topFriends = ref.watch(topFriendsProvider);
    final topFriendsNotifier = ref.watch(topFriendsProvider.notifier);
    final friendIds = ref.watch(friendIdsProvider);
    final imageWidth =
        (themeSize.screenWidth - 2 * themeSize.horizontalPadding) / 5 - 8;
    final users = ref.watch(allUsersNotifierProvider).asData!.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Top フレンドを編集",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              notifier.updateTopFriends(topFriends);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue,
              ),
              child: const Text(
                "保存する",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
                children: topFriends.map((userId) {
                  final user = users[userId]!;
                  return GestureDetector(
                    onTap: () {
                      final list = topFriends
                          .where((item) => item != user.userId)
                          .toList();

                      topFriendsNotifier.state = list;
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      width: imageWidth,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: ThemeColor.accent,
                              height: imageWidth,
                              width: imageWidth,
                              child: user.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user.imageUrl!,
                                      fadeInDuration:
                                          const Duration(milliseconds: 120),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: imageWidth,
                                        width: imageWidth,
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
                                    )
                                  : Icon(
                                      Icons.person_outline,
                                      size: imageWidth * 0.8,
                                      color: ThemeColor.stroke,
                                    ),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: ThemeColor.text,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
                children: users.values
                    .where((user) =>
                        !topFriends.contains(user.userId) &&
                        friendIds.contains(user.userId))
                    .map(
                      (user) => GestureDetector(
                        onTap: () {
                          if (topFriends.length >= 10) {
                            showMessage("10人までしか選択できません。");
                            return;
                          }
                          topFriendsNotifier.state = [
                            ...topFriends,
                            user.userId
                          ];
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: imageWidth,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: ThemeColor.accent,
                                  height: imageWidth,
                                  width: imageWidth,
                                  child: user.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: user.imageUrl!,
                                          fadeInDuration:
                                              const Duration(milliseconds: 120),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            height: imageWidth,
                                            width: imageWidth,
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
                                        )
                                      : Icon(
                                          Icons.person_outline,
                                          size: imageWidth * 0.8,
                                          color: ThemeColor.stroke,
                                        ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                user.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
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
              const Gap(72),
            ],
          ),
        ),
      ),
    );
  }
}
 */