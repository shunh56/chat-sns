import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../constants/tempo_colors.dart';
import '../../constants/tempo_text_styles.dart';
import '../../constants/tempo_spacing.dart';
import '../../widgets/tempo_user_avatar.dart';
import '../../widgets/tempo_time_indicator.dart';

class ConnectionsPage extends HookConsumerWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    
    return Scaffold(
      backgroundColor: TempoColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(TempoSpacing.lg),
              child: Row(
                children: [
                  Text(
                    '24時間フレンド',
                    style: TempoTextStyles.headline2.copyWith(
                      color: TempoColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TempoSpacing.md,
                      vertical: TempoSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: TempoColors.warmGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: TempoSpacing.sm),
                        Text(
                          '3人',
                          style: TempoTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: TempoSpacing.lg),
              decoration: BoxDecoration(
                color: TempoColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  gradient: TempoColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: TempoColors.textSecondary,
                labelStyle: TempoTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TempoTextStyles.bodySmall,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'アクティブ'),
                  Tab(text: '履歴'),
                ],
              ),
            ),
            
            const SizedBox(height: TempoSpacing.lg),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _buildActiveConnections(),
                  _buildConnectionHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveConnections() {
    final connections = [
      {
        'name': 'あかり',
        'activity': 'Netflix見てる',
        'mood': '😊',
        'startTime': DateTime.now().subtract(const Duration(hours: 3)),
        'lastMessage': 'このアニメ面白いね！',
        'unreadCount': 2,
      },
      {
        'name': 'ひろき',
        'activity': '勉強中',
        'mood': '🤔',
        'startTime': DateTime.now().subtract(const Duration(hours: 8)),
        'lastMessage': '一緒に頑張ろう',
        'unreadCount': 0,
      },
      {
        'name': 'みお',
        'activity': 'ゲーム',
        'mood': '😎',
        'startTime': DateTime.now().subtract(const Duration(hours: 15)),
        'lastMessage': 'おつかれさま！',
        'unreadCount': 1,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: TempoSpacing.lg),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final connection = connections[index];
        final startTime = connection['startTime'] as DateTime;
        final remaining = const Duration(hours: 24) - 
            DateTime.now().difference(startTime);
        
        return Container(
          margin: const EdgeInsets.only(bottom: TempoSpacing.md),
          padding: const EdgeInsets.all(TempoSpacing.cardPadding),
          decoration: BoxDecoration(
            color: TempoColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TempoColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  TempoUserAvatar(
                    imageUrl: null,
                    size: TempoSpacing.avatarMedium,
                    isOnline: true,
                    mood: connection['mood'] as String,
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: TempoTimeIndicator(
                      remaining: remaining,
                      total: const Duration(hours: 24),
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: TempoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          connection['name'] as String,
                          style: TempoTextStyles.bodyMedium.copyWith(
                            color: TempoColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((connection['unreadCount'] as int) > 0) ...[
                          const SizedBox(width: TempoSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: TempoColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${connection['unreadCount']}',
                              style: TempoTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connection['activity'] as String,
                      style: TempoTextStyles.bodySmall.copyWith(
                        color: TempoColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connection['lastMessage'] as String,
                      style: TempoTextStyles.caption.copyWith(
                        color: TempoColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(TempoSpacing.sm),
                decoration: BoxDecoration(
                  gradient: TempoColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionHistory() {
    final history = [
      {
        'name': 'さくら',
        'activity': 'カフェでまったり',
        'mood': '😪',
        'date': '昨日',
        'duration': '18時間',
        'memory': '素敵な話ができました',
      },
      {
        'name': 'たけし',
        'activity': '散歩',
        'mood': '🥺',
        'date': '2日前',
        'duration': '24時間',
        'memory': '一緒に散歩の話をしました',
      },
      {
        'name': 'ゆい',
        'activity': '映画鑑賞',
        'mood': '😊',
        'date': '3日前',
        'duration': '12時間',
        'memory': '映画の感想で盛り上がりました',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: TempoSpacing.lg),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: TempoSpacing.md),
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
                isOnline: false,
                mood: item['mood'] as String,
              ),
              const SizedBox(width: TempoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: TempoTextStyles.bodyMedium.copyWith(
                        color: TempoColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['date']} • ${item['duration']}',
                      style: TempoTextStyles.bodySmall.copyWith(
                        color: TempoColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['memory'] as String,
                      style: TempoTextStyles.caption.copyWith(
                        color: TempoColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: 思い出カード表示
                },
                icon: const Icon(
                  Icons.auto_awesome,
                  color: TempoColors.accent,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}