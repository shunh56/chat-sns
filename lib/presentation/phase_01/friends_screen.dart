import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final friendIds = ref.watch(friendIdsProvider);
    final map = ref.read(allUsersNotifierProvider).asData!.value;
    final friends = friendIds.map((userId) => map[userId]!).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "フレンド",
          style: textStyle.appbarText(
            japanese: true,
            isSmall: true,
          ),
        ),
      ),
      body: SearchView(
        friends: friends,
      ),
    );
  }
}

class SearchView extends ConsumerWidget {
  const SearchView({super.key, required this.friends});

  final List<UserAccount> friends;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final controller = ref.watch(controllerProvider);
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final text = ref.watch(inputTextProvider);
    final imageWidth = (themeSize.screenWidth - 2 * 12) / 5 - 8;
    final searchQuery = friends
        .where((user) => user.name.toLowerCase().contains(text.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
          Gap(themeSize.verticalSpaceSmall),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 72),
              children: [
                Builder(
                  builder: (context) {
                    if (friends.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Center(
                          child: Text(
                            "フレンドはいません",
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                      );
                    }
                    if (searchQuery.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Center(
                          child: Text(
                            "検索結果がありません",
                            style: textStyle.w600(
                              fontSize: 14,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                      );
                    }
                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: searchQuery
                          .map(
                            (user) => GestureDetector(
                              onTap: () {
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToProfile(user);
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
                                                fadeInDuration: const Duration(
                                                    milliseconds: 120),
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
                                                errorWidget:
                                                    (context, url, error) =>
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
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
