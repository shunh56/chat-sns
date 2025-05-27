import 'package:app/presentation/pages/_new/models/stats_model.dart';
import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import './widgets/cosmic_background.dart';
import './widgets/stellar_user_widget.dart';
import './widgets/stat_bubble.dart';
import './widgets/mode_selector.dart';
import './widgets/floating_controls.dart';
import './providers/discovery_provider.dart';
import './providers/stats_provider.dart';
import './models/user_model.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryState = ref.watch(discoveryProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(AppConstants.containerPadding),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(0.3, -0.2),
            radius: 1.2,
            colors: [
              Color(0x1FFF006E),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(37),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(-0.7, 0.8),
              radius: 1.2,
              colors: [
                Color(0x1F8338EC),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(37),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundDark,
                  AppColors.backgroundMedium,
                  AppColors.backgroundLight,
                ],
              ),
              borderRadius: BorderRadius.circular(37),
            ),
            child: Stack(
              children: [
                // Cosmic Background
                const CosmicBackground(),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(stats),
                      const Gap(20),
                      _buildUserConstellation(discoveryState.users),
                    ],
                  ),
                ),

                // Floating Controls
                const FloatingControls(),

                // Detail Panels
                if (discoveryState.activePanel != null)
                  _buildDetailPanel(
                    context,
                    ref,
                    discoveryState.activePanel!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StatsModel stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.titleGradient.createShader(bounds),
            child: const Text(
              'BLANK',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 6.seconds, color: Colors.white.withOpacity(0.3)),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            '新感覚で新しい出会いを発見',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 800.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatBubble(
                value: '${stats.discoveredCount}',
                label: '見つけた人',
                tooltip: '今まで見つけた人の数',
              ),
              StatBubble(
                value: '${stats.matchPercentage}%',
                label: 'マッチ度',
                tooltip: 'あなたとの相性の良さ',
              ),
              StatBubble(
                value: '${stats.mutualLikes}',
                label: 'お互いいいね',
                tooltip: 'お互いに興味を持った人',
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Mode Selector
          const ModeSelector(),
        ],
      ),
    );
  }

  Widget _buildUserConstellation(List<UserModel> users) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            // User Planets
            ...users.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;

              return Positioned(
                top: _getUserPosition(user, index).dy,
                left: _getUserPosition(user, index).dx,
                child: StellarUserWidget(
                  user: user,
                  index: index,
                )
                    .animate(delay: (index * 100).ms)
                    .fadeIn(duration: 800.ms)
                    .scale(
                        begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Offset _getUserPosition(UserModel user, int index) {
    switch (user.type) {
      case UserType.primary:
        return const Offset(120, 200); // Center position

      case UserType.secondary:
        final positions = [
          const Offset(20, 50), // Top-left
          const Offset(200, 30), // Top-right
          const Offset(10, 300), // Bottom-left
          const Offset(220, 280), // Bottom-right
        ];
        return positions[index % positions.length];

      case UserType.tertiary:
        final positions = [
          const Offset(5, 150), // Mid-left
          const Offset(250, 180), // Mid-right
        ];
        return positions[index % positions.length];
    }
  }

  Widget _buildDetailPanel(
    BuildContext context,
    WidgetRef ref,
    DetailPanelType panelType,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getPanelTitle(panelType),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(discoveryProvider.notifier)
                        .toggleDetailPanel(null),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: _buildPanelContent(panelType),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 1, end: 0, duration: 400.ms);
  }

  String _getPanelTitle(DetailPanelType panelType) {
    switch (panelType) {
      case DetailPanelType.filter:
        return 'フィルター設定';
      case DetailPanelType.history:
        return '発見履歴';
      case DetailPanelType.analysis:
        return '相性分析';
    }
  }

  Widget _buildPanelContent(DetailPanelType panelType) {
    switch (panelType) {
      case DetailPanelType.filter:
        return _buildFilterContent();
      case DetailPanelType.history:
        return _buildHistoryContent();
      case DetailPanelType.analysis:
        return _buildAnalysisContent();
    }
  }

  Widget _buildFilterContent() {
    return const Column(
      children: [
        Text(
          'フィルター機能は開発中です。',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    return const Column(
      children: [
        Text(
          '履歴機能は開発中です。',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisContent() {
    return const Column(
      children: [
        Text(
          '分析機能は開発中です。',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
