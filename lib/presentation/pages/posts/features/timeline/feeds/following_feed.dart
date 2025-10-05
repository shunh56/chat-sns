import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/posts/core/components/post_card/post_card.dart';
import 'package:app/presentation/providers/posts/following_posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

//final refreshController = Provider((ref) => RefreshController());

//keepAlive => stateful widget
class FollowingPostsThread extends ConsumerStatefulWidget {
  const FollowingPostsThread({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FollowingPostsThreadState();
}

class _FollowingPostsThreadState extends ConsumerState<FollowingPostsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postList = ref.watch(followingPostsNotifierProvider);
    return postList.when(
      data: (list) {
        return RefreshIndicator(
          color: ThemeColor.text,
          backgroundColor: ThemeColor.stroke,
          onRefresh: () async {
            ref.read(followingPostsNotifierProvider.notifier).refresh();
            // ref.read(voiceChatListNotifierProvider.notifier).refresh();
            /*ref
                .read(friendsCurrentStatusPostsNotiferProvider.notifier)
                .refresh(); */
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final post = list[index];

              return Column(
                children: [
                  UserWidget(
                    userId: post.userId,
                    builder: (user) => PostCard(
                      postRef: post,
                      user: user,
                    ),
                  ),
                  /* if (index != 0 && index % 10 == 0)
                      NativeAdWidget(
                        id: const Uuid().v4(),
                      ), */
                ],
              );
            },
          ),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(
            color: ThemeColor.text,
          ),
        );
      },
    );
  }

  /*navToEditCurrentStatus(BuildContext context, WidgetRef ref, UserAccount me) {
    ref.read(currentStatusStateProvider.notifier).state = me.currentStatus;
    Navigator.push(
      context,
      PageTransitionMethods.slideUp(
        const EditCurrentStatusScreen(),
      ),
    );
  } */

  /*Widget _buildCurrentStatus(
      BuildContext context, WidgetRef ref, UserAccount me) {
    final canvasTheme = me.canvasTheme;

    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
              collapsed: box(
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
                              flex: 2,
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
                              flex: 5,
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
                    const Gap(4),
                    Center(
                      child: ExpandableButton(
                        theme: const ExpandableThemeData(
                          useInkWell: false,
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black.withOpacity(0.1),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: me.canvasTheme.boxSecondaryTextColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                () {
                  navToEditCurrentStatus(context, ref, me);
                },
              ),
              expanded: box(
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
                              flex: 2,
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
                              flex: 5,
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
                              flex: 2,
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
                              flex: 5,
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
                              flex: 2,
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
                              flex: 5,
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
                              flex: 2,
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
                              flex: 5,
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
                                        color:
                                            canvasTheme.boxSecondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (me.currentStatus.nextAt.isNotEmpty)
                                      Text(
                                        "next: ${me.currentStatus.nextAt}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              canvasTheme.boxSecondaryTextColor,
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
                              flex: 2,
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
                              flex: 5,
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
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  color: ThemeColor.accent,
                                                  height: 48,
                                                  width: 48,
                                                  child: user.imageUrl != null
                                                      ? CachedNetworkImage(
                                                          imageUrl:
                                                              user.imageUrl!,
                                                          fadeInDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      120),
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                            height: 48,
                                                            width: 48,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          placeholder: (context,
                                                                  url) =>
                                                              const SizedBox(),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const SizedBox(),
                                                        )
                                                      : const Icon(
                                                          Icons.person_outline,
                                                          size: 48 * 0.8,
                                                          color:
                                                              ThemeColor.stroke,
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
                    const Gap(4),
                    Center(
                      child: ExpandableButton(
                        theme: const ExpandableThemeData(
                          useInkWell: false,
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black.withOpacity(0.1),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: me.canvasTheme.boxSecondaryTextColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                () {
                  navToEditCurrentStatus(context, ref, me);
                },
              )),
        ],
      ),
    );
  } */

  Widget box(CanvasTheme canvasTheme, Widget child, Function onPressed) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 16,
                  bottom: 4,
                ),
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

/*class CurrentStatusPostsSection extends ConsumerStatefulWidget {
  const CurrentStatusPostsSection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CurrentStatusPostsSectionState();
}

class _CurrentStatusPostsSectionState
    extends ConsumerState<CurrentStatusPostsSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(friendsCurrentStatusPostsNotiferProvider);
    final myId = ref.read(authProvider).currentUser!.uid;
    final me = ref.watch(myAccountNotifierProvider).asData!.value;
    const boxHeight = 86.0;

    return asyncValue.when(
      data: (data) {
        final userIds = data.keys.where((userId) => userId != myId).toList();
        final friendIds = ref.watch(friendIdsProvider);

        /*userIds.sort((a, b) {
          final aSeen = data[a]!.first.isSeen;
          final bSeen = data[b]!.first.isSeen;
          if (aSeen != bSeen) {
            return aSeen ? 1 : -1;
          }
          final aEngament = friendInfos
              .where((info) => info.userId == a)
              .first
              .engagementCount;
          final bEngament = friendInfos
              .where((info) => info.userId == b)
              .first
              .engagementCount;
          return bEngament.compareTo(aEngament);
        }); */
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "友達のステータス",
                  style: textStyle.w600(
                    fontSize: 18,
                  ),
                ),
              ),
              const Gap(8),
              SizedBox(
                height: boxHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: data[myId] != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CurrentStatusStories(
                                        initIndex: -1,
                                        sortedUserIds: userIds,
                                      ),
                                    ),
                                  );
                                }
                              : () {
                                  final me = ref
                                      .read(myAccountNotifierProvider)
                                      .asData!
                                      .value;
                                  ref
                                      .read(currentStatusStateProvider.notifier)
                                      .state = me.currentStatus;
                                  Navigator.push(
                                    context,
                                    PageTransitionMethods.slideUp(
                                      const EditCurrentStatusScreen(),
                                    ),
                                  );
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: UserIconStoryIcon(
                              user: me,
                              isSeen: ((data[myId] == null) ||
                                  data[myId] != null &&
                                      data[myId]!.first.isSeen),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              final me = ref
                                  .read(myAccountNotifierProvider)
                                  .asData!
                                  .value;
                              ref
                                  .read(currentStatusStateProvider.notifier)
                                  .state = me.currentStatus;
                              Navigator.push(
                                context,
                                PageTransitionMethods.slideUp(
                                  const EditCurrentStatusScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3.2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ThemeColor.background,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue,
                                ),
                                child: data[myId] != null
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: SvgPicture.asset(
                                          "assets/images/icons/edit.svg",
                                          // ignore: deprecated_member_use
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: userIds.length,
                      itemBuilder: (context, index) {
                        final userId = userIds[index];
                        final posts = data[userId]!;
                        final user = ref
                            .read(allUsersNotifierProvider)
                            .asData!
                            .value[userId]!;
                        return SizedBox(
                          height: boxHeight,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CurrentStatusStories(
                                        initIndex: index,
                                        sortedUserIds: userIds,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: UserIconStoryIcon(
                                    user: user,
                                    isSeen: posts.first.isSeen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "友達のステータス",
                style: textStyle.w600(
                  fontSize: 18,
                ),
              ),
            ),
            const Gap(8),
            SizedBox(
              height: boxHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: UserIconStoryIcon(
                          user: me,
                          isSeen: true,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3.2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: ThemeColor.background,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (e, s) => const SizedBox(),
    );
  }
}

class CurrentStatusStories extends ConsumerWidget {
  const CurrentStatusStories({
    super.key,
    this.initIndex = 0,
    required this.sortedUserIds,
  });
  final int initIndex;
  final List<String> sortedUserIds;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final myId = ref.read(authProvider).currentUser!.uid;
    final map =
        ref.read(friendsCurrentStatusPostsNotiferProvider).asData!.value;
    final myStories = map[myId] != null;
    final userIds = (myStories ? [myId] : []) + sortedUserIds;

    final pageController = PageController(
      initialPage: initIndex + (myStories ? 1 : 0),
      viewportFraction: 0.9,
    );

    readInit() async {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!map[userIds[initIndex + (myStories ? 1 : 0)]]!
          .first
          .seenUserIds
          .contains(myId)) {
        ref
            .read(allCurrentStatusPostsNotifierProvider.notifier)
            .readPost(userIds[initIndex + (myStories ? 1 : 0)]);
      }
    }

    readInit();

    pageController.addListener(() {
      final index = pageController.page?.toInt();
      if (index != null) {
        if (!map[userIds[index]]!.first.seenUserIds.contains(myId)) {
          ref
              .read(allCurrentStatusPostsNotifierProvider.notifier)
              .readPost(userIds[index]);
        }
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SafeArea(
              child: PageView.builder(
                controller: pageController,
                itemCount: userIds.length,
                itemBuilder: (context, index) {
                  final userId = userIds[index];
                  final user =
                      ref.read(allUsersNotifierProvider).asData!.value[userId]!;
                  final posts = map[userId]!;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: user.canvasTheme.bgColor,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 8,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(navigationRouterProvider(context))
                                      .goToProfile(user);
                                },
                                child: UserIcon(user: user),
                              ),
                              const Gap(8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user.name}の",
                                    style: textStyle.w600(
                                      fontSize: 16,
                                      color: user.canvasTheme.profileTextColor,
                                    ),
                                  ),
                                  Text(
                                    "ステータス履歴",
                                    style: textStyle.w600(
                                      fontSize: 16,
                                      color: user.canvasTheme.profileTextColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const Gap(12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return CurrentStatusStoryTileWidget(postRef: post);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              width: themeSize.screenWidth / 5,
              height: themeSize.screenHeight * 0.7,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (pageController.page == 0) {
                    Navigator.pop(context);
                    return;
                  }
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                    //  color: Colors.cyan.withOpacity(0.3),
                    ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              width: themeSize.screenWidth / 5,
              height: themeSize.screenHeight * 0.7,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (pageController.page == userIds.length - 1) {
                    Navigator.pop(context);
                    return;
                  }
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                    // color: Colors.green.withOpacity(0.3),
                    ),
              ),
            ),
            const HeartAnimationArea(),
          ],
        ),
      ),
    );
  }
}
 */
