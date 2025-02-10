import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/phase_01/search_screen/widgets/tiles.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class SearchParamsScreen extends ConsumerStatefulWidget {
  const SearchParamsScreen({super.key});

  @override
  ConsumerState<SearchParamsScreen> createState() => _SearchParamsScreenState();
}

class _SearchParamsScreenState extends ConsumerState<SearchParamsScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(userSearchProvider(searchQuery));
    final filters = [ref.read(authProvider).currentUser!.uid];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ユーザーを検索',
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
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ユーザー名で検索',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // 検索結果
          Expanded(
            child: searchResults.when(
              data: (users) {
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
                    return UserRequestWidget(user: user);
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
