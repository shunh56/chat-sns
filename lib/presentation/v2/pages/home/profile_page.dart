import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import '../../constants/tempo_colors.dart';
import '../../constants/tempo_text_styles.dart';
import '../../constants/tempo_spacing.dart';
import '../../widgets/tempo_user_avatar.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TempoColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TempoSpacing.lg),
          child: Column(
            children: [
              // Profile Header (元のUI)
              Container(
                padding: const EdgeInsets.all(TempoSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: TempoColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'マイプロフィール',
                          style: TempoTextStyles.headline2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: 設定画面へ
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TempoSpacing.xl),
                    const TempoUserAvatar(
                      imageUrl: null,
                      size: TempoSpacing.avatarXLarge,
                      isOnline: true,
                      mood: '😊',
                      showEditButton: true,
                    ),
                    const SizedBox(height: TempoSpacing.md),
                    Text(
                      'あなた',
                      style: TempoTextStyles.headline2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: TempoSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TempoSpacing.md,
                        vertical: TempoSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '今この瞬間を大切にする人',
                        style: TempoTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(TempoSpacing.xl),

              // Stats Section (元のUI)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '総接続数',
                      '47',
                      Icons.people,
                      TempoColors.primaryGradient,
                    ),
                  ),
                  const Gap(TempoSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      '今月の接続',
                      '12',
                      Icons.calendar_today,
                      TempoColors.warmGradient,
                    ),
                  ),
                  const Gap(TempoSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      '応援回数',
                      '156',
                      Icons.favorite,
                      TempoColors.successGradient,
                    ),
                  ),
                ],
              ),

              const Gap(TempoSpacing.xl),

              // 今週のテンポセクション（mockに基づく実装）
              _buildTempoStatsCard(),

              const Gap(TempoSpacing.xl),

              // コレクションセクション
              _buildCollectionCard(),

              const Gap(TempoSpacing.xl),

              // 友達を招待しようセクション
              _buildInviteFriendsCard(),

              const Gap(TempoSpacing.xl),

              // 設定メニューセクション
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 今週のテンポセクション（mockデザインに基づく）
  Widget _buildTempoStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TempoSpacing.cardPadding),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TempoColors.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌊', style: TextStyle(fontSize: 24)),
              const Gap(TempoSpacing.sm),
              Text(
                '今週のテンポ',
                style: TempoTextStyles.headline3.copyWith(
                  color: TempoColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(TempoSpacing.lg),
          // よく感じた気分
          _buildProgressItem('😪', 'よく感じた気分', 0.6, TempoColors.primaryGradient),
          const Gap(TempoSpacing.md),
          // よくいた場所
          _buildProgressItem('🏠', 'よくいた場所', 0.8, TempoColors.warmGradient),
          const Gap(TempoSpacing.md),
          // つながった回数
          _buildProgressItem('✨', 'つながった回数', 0.45, TempoColors.successGradient),
          const Gap(TempoSpacing.lg),
          // シェアボタン
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: TempoSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: TempoColors.textTertiary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 18)),
                  const Gap(TempoSpacing.sm),
                  Text(
                    '週間レポートをシェア',
                    style: TempoTextStyles.bodyMedium.copyWith(
                      color: TempoColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String emoji, String label, double progress, LinearGradient gradient) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const Gap(TempoSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TempoTextStyles.bodyMedium.copyWith(
                      color: TempoColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TempoTextStyles.bodySmall.copyWith(
                      color: TempoColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Gap(TempoSpacing.xs),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: TempoColors.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // コレクションセクション
  Widget _buildCollectionCard() {
    const badges = [
      {'emoji': '🌅', 'name': '朝型', 'earned': true},
      {'emoji': '🤝', 'name': '社交家', 'earned': true},
      {'emoji': '💬', 'name': '話し上手', 'earned': true},
      {'emoji': '✨', 'name': '応援者', 'earned': false},
      {'emoji': '🎯', 'name': '達人', 'earned': false},
      {'emoji': '📱', 'name': 'シェア王', 'earned': true},
      {'emoji': '🔥', 'name': '人気者', 'earned': false},
      {'emoji': '🌟', 'name': '伝説', 'earned': false},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TempoSpacing.cardPadding),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TempoColors.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const Gap(TempoSpacing.sm),
              Text(
                'コレクション',
                style: TempoTextStyles.headline3.copyWith(
                  color: TempoColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(TempoSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isEarned = badge['earned'] as bool;
              return Container(
                padding: const EdgeInsets.all(TempoSpacing.sm),
                decoration: BoxDecoration(
                  color: isEarned
                      ? TempoColors.primary.withOpacity(0.1)
                      : TempoColors.textTertiary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEarned
                        ? TempoColors.primary.withOpacity(0.3)
                        : TempoColors.textTertiary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      badge['emoji'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        color: isEarned ? null : Colors.grey,
                      ),
                    ),
                    const Gap(TempoSpacing.xs),
                    Text(
                      badge['name'] as String,
                      style: TempoTextStyles.caption.copyWith(
                        color: isEarned
                            ? TempoColors.textPrimary
                            : TempoColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 友達を招待しようセクション
  Widget _buildInviteFriendsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TempoSpacing.cardPadding),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TempoColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 48)),
          const Gap(TempoSpacing.md),
          Text(
            '友達を招待しよう',
            style: TempoTextStyles.headline3.copyWith(
              color: TempoColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(TempoSpacing.sm),
          Text(
            '特別な人を招待して、一緒にTempoを楽しもう',
            style: TempoTextStyles.bodyMedium.copyWith(
              color: TempoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(TempoSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TempoSpacing.md),
            decoration: BoxDecoration(
              gradient: TempoColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TempoColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📨', style: TextStyle(fontSize: 18)),
                  const Gap(TempoSpacing.sm),
                  Text(
                    '招待リンクを送る',
                    style: TempoTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(TempoSpacing.sm),
          RichText(
            text: TextSpan(
              text: '今月あと ',
              style: TempoTextStyles.caption.copyWith(
                color: TempoColors.textTertiary,
              ),
              children: const [
                TextSpan(
                  text: '2回',
                  style: TextStyle(
                    color: TempoColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' 招待できます'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 設定セクション
  Widget _buildSettingsSection() {
    const menuItems = [
      {
        'icon': Icons.notifications,
        'title': '通知設定',
        'description': 'プッシュ通知の管理'
      },
      {
        'icon': Icons.nightlight_round,
        'title': 'ダークモード',
        'description': '目に優しい表示'
      },
      {'icon': Icons.lock_outline, 'title': 'プライバシー', 'description': '公開設定の変更'},
      {
        'icon': Icons.star_outline,
        'title': 'レビューを書く',
        'description': 'App Storeで評価'
      },
    ];

    return Column(
      children: menuItems
          .map((item) => _buildSettingsItem(
                item['icon'] as IconData,
                item['title'] as String,
                item['description'] as String,
                () {},
              ))
          .toList(),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: TempoSpacing.md),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(TempoSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(TempoSpacing.sm),
                  decoration: BoxDecoration(
                    color: TempoColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: TempoColors.primary,
                    size: 20,
                  ),
                ),
                const Gap(TempoSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TempoTextStyles.bodyMedium.copyWith(
                          color: TempoColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        description,
                        style: TempoTextStyles.bodySmall.copyWith(
                          color: TempoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: TempoColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 元のStatCard実装を追加
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(TempoSpacing.md),
      decoration: BoxDecoration(
        color: TempoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TempoColors.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(TempoSpacing.sm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Gap(TempoSpacing.sm),
          Text(
            value,
            style: TempoTextStyles.headline2.copyWith(
              color: TempoColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TempoTextStyles.caption.copyWith(
              color: TempoColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
