import 'dart:math';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/community.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/phase_01/community_detail_screen.dart';
import 'package:app/presentation/phase_01/search_params_screen.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/phase_01/user_card_stack_screen.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/following_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class SearchUsersScreen extends ConsumerWidget {
  const SearchUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.background,
        elevation: 0,
        centerTitle: false,
        leading: null,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              "探す",
              style: textStyle.w700(
                fontSize: 28,
                color: ThemeColor.white,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchParamsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.search_rounded,
                      color: ThemeColor.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: ThemeColor.accent,
        onRefresh: () async {
          ref.read(newUsersNotifierProvider.notifier).refresh();
          ref.read(recentUsersNotifierProvider.notifier).refresh();
        },
        child: ListView(
          children: const [
            Gap(12),
            UsersFeed(), Gap(24),
            //NewUsersSection(),
            CommunityListView(),
            Gap(24),

            //RecommendedUsersSection(),
            // Gap(24),
            // RecentUsersSection(),
          ],
        ),
      ),
    );
  }

  /* Widget friendsFriendListView(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final friendIds = ref.watch(friendIdsProvider);
    final deletes =
        ref.watch(deletesIdListNotifierProvider).asData?.value ?? [];
    final requesteds = ref.watch(requestedIdsProvider);
    final blocks = ref.watch(blocksListNotifierProvider).asData?.value ?? [];
    final blockeds =
        ref.watch(blockedsListNotifierProvider).asData?.value ?? [];
    final filters = deletes +
        requesteds +
        blocks +
        blockeds +
        friendIds +
        [ref.read(authProvider).currentUser!.uid];
    final asyncValue = ref.watch(maybeFriends);
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const Gap(12),
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "知り合いかも",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
            ),
          ),
        ),
        asyncValue.when(
          data: (ids) {
            final userIds =
                ids.where((userId) => !filters.contains(userId)).toList();
            final users = ref
                .read(allUsersNotifierProvider)
                .asData!
                .value
                .values
                .where((item) => userIds.contains(item.userId))
                .toList();
            //フレンドリクエストが来ているユーザーは消す
            users.removeWhere((user) => filters.contains(user.userId));
            if (users.isEmpty) {
              return SizedBox(
                height: themeSize.screenHeight * 0.1,
                child: Center(
                  child: Text(
                    "おすすめのユーザーはいません。",
                    style: textStyle.w600(
                      color: ThemeColor.subText,
                    ),
                  ),
                ),
              );
            }
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                users.isEmpty
                    ? const Text("")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return UserRequestWidget(user: user);
                        },
                      ),
              ],
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  } */
}

class UsersFeed extends ConsumerWidget {
  const UsersFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);
    final onlineUsersAsyncValue = ref.watch(recentUsersNotifierProvider);
    final width = themeSize.screenWidth * 0.42;
    final height = width * 1.3;
    final titleSize = 16.0;
    final textSize = 14.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "気になる友達を見つけよう",
                style: textStyle.w700(
                  fontSize: 24,
                  color: ThemeColor.white,
                ),
              ),
              const Gap(12),
              Text(
                "新しく始めた人やアクティブなユーザーと\n趣味や興味を共有して仲良くなろう",
                style: textStyle.w400(
                  fontSize: 15,
                  color: const Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 4),
            scrollDirection: Axis.horizontal,
            children: [
              newUsersAsyncValue.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const SizedBox();
                  }
                  final user = users.first;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  UserCardStackScreen(users: users)));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base image container with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: CachedImage.usersCard(user.imageUrl!),
                            ),
                          ),
                          // Blur effect with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ShaderWidget(
                              child: Container(
                                width: width,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "最近始めたユーザー",
                                style: textStyle.w600(
                                  fontSize: titleSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(8),
                              Text(
                                "登録したばかりで\nまだ慣れていません",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: textSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 32,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.pink,
                                ),
                                child: Center(
                                  child: Text(
                                    "見にいく",
                                    style: textStyle.w600(
                                      fontSize: titleSize,
                                      color: ThemeColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: ThemeColor.error),
                      const Gap(8),
                      Text(
                        'エラーが発生しました\n${error.toString()}',
                        textAlign: TextAlign.center,
                        style: textStyle.w400(
                          fontSize: 12,
                          color: ThemeColor.error,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              onlineUsersAsyncValue.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const SizedBox();
                  }
                  final user = users.first;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  UserCardStackScreen(users: users)));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base image container with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: CachedImage.usersCard(user.imageUrl!),
                            ),
                          ),
                          // Blur effect with sharp corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ShaderWidget(
                              child: Container(
                                width: width,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "アクティブな友達",
                                style: textStyle.w600(
                                  fontSize: titleSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(8),
                              Text(
                                "最近開いた友達",
                                textAlign: TextAlign.center,
                                style: textStyle.w600(
                                  fontSize: textSize,
                                  color: ThemeColor.white,
                                ),
                              ),
                              Gap(16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 32,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.pink,
                                ),
                                child: Center(
                                  child: Text(
                                    "見にいく",
                                    style: textStyle.w600(
                                      fontSize: titleSize,
                                      color: ThemeColor.white,
                                    ),
                                  ),
                                ),
                              ),
                              Gap(12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: ThemeColor.error),
                      const Gap(8),
                      Text(
                        'エラーが発生しました\n${error.toString()}',
                        textAlign: TextAlign.center,
                        style: textStyle.w400(
                          fontSize: 12,
                          color: ThemeColor.error,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> mockData = [
  /*{
    "title": "推し活部屋",
    "description": "アニメ、アイドル、VTuber、韓国アーティスト...。同じ推しを見つけて、語り合おう！",
    "thumbnailUrl": "assets/images/community/oshikatsu.png",
    "tags": ["推し活", "オタ活", "同担歓迎", "グッズ交換"],
    "memberCount": 0,
    "category": "entertainment",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  }, */
  /*{
    "title": "バズれ！クリエイターズ",
    "description": "TikTok、YouTube、Instagram...。バズりたい人が集まって情報交換！編集テクから撮影のコツまで",
    "thumbnailUrl": "assets/images/community/creators.png",
    "tags": ["バズり方", "クリエイター", "投稿のコツ", "SNS攻略"],
    "memberCount": 0,
    "category": "creative",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  }, */
  {
    "title": "お洒落さんと繋がりたい",
    "description": "古着mix、韓国っぽ、地雷系など。毎日のコーデや購入品を共有！トレンド情報もシェアしよう",
    "thumbnailUrl": "assets/images/community/fashion.jpeg",
    "tags": ["古着女子", "量産型", "地雷系", "コーデ"],
    "memberCount": 0,
    "category": "fashion",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "ゲーム仲間募集中！",
    "description": "ApexやValo、スプラ、原神など。フレンド募集から攻略情報まで、ゲーム好き集まれ！",
    "thumbnailUrl": "assets/images/community/gaming.jpeg",
    "tags": ["ゲーム好きと繋がりたい", "フレンド募集", "協力プレイ", "攻略"],
    "memberCount": 0,
    "category": "gaming",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "サ活！（サークル活動）",
    "description": "大学生活をもっと楽しく！サークル情報から新歓、イベント情報まで。先輩たちの経験談も",
    "thumbnailUrl": "assets/images/community/circle.jpeg",
    "tags": ["サークル", "大学生", "新歓", "キャンパスライフ"],
    "memberCount": 0,
    "category": "campus",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "フェス＆ライブ民",
    "description": "音楽フェス、アーティストライブ、クラブイベント...。チケット情報から感想まで語り合おう！",
    "thumbnailUrl": "assets/images/community/music.jpeg",
    "tags": ["フェス好き", "現場参戦", "チケット", "ライブレポ"],
    "memberCount": 0,
    "category": "music",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "めんどくさい生活部",
    "description": "毎日のモヤモヤ、人間関係、将来の不安...。愚痴も悩みも本音で話せる、ありのままの交流場所",
    "thumbnailUrl": "assets/images/community/life.jpeg",
    "tags": ["愚痴OK", "ありのまま", "本音トーク", "居場所"],
    "memberCount": 0,
    "category": "lifestyle",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "勉強垢の集い場",
    "description": "テスト対策、資格勉強、就活...。モチベ維持に、一緒に頑張る仲間を見つけよう！",
    "thumbnailUrl": "assets/images/community/study.jpeg",
    "tags": ["勉強垢さんと繋がりたい", "資格勉強", "スタディログ", "受験生"],
    "memberCount": 0,
    "category": "study",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "おうちカフェ部",
    "description": "カフェ巡り好き、お菓子作り、コーヒー好き集まれ！おすすめスポットや手作りレシピをシェアしよう",
    "thumbnailUrl": "assets/images/community/cafe.jpeg",
    "tags": ["カフェ巡り", "おうちカフェ", "スイーツ作り", "カフェ好き"],
    "memberCount": 0,
    "category": "food",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
  {
    "title": "スキルアップ部",
    "description": "プログラミング、デザイン、副業...。新しいスキルを身につけたい人のための情報交換コミュニティ",
    "thumbnailUrl": "assets/images/community/skill.jpeg",
    "tags": ["プログラミング初心者", "デザイン", "副業", "スキル"],
    "memberCount": 0,
    "category": "career",
    "isOfficial": true,
    "createdAt": "2025-02-24T00:00:00.000Z",
  },
];

/*
class CommunitlyListView extends ConsumerWidget {
  const CommunitlyListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "コミュニティ",
            style: textStyle.appbarText(japanese: true),
          ),
        ),
        Gap(12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: mockData.length,
          itemBuilder: (context, index) {
            final data = mockData[index];
            return InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(
                            data["thumbnailUrl"],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["title"]!,
                          style: textStyle.w600(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Gap(8),
                        Text(
                          "${Random().nextInt(120)}人のメンバー",
                          style: textStyle.w500(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
*/
class CommunityListView extends ConsumerWidget {
  const CommunityListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ヘッダーセクション
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "コミュニティを探す",
                style: textStyle.w700(
                  fontSize: 24,
                  color: ThemeColor.white,
                ),
              ),
              const Gap(12),
              Text(
                "興味のあるコミュニティに参加して、同じ趣味の仲間と交流しよう！",
                style: textStyle.w400(
                  fontSize: 15,
                  color: const Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // コミュニティリスト
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockData.length,
          itemBuilder: (context, index) {
            final data = mockData[index];
            return Card(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              color: const Color(0xFF1A1A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Color(0xFF262626),
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CommunityDetailScreen(community: mockCommunityDetail),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // サムネイル
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(data["thumbnailUrl"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Gap(16),
                          // コンテンツ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["title"]!,
                                  style: textStyle.w600(
                                    fontSize: 18,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                                const Gap(8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${Random().nextInt(120)}人が参加中",
                                    style: textStyle.w500(
                                      fontSize: 13,
                                      color: const Color(0xFF60A5FA),
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                Text(
                                  data["description"]!,
                                  style: textStyle.w400(
                                    fontSize: 14,
                                    color: const Color(0xFFB0B0B0),
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      // タグ
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (data["tags"] as List<String>).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222222),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "#$tag",
                              style: textStyle.w500(
                                fontSize: 13,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


/*

class NewUsersSection extends ConsumerWidget {
  const NewUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);
    return UsersSection(
      title: "最近始めたユーザー",
      onSectionTapped: () {},
      asyncValue: newUsersAsyncValue,
    );
  }
}

class RecentUsersSection extends ConsumerWidget {
  const RecentUsersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineUsersAsyncValue = ref.watch(recentUsersNotifierProvider);
    return UsersSection(
      title: "最近アクティブのユーザー",
      onSectionTapped: () {},
      asyncValue: onlineUsersAsyncValue,
    );
  }
}

class UsersSection extends ConsumerWidget {
  const UsersSection({
    super.key,
    required this.title,
    required this.onSectionTapped,
    required this.asyncValue,
  });

  final String title;
  final VoidCallback onSectionTapped;
  final AsyncValue<List<UserAccount>> asyncValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textStyle.w600(fontSize: 16),
              ),
              GestureDetector(
                onTap: onSectionTapped,
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeColor.icon,
                  size: 18,
                ),
              )
            ],
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 180,
          child: asyncValue.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    'ユーザーが見つかりません',
                    style: textStyle.w400(fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  if (user.userId == ref.read(authProvider).currentUser!.uid) {
                    return const SizedBox();
                  }
                  return _userTile(context, user, ref, textStyle);
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: ThemeColor.error),
                  const Gap(8),
                  Text(
                    'エラーが発生しました\n${error.toString()}',
                    textAlign: TextAlign.center,
                    style: textStyle.w400(
                      fontSize: 12,
                      color: ThemeColor.error,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userTile(
    BuildContext context,
    UserAccount user,
    WidgetRef ref,
    ThemeTextStyle textStyle,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 160,
        decoration: BoxDecoration(
          color: ThemeColor.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(12),
            CachedImage.userIcon(user.imageUrl, user.name, 32),
            const Gap(8),
            Text(
              user.name,
              style: textStyle.w600(fontSize: 16),
            ),
            const Gap(12),
            _buildFollowButton(user),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserAccount user) {
    return Consumer(
      builder: (context, ref, child) {
        final themeSize = ref.watch(themeSizeProvider(context));
        final textStyle = ThemeTextStyle(themeSize: themeSize);
        ref.watch(followingListNotifierProvider);
        final notifier = ref.read(followingListNotifierProvider.notifier);
        final isFollowing = notifier.isFollowing(user.userId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isFollowing ? Colors.blue : ThemeColor.white,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: () {
                if (!isFollowing) {
                  notifier.followUser(user);
                } else {
                  notifier.unfollowUser(user);
                }
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 96,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    !isFollowing ? 'フォロー' : 'フォロー中',
                    style: textStyle.w500(
                      fontSize: 12,
                      color: isFollowing
                          ? ThemeColor.white
                          : ThemeColor.background,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
 */