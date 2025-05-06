import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

// Firestoreのインスタンス
final firestore = FirebaseFirestore.instance;

// ユーザー検索のProvider
final userSearchProvider =
    FutureProvider.family<List<UserAccount>, String>((ref, query) async {
  final usecase = ref.read(userUsecaseProvider);
  if (query.isEmpty) {
    return [];
  }
  final nameList = await usecase.searchUserByName(query);
  final nameListUserIds = nameList.map((user) => user.userId).toSet();
  final usernameList = await usecase.searchUserByUsername(query);
  final uniqueUsernameResults =
      usernameList.where((user) => !nameListUserIds.contains(user.userId));

  return [...nameList, ...uniqueUsernameResults];
});

class CreateChatsScreen extends ConsumerStatefulWidget {
  const CreateChatsScreen({super.key});

  @override
  ConsumerState<CreateChatsScreen> createState() => _CreateChatsScreenState();
}

class _CreateChatsScreenState extends ConsumerState<CreateChatsScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final searchResults = ref.watch(userSearchProvider(searchQuery));
    final filters = [ref.read(authProvider).currentUser!.uid];
    final followings =
        ref.watch(followingListNotifierProvider).asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'チャットを始める',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onSubmitted: (value) => setState(() => searchQuery = value),
              style: textStyle.w400(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'ユーザー名で検索',
                hintStyle: textStyle.w400(
                  color: ThemeColor.headline,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // 検索結果
          Expanded(
            child: searchResults.when(
              data: (users) {
                if (searchQuery.isEmpty) {
                  final followingIds =
                      followings.map((relation) => relation.userId).toList();
                  if (followingIds.isEmpty) {
                    return const Center(
                      child: Text(
                        'ユーザーが見つかりませんでした',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: followingIds.length,
                      itemBuilder: (context, index) {
                        final user = ref
                            .read(allUsersNotifierProvider)
                            .asData!
                            .value[followingIds[index]]!;

                        return CreateChatTile(user: user);
                      },
                    );
                  }
                }
                users.removeWhere((user) => filters.contains(user.userId));
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'ユーザーが見つかりませんでした',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return CreateChatTile(user: user);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'エラーが発生しました: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateChatTile extends ConsumerWidget {
  const CreateChatTile({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: ThemeColor.accent,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.1),
          onTap: () {
            ref
                .read(navigationRouterProvider(context))
                .goToChat(user, replace: true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserIcon(
                  user: user,
                  width: 48,
                  isCircle: true,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.text,
                              height: 1,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            "@${user.username}",
                            style: textStyle.w400(
                              color: ThemeColor.subText,
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
        ),
      ),
    );
  }
}
