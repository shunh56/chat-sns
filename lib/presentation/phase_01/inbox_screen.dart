import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/phase_01/friend_request_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final requestIds =
        ref.watch(friendRequestIdListNotifierProvider).asData?.value ?? [];
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("リクエスト"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
            child: Text(
              "ユーザーからのフレンドリクエストを確認できます。また、自分が送ったリクエストも探すことができます。",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Gap(themeSize.verticalSpaceSmall),
          Material(
            color: Colors.white.withOpacity(0.05),
            child: InkWell(
              splashColor: ThemeColor.highlight,
              highlightColor: ThemeColor.beige.withOpacity(0.3),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FriendRequestScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.asset(
                        "assets/images/icons/send.svg",
                        
                        color: ThemeColor.button,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      "自分が送ったリクエスト",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    requestIds.isNotEmpty
                        ? Text(
                            "${requestIds.length}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox(),
                    const Gap(12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ThemeColor.button,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: friendRequestedListView(ref),
          ),
        ],
      ),
    );
  }

  Widget friendRequestedListView(WidgetRef ref) {
    final asyncValue = ref.watch(friendRequestedIdListNotifierProvider);
    return asyncValue.when(
      data: (requestedIds) {
        return ListView(
          children: [
            const Gap(12),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "フレンドリクエスト",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.text,
                ),
              ),
            ),
            const Gap(6),
            requestedIds.isEmpty
                ? const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text("ユーザーからのリクエストはいません。"),
                    ),
                  )
                : ListView.builder(
                    //padding: EdgeInsets.symmetric(horizontal: 12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requestedIds.length,
                    itemBuilder: (context, index) {
                      final userId = requestedIds[index];
                      final user = ref
                          .read(allUsersNotifierProvider)
                          .asData!
                          .value[userId]!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(navigationRouterProvider(context))
                                    .goToProfile(user);
                              },
                              child: UserIcon.tileIcon(user),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(4),
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeColor.text,
                                    ),
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Material(
                                            color: Colors.pink,
                                            child: InkWell(
                                              splashColor:
                                                  Colors.black.withOpacity(0.3),
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                ref
                                                    .read(
                                                        friendRequestedIdListNotifierProvider
                                                            .notifier)
                                                    .admitFriendRequested(
                                                        userId);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: const Center(
                                                  child: Text(
                                                    "フレンドに追加",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Material(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            child: InkWell(
                                              splashColor:
                                                  Colors.black.withOpacity(0.3),
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                ref
                                                    .read(
                                                        friendRequestedIdListNotifierProvider
                                                            .notifier)
                                                    .deleteRequested(userId);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: const Center(
                                                  child: Text(
                                                    "削除",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                      );
                    },
                  ),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}
