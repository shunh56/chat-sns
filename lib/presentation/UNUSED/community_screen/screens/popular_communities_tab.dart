// views/popular_communities_tab.dart
import 'package:app/presentation/UNUSED/community_screen/components/community_card.dart';
import 'package:app/presentation/providers/community.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityLoadingProvider = StateProvider<bool>((ref) => false);

// エラーメッセージを管理するプロバイダー
final communityErrorProvider = StateProvider<String?>((ref) => null);

class PopularCommunitiesTab extends ConsumerWidget {
  const PopularCommunitiesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularCommunitiesAsync = ref.watch(popularCommunitiesProvider);
    final joinedCommunityIds = ref.watch(joinedCommunityIdsProvider);

    return popularCommunitiesAsync.when(
      data: (communities) => RefreshIndicator(
        onRefresh: () => ref.refresh(popularCommunitiesProvider.future),
        child: ListView.builder(
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            return CommunityCard(
              community: community,
              isJoined:
                  joinedCommunityIds.value?.contains(community.id) ?? false,
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラーが発生しました: $error, $stackTrace'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(popularCommunitiesProvider),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }
}
