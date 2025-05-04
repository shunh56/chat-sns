/*import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/pages/onboarding/providers/providers.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/invite_code_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddOtherFriendsScreen extends ConsumerWidget {
  const AddOtherFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final selectedOtherIds = ref.watch(selectedOtherIdsProvider);
    final myAccountAsync = ref.watch(myAccountNotifierProvider);
    final usedCode = myAccountAsync.asData?.value.usedCode;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            "友達を追加",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ThemeColor.text,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FutureBuilder(
              future: _getFriends(ref, usedCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ThemeColor.primary),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    ref.read(pageControllerProvider).nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                  });
                  return const SizedBox();
                }

                final users = snapshot.data!;
                final inviter = users[0];
                final friends = users.sublist(1);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          UserIcon(
                            user: inviter,
                            width: 120,
                            navDisabled: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${inviter.name}さんの友達",
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final friend = friends[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: ThemeColor.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ThemeColor.stroke),
                            ),
                            child: InkWell(
                              onTap: () {
                                final list =
                                    List<String>.from(selectedOtherIds);
                                if (list.contains(friend.userId)) {
                                  list.remove(friend.userId);
                                } else {
                                  list.add(friend.userId);
                                }
                                ref
                                    .read(selectedOtherIdsProvider.notifier)
                                    .state = list;
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    UserIcon(
                                      user: friend,
                                      width: 48,
                                      navDisabled: true,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        friend.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: ThemeColor.text,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selectedOtherIds
                                                .contains(friend.userId)
                                            ? ThemeColor.primary
                                            : ThemeColor.surface,
                                        border: Border.all(
                                          color: selectedOtherIds
                                                  .contains(friend.userId)
                                              ? ThemeColor.primary
                                              : ThemeColor.stroke,
                                        ),
                                      ),
                                      child: selectedOtherIds
                                              .contains(friend.userId)
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: friends.length,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(pageControllerProvider).nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primary,
              foregroundColor: ThemeColor.text,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              selectedOtherIds.isEmpty ? "スキップ" : "次へ",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /*Future<List<UserAccount>?> _getFriends(WidgetRef ref, String? usedCode) async {
    if (usedCode == null) return null;
    try {
      final code = await ref.read(inviteCodeUsecaseProvider).getInviteCode(usedCode);
      final user = (await ref
          .read(allUsersNotifierProvider.notifier)
          .getUserAccounts([code.userId]))
          .firstOrNull;
      if (user == null) return null;
      final friends = await ref
          .read(friendIdListNotifierProvider.notifier)
          .getFriends(user.userId);
      return [user, ...friends];
    } catch (e) {
      return null;
    }
  } */
}
 */