import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/UNUSED/community_screen/components/components.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/community_chat_screen/community_chat_screen.dart';
import 'package:app/presentation/UNUSED/community_screen/screens/popular_communities_tab.dart';
import 'package:app/presentation/providers/community.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class _JoinButton extends ConsumerWidget {
  final Community community;
  final bool isJoined;

  const _JoinButton({
    required this.community,
    required this.isJoined,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(communityLoadingProvider);

    return isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : ElevatedButton(
            onPressed: () => _handleJoinTap(ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined ? Colors.blue : Colors.white,
              foregroundColor: isJoined ? Colors.white : Colors.blue,
            ),
            child: Text(isJoined ? '退会する' : '参加する'),
          );
  }

  Future<void> _handleJoinTap(WidgetRef ref) async {
    try {
      ref.read(communityLoadingProvider.notifier).state = true;
      ref.read(communityErrorProvider.notifier).state = null;

      final usecase = ref.read(communityUsecaseProvider);
      if (isJoined) {
        await usecase.leaveCommunity(community);
      } else {
        await usecase.joinCommunity(community);
      }
    } catch (e) {
      ref.read(communityErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(communityLoadingProvider.notifier).state = false;
    }
  }
}

class CommunityCard extends ConsumerWidget {
  final Community community;

  final bool isJoined;

  const CommunityCard({
    super.key,
    required this.community,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue =
        ref.watch(communityMembersNotifierProvider(community.id));
    return GestureDetector(
      onTap: () {
        if (!isJoined) {
          showMessage("コミュニティに参加していません。");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityChatScreen(community: community),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF111827),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF374151).withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                          bottom: 8,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CachedImage.postImage(
                                community.thumbnailImageUrl),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: FutureBuilder(
                          future: ref
                              .read(allUsersNotifierProvider.notifier)
                              .getUserAccounts([community.moderators[0]]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }
                            final user = snapshot.data![0];
                            return UserIcon(
                              user: user,
                              width: 40,
                              isCircle: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: textStyle.w600(
                            fontSize: 20,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          community.description,
                          maxLines: 2,
                          style: textStyle.w500(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Metrics Section
                        Wrap(
                          spacing: 12,
                          children: [
                            // Members Count
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                asyncValue.maybeWhen(
                                  data: (members) => UserStackIcons(
                                    users: members
                                        .map((member) => member.user)
                                        .toList(),
                                    imageRadius: 10,
                                    strokeColor: const Color(0xFF1F2937),
                                  ),
                                  orElse: () => const SizedBox(),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${community.memberCount}人のメンバー',
                                  style: textStyle.w400(
                                    fontSize: 14,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                              ],
                            ),
                            /*Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_outlined,
                                  size: 20,
                                  color: Colors.indigo[400],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '12.3k',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ), */
                            // Activity Status
                            /*Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Colors.indigo[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '高活性コミュニティ',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ), */
                          ],
                        ),
                        const Gap(12),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_outlined,
                              size: 16,
                              color: ThemeColor.subText,
                            ),
                            const Gap(4),
                            Text(
                              "${community.createdAt.toDateStr}〜",
                              style: textStyle.w400(
                                fontSize: 14,
                                color: ThemeColor.subText,
                              ),
                            ),
                          ],
                        )

                        // Tags Section
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: community.tags
                    .map(
                      (tag) => _buildTag(tag),
                    )
                    .toList(),
              ),
              // Header Section

              // Bottom Section with Next Event and Join Button
              if (!isJoined)
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _JoinButton(community: community, isJoined: isJoined),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ThemeColor.text,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
