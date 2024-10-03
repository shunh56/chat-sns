import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class UsersFriendsScreen extends ConsumerWidget {
  const UsersFriendsScreen(
      {super.key, required this.user, required this.friends});
  final UserAccount user;
  final List<UserAccount> friends;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];
    final myFriendIds = friendInfos.map((item) => item.userId).toList();
    final controller = ref.watch(controllerProvider);
    final text = ref.watch(inputTextProvider);

    final users = friends.where((user) => user.name.contains(text)).toList();
    final listView = (friends.isEmpty)
        ? const Center(
            child: Text("フレンドはいません"),
          )
        : users.isEmpty
            ? const Center(
                child: Text("検索結果がありません"),
              )
            : ListView.builder(
                itemCount: users.length,
                padding: const EdgeInsets.only(bottom: 48),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(navigationRouterProvider(context))
                          .goToProfile(user);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: ThemeColor.accent,
                        border:
                            Border.all(color: ThemeColor.stroke, width: 0.4),
                      ),
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
                            child: UserIcon.tileIcon(user, width: 40),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(4),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColor.text,
                                              height: 1.0),
                                        ),
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Gap(4),
                                Text(
                                  user.aboutMe,
                                  maxLines: 4,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "フレンド(${friends.length})",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.name,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      ref.read(inputTextProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: "検索",
                      filled: true,
                      isDense: true,
                      fillColor: ThemeColor.stroke,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: ThemeColor.white,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(themeSize.verticalSpaceSmall),
          Expanded(child: listView),
        ],
      ),
    );
  }
}
