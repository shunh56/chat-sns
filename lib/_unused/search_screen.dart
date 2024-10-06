/*import 'package:app/core/utils/theme.dart';
import 'package:app/datasource/local/tags.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/profile_page/edit_current_status_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/timeline_page/_not_used/all_blogs.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class Tag {
  final String fieldName;
  final String type; // "array" or "string"
  Tag({required this.fieldName, required this.type});
}

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final asyncValue = ref.watch(myAccountNotifierProvider);
    final List<Tag> tagsList = asyncValue.when(
      data: (me) {
        List<Tag> tags = [];
        const careerTag = "univ";
        // const schoolTag = "waseda";
        const locationTag = "tokyo";
        final selectedTags = selectionTags.map((tag) => tag.jp).toList();
        tags.addAll([
          Tag(
            fieldName: careerTag,
            type: "string",
          ),
          Tag(
            fieldName: locationTag,
            type: "string",
          ),
        ]);
        for (var tag in selectedTags) {
          tags.add(Tag(fieldName: tag, type: "array"));
        }
        return tags;
      },
      error: (e, s) {
        return [];
      },
      loading: () {
        return [];
      },
    );
    final myIcon = asyncValue.when(
      data: (user) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
          child: CachedImage.userIcon(user.imageUrl, user.name, 18),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return DefaultTabController(
      length: 3, //tagsList.length + 1,
      child: Scaffold(
        //TODO -> SliverAppBarに変更する
        body: Column(
          children: [
            Gap(themeSize.appbarHeight),
            TabBar(
              isScrollable: true,
              onTap: (val) {
                HapticFeedback.lightImpact();
              },
              padding: EdgeInsets.symmetric(
                  horizontal: themeSize.horizontalPadding - 4),
              indicator: BoxDecoration(
                color: ThemeColor.button,
                borderRadius: BorderRadius.circular(100),
              ),
              tabAlignment: TabAlignment.start,
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: ThemeColor.background,
              unselectedLabelColor: Colors.white.withOpacity(0.3),
              dividerColor: ThemeColor.background,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  // Use the default focused overlay color
                  return states.contains(WidgetState.focused)
                      ? null
                      : Colors.transparent;
                },
              ),
              tabs: const [
                Tab(
                  child: Text(
                    "ブログ",
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: Text(
                    "人気",
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: Text(
                    "質問",
                    textAlign: TextAlign.center,
                  ),
                ),

                /* ...tagsList.map(
                        (tag) => Tab(
                          child: Text(
                            tag.fieldName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ) */
              ],
            ),
            Expanded(
              child: TabBarView(
                //physics: const NeverScrollableScrollPhysics(),
                children: [
                  const AllBlogsThread(),
                  Container(
                    child: const Center(
                      child: Text("人気のブログ"),
                    ),
                  ),
                  Container(
                    child: const Center(
                      child: Text("質問"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditCurrentStatusScreen(),
      ),
    );
  }

  Widget _buildCurrentStatus(
      BuildContext context, WidgetRef ref, UserAccount me) {
    final canvasTheme = me.canvasTheme;
    return Column(
      children: [
        box(
          canvasTheme,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "「いま」ボード",
                style: TextStyle(
                  fontSize: 16,
                  color: canvasTheme.boxTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              if (me.currentStatus.doing.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "なにしてる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.doing,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (me.currentStatus.eating.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "なに食べてる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.eating,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (me.currentStatus.mood.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "今の気分は？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Text(
                            me.currentStatus.mood,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (me.currentStatus.nextAt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "どこにいる？",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                me.currentStatus.nowAt,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: canvasTheme.boxSecondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (me.currentStatus.nextAt.isNotEmpty)
                                Text(
                                  "next: ${me.currentStatus.nextAt}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: canvasTheme.boxSecondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (me.currentStatus.nowWith.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          "一緒にいる人",
                          style: TextStyle(
                            fontSize: 14,
                            color: canvasTheme.boxSecondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: FutureBuilder(
                          future: ref
                              .read(allUsersNotifierProvider.notifier)
                              .getUserAccounts(me.currentStatus.nowWith),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }
                            final users = snapshot.data!;
                            return SizedBox(
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
                                          child: SizedBox(
                                            height: 48,
                                            width: 48,
                                            child: CachedNetworkImage(
                                              imageUrl: user.imageUrl!,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 120),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                height: 48,
                                                width: 48,
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
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
          () {
            navToEditCurrentStatus(context, ref, me);
          },
        ),
        const Gap(12),
      ],
    );
  }

  Widget box(CanvasTheme canvasTheme, Widget child, Function onPressed) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: canvasTheme.boxBgColor,
                  borderRadius: BorderRadius.circular(canvasTheme.boxRadius),
                  border: Border.all(
                    width: canvasTheme.boxWidth,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
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
                  color: canvasTheme.boxTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
 */