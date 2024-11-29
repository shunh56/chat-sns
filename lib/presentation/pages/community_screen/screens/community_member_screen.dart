import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/community.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CommunityMemberScreen extends ConsumerWidget {
  const CommunityMemberScreen({
    super.key,
    required this.community,
  });
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(communityMembersNotifierProvider);
    final scrollController = ScrollController();
    /*scrollController.addListener(() async {
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent + 120) {
        final pos = scrollController.position.maxScrollExtent;
        bool reload = await ref
            .read(communityMembersNotifierProvider.notifier)
            .loadMore();
        if (reload && scrollController.hasClients) {
          scrollController.jumpTo(pos);
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }); */
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "メンバー",
          style: textStyle.appbarText(isSmall: true),
        ),
      ),
      body: asyncValue.maybeWhen(
        data: (members) {
          return RefreshIndicator(
            backgroundColor: ThemeColor.accent,
            onRefresh: () async {
              await ref
                  .read(communityMembersNotifierProvider.notifier)
                  .refresh();
            },
            child: ListView.builder(
              //controller: scrollController,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final user = members[index].user;
                final joinedAt = members[index].joinedAt;

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(navigationRouterProvider(context))
                        .goToProfile(user);
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: UserIcon(user: user),
                            ),
                            if (user.greenBadge)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: ThemeColor.accent,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(8),
                              Text(
                                user.name,
                                style: textStyle.w600(fontSize: 16),
                              ),
                              const Gap(8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_outlined,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const Gap(4),
                                  Text(
                                    "${joinedAt.xxAgo}に参加",
                                    style: textStyle.w400(
                                      fontSize: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              if (user.aboutMe.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.aboutMe,
                                          style: textStyle.w400(
                                            fontSize: 14,
                                            height: 1.8,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
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
                );
              },
            ),
          );
        },
        orElse: () => const SizedBox(),
      ),
    );
  }
}
