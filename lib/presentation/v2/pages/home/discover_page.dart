import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../constants/tempo_colors.dart';
import '../../constants/tempo_text_styles.dart';
import '../../constants/tempo_spacing.dart';
import '../../widgets/tempo_status_card.dart';
import '../../widgets/tempo_user_avatar.dart';
import '../edit_status/edit_status_page.dart';

class DiscoverPage extends HookConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    
    return Scaffold(
      backgroundColor: TempoColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(TempoSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => TempoColors.primaryGradient
                              .createShader(bounds),
                          child: const Text(
                            'Tempo',
                            style: TempoTextStyles.display2,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TempoSpacing.md,
                            vertical: TempoSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: TempoColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: TempoColors.online,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: TempoSpacing.sm),
                              Text(
                                '127人オンライン',
                                style: TempoTextStyles.caption.copyWith(
                                  color: TempoColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TempoSpacing.sm),
                    Text(
                      '今この瞬間を、誰かと',
                      style: TempoTextStyles.bodyMedium.copyWith(
                        color: TempoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Current Status Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TempoSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '今の気分は？',
                          style: TempoTextStyles.headline3.copyWith(
                            color: TempoColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditStatusPage(),
                              ),
                            );
                          },
                          child: Text(
                            '変更',
                            style: TempoTextStyles.bodySmall.copyWith(
                              color: TempoColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TempoSpacing.md),
                    const TempoStatusCard(
                      isMyStatus: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: TempoSpacing.xl)),
            
            // Nearby Users Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TempoSpacing.lg),
                child: Text(
                  '同じテンポの人たち',
                  style: TempoTextStyles.headline3.copyWith(
                    color: TempoColors.textPrimary,
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: TempoSpacing.lg)),
            
            // User Cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: TempoSpacing.lg,
                      right: TempoSpacing.lg,
                      bottom: TempoSpacing.md,
                    ),
                    child: _buildUserCard(index),
                  );
                },
                childCount: 10,
              ),
            ),
            
            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: TempoSpacing.xxxl),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: マッチング開始
        },
        backgroundColor: TempoColors.primary,
        icon: const Icon(Icons.explore, color: Colors.white),
        label: Text(
          '新しい人を探す',
          style: TempoTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(int index) {
    final users = [
      {'name': 'あかり', 'activity': 'Netflix見てる', 'mood': '😊', 'time': '2分前'},
      {'name': 'ひろき', 'activity': '勉強中', 'mood': '🤔', 'time': '5分前'},
      {'name': 'みお', 'activity': 'ゲーム', 'mood': '😎', 'time': '8分前'},
      {'name': 'たけし', 'activity': '散歩', 'mood': '🥺', 'time': '12分前'},
      {'name': 'さくら', 'activity': 'カフェでまったり', 'mood': '😪', 'time': '15分前'},
    ];
    
    final user = users[index % users.length];
    
    return Container(
      padding: const EdgeInsets.all(TempoSpacing.cardPadding),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TempoColors.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          TempoUserAvatar(
            imageUrl: null,
            size: TempoSpacing.avatarMedium,
            isOnline: true,
            mood: user['mood']!,
          ),
          const SizedBox(width: TempoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']!,
                  style: TempoTextStyles.bodyMedium.copyWith(
                    color: TempoColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['activity']!,
                  style: TempoTextStyles.bodySmall.copyWith(
                    color: TempoColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['time']!,
                  style: TempoTextStyles.caption.copyWith(
                    color: TempoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TempoSpacing.md,
              vertical: TempoSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: TempoColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '話そう',
              style: TempoTextStyles.buttonMedium.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}