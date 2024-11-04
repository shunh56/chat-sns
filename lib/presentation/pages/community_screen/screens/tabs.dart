// 1. 投稿タブの実装
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/model/room.dart';
import 'package:app/presentation/pages/community_screen/model/topic.dart';
import 'package:app/presentation/pages/community_screen/provider/states/community_membership_provider.dart';
import 'package:app/presentation/pages/community_screen/screens/community_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/create_topics_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/room_screen.dart';
import 'package:app/presentation/pages/community_screen/screens/topic_screen.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_widget.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:app/presentation/providers/provider/posts/community_posts.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/topics/topics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

class PostsTab extends ConsumerWidget {
  const PostsTab({super.key, required this.community});
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final postList = ref.watch(friendsPostsNotiferProvider);
    final postList = ref.watch(communityPostsNotifierProvider(community.id));
    return Stack(
      children: [
        postList.when(
          data: (list) {
            return RefreshIndicator(
              color: ThemeColor.text,
              backgroundColor: ThemeColor.stroke,
              onRefresh: () async {
                ref
                    .read(communityPostsNotifierProvider(community.id).notifier)
                    .initialize();
              },
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final post = list[index];
                  return PostWidget(postRef: post);
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
        ),
        Positioned(
          right: 16,
          bottom: 32,
          child: FloatingActionButton(
            shape: const StadiumBorder(),
            onPressed: () {
              final isMember =
                  ref.watch(communityMembershipProvider(community.id));
              if (!isMember) {
                showJoinDialog(context, ref, community.id);
              } else {
                Navigator.push(
                  context,
                  PageTransitionMethods.slideUp(
                    CreatePostScreen(
                      community: community,
                    ),
                  ),
                );
              }
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

/*class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: InkWell(
        // onTap: () => _showPostDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              /*  if (post.tags != null) ...[
                const SizedBox(height: 8),
                _buildTags(),
              ], */
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(post.userImageUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTimeAgo(post.createdAt),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {},
          //onPressed: () => _showPostOptions(context),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        if (post.imageUrls != null && post.imageUrls!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildImageGrid(),
        ],
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: post.imageUrls!.length == 1 ? 1 : 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: post.imageUrls!
          .map((url) => Image.network(
                url,
                fit: BoxFit.cover,
              ))
          .toList(),
    );
  }

  Widget _buildTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: post.tags!
            .map((tag) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildActionButton(Icons.favorite_border, post.likeCount.toString(),
            () {} // () => _handleLike(context),
            ),
        const SizedBox(width: 24),
        _buildActionButton(Icons.comment_outlined, post.commentCount.toString(),
            () {} //  () => _showComments(context),
            ),
        const SizedBox(width: 24),
        _buildActionButton(
            Icons.share_outlined, '', () {} // () => _handleShare(context),
            ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String count,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
z */

// 2. トピックタブの実装
class TopicsTab extends ConsumerWidget {
  const TopicsTab({super.key, required this.community});
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(communityTopicsNotifier(community.id));

    return Stack(
      children: [
        topicsAsync.when(
          data: (topics) => RefreshIndicator(
            backgroundColor: ThemeColor.stroke,
            onRefresh: () async {
              ref
                  .read(communityTopicsNotifier(community.id).notifier)
                  .initialize();
            },
            child: FutureBuilder(
                future: ref
                    .read(allUsersNotifierProvider.notifier)
                    .getUserAccounts(
                        topics.map((topic) => topic.userId).toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: topics.length,
                    itemBuilder: (context, index) =>
                        TopicCard(topic: topics[index]),
                  );
                }),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'エラーが発生しました: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 32,
          child: FloatingActionButton(
            shape: const StadiumBorder(),
            onPressed: () {
              final isMember =
                  ref.watch(communityMembershipProvider(community.id));
              if (!isMember) {
                showJoinDialog(context, ref, community.id);
              } else {
                Navigator.push(
                  context,
                  PageTransitionMethods.slideUp(
                    CreateTopicScreen(community: community),
                  ),
                );
              }
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class TopicCard extends ConsumerWidget {
  final Topic topic;

  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.read(allUsersNotifierProvider).asData!.value[topic.userId]!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TopicScreen(topic: topic)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              UserIcon(
                user: user,
                width: 48,
                isCircle: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${topic.participantCount}人が参加中',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (topic.isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final roomsStreamProvider = StreamProvider.family((ref, String communityId) {
  return ref
      .watch(firestoreProvider)
      .collection("rooms")
      .where("communityId", isEqualTo: communityId)
      .orderBy("createdAt", descending: true)
      .snapshots();
});

// lib/screens/tabs/rooms_tab.dart
class RoomsTab extends ConsumerWidget {
  const RoomsTab({super.key, required this.community});
  final Community community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsStreamProvider(community.id));

    return Stack(
      children: [
        roomsAsync.when(
            data: (rooms) => ListView.builder(
                  itemCount: rooms.docs.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final room = Room.fromJson(rooms.docs[index].data());
                    return RoomCard(room: room);
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              DebugPrint("error : $error");
              return Center(
                child: Text(
                  'エラーが発生しました: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }),
        Positioned(
          right: 16,
          bottom: 32,
          child: FloatingActionButton(
            shape: const StadiumBorder(),
            onPressed: () => _showCreateRoomDialog(context, ref),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.mic),
          ),
        ),
      ],
    );
  }

  void _showCreateRoomDialog(BuildContext context, WidgetRef ref) {
    final isMember = ref.watch(communityMembershipProvider(community.id));
    if (!isMember) {
      showJoinDialog(context, ref, community.id);
    } else {
      showDialog(
        context: context,
        builder: (context) => CreateRoomDialog(community: community),
      );
    }
  }
}

// まずタグのプロバイダーを作成
final selectedTagsProvider = StateProvider<List<String>>((ref) => []);

// タグのリストを定義（または別途管理）
final roomTagsList = [
  "雑談",
  "恋愛",
  "相談",
  "勉強",
  "定期テスト",
  "課題",
  "趣味",
  "バイト",
  "サークル",
  "青春",
  //
  "勉強方法",
  "学校生活",
  "部活動",
  "受験対策",
  "悩み相談",
  "塾選び",
  "文化祭",
  "習い事",
  "テスト週間",
  "学校行事",
  //
  "レポート",
  "バイト探し",
  "一人暮らし",
  "サークル",
  "就活情報",
  "インターン",
  "資格取得",
  "研究室",
  "ゼミ活動",
  "教授情報",
  "キャンパスライフ",
];

class CreateRoomDialog extends ConsumerWidget {
  const CreateRoomDialog({super.key, required this.community});
  final Community community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final titleController = TextEditingController();
    final maxParticipantsController = TextEditingController(text: "20");
    final selectedTags = ref.watch(selectedTagsProvider);

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'ルームを作成',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'ルーム名',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxParticipantsController,
              decoration: const InputDecoration(
                labelText: '最大参加人数',
                labelStyle: TextStyle(color: Colors.white),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'タグを選択（最大3つまで）',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: roomTagsList.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  surfaceTintColor: Colors.white.withOpacity(0.1),
                  selected: isSelected,

                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  //labelPadding: EdgeInsets.zero,
                  label: Text(
                    '#$tag',
                    style: textStyle.w400(),
                  ),
                  onSelected: (selected) {
                    if (selected && selectedTags.length < 3) {
                      ref.read(selectedTagsProvider.notifier).state = [
                        ...selectedTags,
                        tag,
                      ];
                    } else if (!selected) {
                      ref.read(selectedTagsProvider.notifier).state =
                          selectedTags.where((t) => t != tag).toList();
                    }
                  },
                  backgroundColor: ThemeColor.stroke,
                  selectedColor: Colors.blue,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(selectedTagsProvider.notifier).state = [];
            Navigator.pop(context);
          },
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () => _createRoom(
            context,
            ref,
            titleController.text,
            int.parse(maxParticipantsController.text),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text('作成'),
        ),
      ],
    );
  }

  void _createRoom(BuildContext context, WidgetRef ref, String title,
      int maxParticipants) async {
    if (title.isEmpty) return;

    final selectedTags = ref.read(selectedTagsProvider);

    try {
      final room = Room(
        id: const Uuid().v4(),
        communityId: community.id,
        title: title,
        userId: ref.read(authProvider).currentUser!.uid,
        tags: selectedTags, // 選択されたタグを設定
        currentParticipants: 1,
        maxParticipants: maxParticipants,
        isLive: false,
        joinedUserIds: [
          ref.read(authProvider).currentUser!.uid,
        ],
        createdAt: DateTime.now(),
      );

      await ref
          .watch(firestoreProvider)
          .collection("rooms")
          .doc(room.id)
          .set(room.toJson());

      if (context.mounted) {
        // タグの選択状態をリセット
        ref.read(selectedTagsProvider.notifier).state = [];
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(room: room),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ルームの作成に失敗しました: $e')),
        );
      }
    }
  }
}

class RoomCard extends ConsumerWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: ThemeColor.stroke,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToRoom(context),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textStyle),
                const Gap(16),
                _buildParticipants(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeTextStyle textStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.title,
                style: textStyle.w600(
                  fontSize: 22,
                ),
              ),
              if (room.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: room.tags
                        .map((tag) => _buildTag(tag, textStyle))
                        .toList(),
                  ),
                )
            ],
          ),
        ),
        if (room.isLive)
          Container(
            margin: const EdgeInsets.only(top: 4, left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: textStyle.w600(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildParticipants(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final currentUser = ref.watch(authProvider).currentUser;
    final hasJoined = room.joinedUserIds.contains(currentUser?.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '参加者',
              style: textStyle.w600(
                color: ThemeColor.subText,
                fontSize: 14,
              ),
            ),
            const Gap(4),
            Text(
              '${room.currentParticipants}/${room.maxParticipants}人',
              style: textStyle.numText(
                color: ThemeColor.subText,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<UserAccount>>(
                future: ref
                    .read(allUsersNotifierProvider.notifier)
                    .getUserAccounts(room.joinedUserIds),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final participants = snapshot.data!;
                  return SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participants.length * 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: UserIcon(
                            user: participants[index % participants.length],
                            isCircle: true,
                            width: 40,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Gap(4),
            ElevatedButton(
              onPressed: hasJoined
                  ? () => _leaveRoom(context, ref)
                  : () => _joinRoom(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasJoined ? Colors.red : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                hasJoined ? '退出する' : '参加する',
                style: textStyle.w600(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _joinRoom(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    if (room.currentParticipants >= room.maxParticipants) {
      showMessage('ルームが満員です');
      return;
    }

    try {
      await ref.read(roomProvider(room.id).notifier).joinRoom(currentUser.uid);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(room: room),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _leaveRoom(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(authProvider).currentUser;
    if (currentUser == null) return;

    try {
      await ref.read(roomProvider(room.id).notifier).leaveRoom(currentUser.uid);

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showMessage(
          e.toString(),
        );
      }
    }
  }

  Widget _buildTag(String tag, ThemeTextStyle textStyle) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.button.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        tag,
        style: textStyle.w600(
          fontSize: 14,
        ),
      ),
    );
  }

  void _navigateToRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomScreen(room: room),
      ),
    );
  }
}

// 4. 情報タブの実装
class InfoTab extends ConsumerWidget {
  const InfoTab({super.key, required this.community});
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'コミュニティについて',
          child: Text(
            community.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: 'コミュニティルール',
          child: Column(
            children: community.rules.map((rule) => _buildRule(rule)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        FutureBuilder(
            future: ref
                .read(allUsersNotifierProvider.notifier)
                .getUserAccounts(community.moderators),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                    "error : ${snapshot.error}, ${snapshot.stackTrace}");
              }
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              final users = snapshot.data!;
              return _buildSection(
                title: 'モデレーター',
                child: Column(
                  children: users
                      .map((user) => _buildModerator(context, ref, user))
                      .toList(),
                ),
              );
            }),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildRule(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerator(
      BuildContext context, WidgetRef ref, UserAccount user) {
    return ListTile(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      contentPadding: EdgeInsets.zero,
      leading: UserIcon(
        user: user,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "モデレータ",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          Text(
            '${_getTimeAgo(user.createdAt.toDate())}から',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.message_outlined, color: Colors.grey),
        onPressed: () {},
        // onPressed: () => _contactModerator(context, moderator),
      ),
    );
  }
}

// ユーティリティ関数
String _getTimeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()}年前';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()}ヶ月前';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}日前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}時間前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}分前';
  } else {
    return 'たった今';
  }
}
