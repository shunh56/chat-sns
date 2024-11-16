import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/model/voice_room.dart';
import 'package:app/presentation/pages/community_screen/screens/community_member_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/community_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/new_users_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/online_users_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/tabs.dart';
import 'package:app/presentation/providers/provider/community.dart';
import 'package:app/presentation/providers/provider/users/online_users.dart';
import 'package:app/presentation/providers/topics/topics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CommunityTabScreen extends ConsumerWidget {
  const CommunityTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    //const String communityId = 'student_life'; // α版では固定

    final communityAsyncValue = ref.watch(communityNotifierProvider);
    final topicsAsyncValue = ref.watch(recentTopicsNotifier);
    final onlineUsersAsyncValue = ref.watch(onlineUsersNotifierProvider);
    final newUsersAsyncValue = ref.watch(newUsersNotifierProvider);

    return Scaffold(
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverAppBar(
              floating: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "コミュニティ",
                    style: textStyle.appbarText(japanese: true),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnlineUsersScreen(),
                              ),
                            );
                          },
                          splashColor: Colors.white.withOpacity(0.05),
                          highlightColor: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ThemeColor.accent,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.green,
                                    ),
                                    const Gap(6),
                                    Text(
                                      "オンライン",
                                      style: textStyle.w600(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(6),
                                Text(
                                  "アクティブなユーザー",
                                  style: textStyle.w400(
                                    fontSize: 12,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                                const Gap(12),
                                onlineUsersAsyncValue.maybeWhen(
                                  data: (users) {
                                    return UserStackIcons(
                                      imageRadius: 16,
                                      users: users,
                                      strokeColor: ThemeColor.accent,
                                    );
                                  },
                                  orElse: () {
                                    return const EmptyUserStackIcons(
                                      imageRadius: 16,
                                      strokeColor: ThemeColor.accent,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewUsersScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: ThemeColor.accent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    color: ThemeColor.text,
                                    size: 18,
                                  ),
                                  const Gap(6),
                                  Text(
                                    "今日の活動",
                                    style: textStyle.w600(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(6),
                              Text(
                                "新規ユーザー",
                                style: textStyle.w400(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                              const Gap(12),
                              newUsersAsyncValue.maybeWhen(
                                data: (users) {
                                  return UserStackIcons(
                                    imageRadius: 16,
                                    users: users,
                                    strokeColor: ThemeColor.accent,
                                  );
                                },
                                orElse: () {
                                  return const EmptyUserStackIcons(
                                    imageRadius: 16,
                                    strokeColor: ThemeColor.accent,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // メインコンテンツ
            SliverToBoxAdapter(
              child: communityAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (community) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommunityCard(community: community),

                      const SizedBox(height: 24),

                      // 人気のトピック
                      const Text(
                        '人気のトピック',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TopicsList(topicsAsyncValue: topicsAsyncValue),

                      const SizedBox(height: 24),

                      // アクティブな通話室
                      /*  const Text(
                        'アクティブな通話室',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12), */
                      /*VoiceRoomsList(
                       voiceRoomsAsyncValue: voiceRoomsAsyncValue,
                          ), */
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityCard extends ConsumerWidget {
  const CommunityCard({super.key, required this.community});
  final Community? community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    if (community == null) {
      return const SizedBox();
    }
    final asyncValue = ref.watch(communityMembersNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "おすすめのコミュニティ",
          style: textStyle.w600(
            fontSize: 18,
          ),
        ),
        const Gap(8), // バナー部分
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommunityScreen(
                  communityId: community!.id,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColor.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 108,
                    height: 108,
                    child: CachedImage.postImage(community!.thumbnailImageUrl),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community!.name,
                        style: textStyle.w600(
                          fontSize: 24,
                        ),
                      ),
                      const Gap(8),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityMemberScreen(community: community!),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${community!.memberCount.toString()} 人のメンバー',
                              style: textStyle.w400(
                                fontSize: 14,
                                color: ThemeColor.subText,
                              ),
                            ),
                            const Gap(8),
                            asyncValue.maybeWhen(
                              data: (members) => UserStackIcons(
                                users: members
                                    .map((member) => member.user)
                                    .toList(),
                                strokeColor: ThemeColor.accent,
                                imageRadius: 16,
                              ),
                              orElse: () => const EmptyUserStackIcons(
                                imageRadius: 16,
                                strokeColor: ThemeColor.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 統計情報
        /*Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              statItem(
                context,
                ref,
                label: '投稿',
                value: community!.totalPosts.toString(),
              ),
              statItem(
                context,
                ref,
                label: '今日の投稿',
                value: community!.dailyPosts.toString(),
              ),
              statItem(
                context,
                ref,
                label: 'トピック',
                value: community!.topicsCount.toString(),
              ),
            ],
          ),
        ), */
      ],
    );
  }

  Widget statItem(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String value,
  }) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Column(
      children: [
        Text(
          value,
          style: textStyle.numText(
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: textStyle.w400(
            color: ThemeColor.subText,
          ),
        ),
      ],
    );
  }
}

// max 6 cards
class TopicsList extends ConsumerWidget {
  final AsyncValue<List<Topic>> topicsAsyncValue;

  const TopicsList({super.key, required this.topicsAsyncValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return topicsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (topics) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return TopicCard(
              topic: topics[index],
            );
          },
        );
      },
    );
  }
}

class VoiceRoomsList extends ConsumerWidget {
  final AsyncValue<List<VoiceRoom>> voiceRoomsAsyncValue;

  const VoiceRoomsList({super.key, required this.voiceRoomsAsyncValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return voiceRoomsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (voiceRooms) => Column(
        children:
            voiceRooms.map((room) => VoiceRoomCard(voiceRoom: room)).toList(),
      ),
    );
  }
}

class VoiceRoomCard extends ConsumerWidget {
  final VoiceRoom voiceRoom;

  const VoiceRoomCard({super.key, required this.voiceRoom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ThemeColor.stroke,
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.mic,
            color: Colors.white,
          ),
        ),
        title: Text(voiceRoom.name),
        subtitle: Text('${voiceRoom.participantCount}人が参加中'),
        trailing: Material(
          color: ThemeColor.background,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                '参加',
                style: textStyle.w600(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
