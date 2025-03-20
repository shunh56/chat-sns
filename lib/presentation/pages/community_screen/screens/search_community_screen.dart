import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/pages/community_screen/components/community_card.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/usecase/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = StateProvider<List<Community>>((ref) => []);

class SearchCommunityScreen extends ConsumerWidget {
  const SearchCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(ref),
            Expanded(
              child: _buildSearchResults(searchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // blue-gray-800
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withOpacity(0.5), // blue-gray-600
        ),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
          _performSearch(ref, value);
        },
        decoration: InputDecoration(
          hintText: 'コミュニティを検索',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Community> results) {
    return results.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: results.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final community = results[index];
              return CommunityCard(
                community: community,
                isJoined: false, // この値は適切に設定する必要があります
              );
            },
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey[600],
          ),
          const Gap(16),
          Text(
            'コミュニティが見つかりませんでした',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(WidgetRef ref, String query) async {
    if (query.isEmpty) {
      ref.read(searchResultsProvider.notifier).state = [];
      return;
    }

    try {
      //TODO
      final communities =
          await ref.read(communityUsecaseProvider).searchCommunities(query);
      ref.read(searchResultsProvider.notifier).state = communities;
    } catch (e) {
      DebugPrint('Search error: $e');
      // エラーハンドリングを実装
    }
  }
}
