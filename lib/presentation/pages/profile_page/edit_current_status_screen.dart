import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile_page/edit_now_with_screen.dart';
import 'package:app/presentation/pages/profile_page/edit_tags_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class EditCurrentStatusScreen extends ConsumerWidget {
  const EditCurrentStatusScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));

    final notifier = ref.read(myAccountNotifierProvider.notifier);
    // final canvasTheme = ref.read(canvasThemeProvider);

    final currentStatus = ref.watch(currentStatusStateProvider);
    final currentStatusNotifier =
        ref.watch(currentStatusStateProvider.notifier);

    final asyncValue = ref.watch(myAccountNotifierProvider);

    final listView = asyncValue.when(
      data: (me) {
        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
          child: ListView(
            padding: const EdgeInsets.only(top: 36),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //tags
                  const Text(
                    "タグ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          children: currentStatus.tags
                              .map(
                                (tag) => Container(
                                  margin: const EdgeInsets.only(
                                      right: 8, bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: ThemeColor.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Gap(6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(selectedtagsStateProvider.notifier).state =
                              currentStatus.tags;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditTagsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: SvgPicture.asset(
                              "assets/images/icons/edit.svg",
                              color: ThemeColor.icon,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  //doing
                  const Text(
                    "なにしてる？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: currentStatus.doing,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      currentStatusNotifier.state =
                          currentStatus.copyWith(doing: value);
                    },
                    decoration: InputDecoration(
                      hintText: "カラオケしてる",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),

                  //eating
                  const Text(
                    "なに食べてる？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: currentStatus.eating,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      currentStatusNotifier.state =
                          currentStatus.copyWith(eating: value);
                    },
                    decoration: InputDecoration(
                      hintText: "寿司",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),
                  //mood
                  const Text(
                    "今の気分は？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: currentStatus.mood,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      currentStatusNotifier.state =
                          currentStatus.copyWith(mood: value);
                    },
                    decoration: InputDecoration(
                      hintText: "最高",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),
                  //nowAt
                  const Text(
                    "どこにいる？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: currentStatus.nowAt,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      currentStatusNotifier.state =
                          currentStatus.copyWith(nowAt: value);
                    },
                    decoration: InputDecoration(
                      hintText: "飛行機の中",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),

                  //nextAt
                  const Text(
                    "どこに行く？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(6),
                  TextFormField(
                    initialValue: currentStatus.nextAt,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ThemeColor.text,
                    ),
                    onChanged: (value) {
                      currentStatusNotifier.state =
                          currentStatus.copyWith(nextAt: value);
                    },
                    decoration: InputDecoration(
                      hintText: "ニューヨーク",
                      filled: true,
                      isDense: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        color: ThemeColor.beige,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const Gap(24),

                  //nowWith
                  const Text(
                    "誰といる？",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(8),
                  FutureBuilder(
                    future: ref
                        .read(allUsersNotifierProvider.notifier)
                        .getUserAccounts(currentStatus.nowWith),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final users = snapshot.data!;
                      if (users.isEmpty) {
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(selectedUserIdsStateProvider.notifier)
                                .state = currentStatus.nowWith;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditNowWithScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: const Center(
                              child: Text(
                                "一緒にいる友達を追加する",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: users
                                    .map(
                                      (user) => Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            color: ThemeColor.accent,
                                            height: 48,
                                            width: 48,
                                            child: user.imageUrl != null
                                                ? CachedNetworkImage(
                                                    imageUrl: user.imageUrl!,
                                                    fadeInDuration:
                                                        const Duration(
                                                            milliseconds: 120),
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      height: 48,
                                                      width: 48,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            const SizedBox(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const SizedBox(),
                                                  )
                                                : const Icon(
                                                    Icons.person_outline,
                                                    size: 48 * 0.8,
                                                    color: ThemeColor.stroke,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          const Gap(6),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(selectedUserIdsStateProvider.notifier)
                                  .state = currentStatus.nowWith;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditNowWithScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withOpacity(0.1),
                              ),
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: SvgPicture.asset(
                                  "assets/images/icons/edit.svg",
                                  color: ThemeColor.icon,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Gap(24),
                  const Gap(60),
                ],
              ),
            ],
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ステータスを更新",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              notifier.updateCurrentStatus(currentStatus);
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
      body: listView,
    );
  }
}
