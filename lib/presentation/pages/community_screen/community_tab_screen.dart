import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/model/voice_room.dart';
import 'package:app/presentation/pages/community_screen/provider/states/community_membership_provider.dart';
import 'package:app/presentation/pages/community_screen/screens/community_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/topic_screen.dart';
import 'package:app/presentation/providers/provider/community.dart';
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
    const String communityId = 'student_life'; // α版では固定

    final communityAsyncValue = ref.watch(communityNotifierProvider);
    ref.watch(communityMembershipProvider(communityId));
    final topicsAsyncValue = ref.watch(recentTopicsNotifier);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ヘッダー
            SliverAppBar(
              floating: true,
              title: Row(
                children: [
                  Text(
                    'コミュニティ',
                    style: textStyle.appbarText(japanese: true),
                  ),
                  const Expanded(child: SizedBox()),
                ],
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
                      const Text(
                        'アクティブな通話室',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
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
      return const Text("NULL");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // バナー部分
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
            decoration: const BoxDecoration(
              color: ThemeColor.stroke,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
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
                      const Gap(4),
                      Text(
                        '${community!.memberCount.toString()} メンバー • オンライン ${community!.dailyActiveUsers.toString()}人',
                        style: textStyle.w400(
                          fontSize: 14,
                          color: ThemeColor.subText,
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 108,
                    height: 72,
                    child: CachedImage.postImage(community!.thumbnailImageUrl),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 統計情報
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
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
                label: '今日の投稿',
                value: community!.dailyPosts.toString(),
              ),
              statItem(
                context,
                ref,
                label: '通話中',
                value: community!.activeVoiceRooms.toString(),
              ),
              statItem(
                context, ref,
                label: '未読の話題',
                value: '5', // この値は別途管理が必要
              ),
            ],
          ),
        ),
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
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2,
          children: topics.map((topic) => TopicCard(topic: topic)).toList(),
        );
      },
    );
  }
}

class TopicCard extends ConsumerWidget {
  final Topic topic;

  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final isMember =
            ref.watch(communityMembershipProvider(topic.communityId));
        if (!isMember) {
          showJoinDialog(context, ref, topic.communityId);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicScreen(topic: topic),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ThemeColor.stroke,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${topic.postCount}件の投稿',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
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
