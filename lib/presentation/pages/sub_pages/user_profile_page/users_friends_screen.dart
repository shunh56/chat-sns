import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final friendsCount = "(${friends.length})";
    final friendInfos =
        ref.watch(friendIdListNotifierProvider).asData?.value ?? [];

    final imageWidth = (themeSize.screenWidth - 2 * 12) / 5 - 8;
    final myFriendIds = friendInfos.map((item) => item.userId).toList();
    final controller = ref.watch(controllerProvider);
    final text = ref.watch(inputTextProvider);

    final users = friends.where((user) => user.name.contains(text)).toList();
    final listView = (friends.isEmpty)
        ? Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Center(
              child: Text(
                "フレンドはいません",
                style: textStyle.w600(
                  color: ThemeColor.subText,
                ),
              ),
            ),
          )
        : users.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Center(
                  child: Text(
                    "検索結果がありません",
                    style: textStyle.w600(
                      color: ThemeColor.subText,
                    ),
                  ),
                ),
              )
            : Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: friends
                    .where((user) =>
                        user.name.toLowerCase().contains(text.toLowerCase()))
                    .map(
                      (user) => GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
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
              );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "フレンド$friendsCount",
          style: textStyle.appbarText(japanese: true),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
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
            listView,
          ],
        ),
      ),
    );
  }
}
