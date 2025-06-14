import 'dart:math';

import 'package:app/presentation/pages/_new/models/stats_model.dart';
import 'package:app/presentation/pages/_new/models/user_model.dart';
import 'package:app/presentation/pages/_new/providers/discovery_provider.dart';
import 'package:app/presentation/pages/_new/providers/stats_provider.dart';
import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:app/presentation/pages/_new/utils/user_position_system.dart';
import 'package:app/presentation/pages/_new/widgets/cosmic_background.dart';
import 'package:app/presentation/pages/_new/widgets/floating_controls.dart';
import 'package:app/presentation/pages/_new/widgets/loading_widget.dart';
import 'package:app/presentation/pages/_new/widgets/mode_selector.dart';
import 'package:app/presentation/pages/_new/widgets/stat_bubble.dart';
import 'package:app/presentation/pages/_new/widgets/stellar_user_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _headerController;
  late AnimationController _modeTransitionController;
  late UserPositioningSystem _positioningSystem;
  List<UserPosition> _userPositions = [];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面サイズが取得できたら配置システムを初期化
    final screenSize = MediaQuery.of(context).size;
    _positioningSystem = UserPositioningSystem(
      screenSize: Size(
        screenSize.width * 0.7,
        screenSize.height * 0.5,
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _headerController.dispose();
    _modeTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryProvider);
    final stats = ref.watch(statsProvider);

    // ユーザーリストが変更された時に位置を再計算
    ref.listen(discoveryProvider.select((state) => state.users),
        (previous, next) {
      if (next.isNotEmpty &&
          (previous?.length != next.length || _userPositions.isEmpty)) {
        _regenerateUserPositions(next);
      }
    });

    // モード変更時のアニメーション
    ref.listen(discoveryProvider.select((state) => state.selectedMode),
        (previous, next) {
      if (previous != null && previous != next) {
        _triggerModeTransition();
      }
    });

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(AppConstants.containerPadding),
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(0.3, -0.2),
            radius: 1.2,
            colors: [
              Color(0x2FFF006E),
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
                Color(0x2F8338EC),
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
                //  Cosmic Background
                CosmicBackground(controller: _backgroundController),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(stats),
                      const Gap(20),
                      _buildUserConstellationWithPositioning(discoveryState),
                    ],
                  ),
                ),

                //  Floating Controls
                const FloatingControls(),

                // Detail Panels
                if (discoveryState.activePanel != null)
                  _buildDetailPanel(
                    context,
                    ref,
                    discoveryState.activePanel!,
                  ),

                // Debug info (開発時のみ表示)
                if (kDebugMode) _buildDebugInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _regenerateUserPositions(List<UserModel> users) {
    setState(() {
      _userPositions = _positioningSystem.generatePositions(users);
    });

    // デバッグ情報を出力
    if (kDebugMode) {
      final stats = _positioningSystem.getStats();
      print('Positioning Stats: $stats');
    }
  }

  Widget _buildHeader(StatsModel stats) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              //  Title
              Transform.scale(
                scale: 0.8 + (_headerController.value * 0.2),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.titleGradient.createShader(bounds),
                  child: const Text(
                    'BLANK',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: 4.seconds,
                    color: Colors.white.withOpacity(0.4),
                    angle: 45,
                  ),

              const SizedBox(height: 8),

              // Subtitle
              _buildTypewriterText(
                '新感覚で新しい出会いを発見',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              //  Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatBubble(
                    value: '${stats.discoveredCount}',
                    label: '見つけた人',
                    tooltip: '今まで見つけた人の数',
                    delay: 100.ms,
                    icon: Icons.people_outline,
                  ),
                  StatBubble(
                    value: '${stats.matchPercentage}%',
                    label: 'マッチ度',
                    tooltip: 'あなたとの相性の良さ',
                    delay: 200.ms,
                    icon: Icons.favorite_outline,
                  ),
                  StatBubble(
                    value: '${stats.mutualLikes}',
                    label: 'お互いいいね',
                    tooltip: 'お互いに興味を持った人',
                    delay: 300.ms,
                    icon: Icons.handshake_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              //  Mode Selector
              const ModeSelector(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypewriterText(String text, {required TextStyle style}) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        final chars = text.length * _headerController.value;
        final displayText =
            text.substring(0, chars.floor().clamp(0, text.length));

        return Text(displayText, style: style);
      },
    );
  }

  Widget _buildUserConstellationWithPositioning(DiscoveryState discoveryState) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _modeTransitionController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: _userPositions.isEmpty
                ? const Center(child: CosmicLoadingWidget())
                : _buildPositionedUsers(),
          );
        },
      ),
    );
  }

  Widget _buildPositionedUsers() {
    return Stack(
      children: [
        // Constellation lines connecting users
        CustomPaint(
          painter: ConstellationPainter(
            _userPositions,
            _backgroundController.value,
          ),
          size: Size(
            MediaQuery.sizeOf(context).width * 0.7,
            MediaQuery.sizeOf(context).height * 0.5,
          ),
        ),

        // Positioned user widgets
        ..._userPositions.map((userPosition) {
          return Positioned(
            top: userPosition.position.dy - userPosition.radius,
            left: userPosition.position.dx - userPosition.radius,
            child: StellarUserWidget(
              user: userPosition.user,
              index: userPosition.index,
              onTap: () => _handleUserTap(userPosition.user),
              onLongPress: () => _handleUserLongPress(userPosition.user),
              onSwipe: (direction) =>
                  _handleUserSwipe(userPosition.user, direction),
            )
                .animate(delay: (userPosition.index * 150).ms)
                .fadeIn(duration: 1000.ms)
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),
          );
        }),
      ],
    );
  }

  Widget _buildDebugInfo() {
    if (_userPositions.isEmpty) return const SizedBox.shrink();

    final stats = _positioningSystem.getStats();

    return Positioned(
      top: 50,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users: ${stats.totalUsers}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Utilization: ${(stats.spaceUtilization * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Avg Distance: ${stats.averageDistance.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerModeTransition() {
    _modeTransitionController.forward().then((_) {
      // モード変更時にユーザー位置を再計算（オプション）
      final discoveryState = ref.read(discoveryProvider);
      if (discoveryState.users.isNotEmpty) {
        _regenerateUserPositions(discoveryState.users);
      }
      _modeTransitionController.reverse();
    });

    HapticFeedback.mediumImpact();
  }

  void _handleUserTap(UserModel user) {
    HapticFeedback.lightImpact();
    // Handle user tap
  }

  void _handleUserLongPress(UserModel user) {
    HapticFeedback.heavyImpact();
    _showQuickActionMenu(user);
  }

  void _handleUserSwipe(UserModel user, SwipeDirection direction) {
    HapticFeedback.selectionClick();
    // Handle swipe actions
  }

  void _showQuickActionMenu(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionMenu(user: user),
    );
  }

  Widget _buildDetailPanel(
    BuildContext context,
    WidgetRef ref,
    DetailPanelType panelType,
  ) {
    // 既存のDetailPanel実装
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.95),
                AppColors.backgroundDark.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
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
}

//  constellation painter for connecting lines
class ConstellationPainter extends CustomPainter {
  final List<UserPosition> userPositions;
  final double animationValue;

  ConstellationPainter(this.userPositions, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (userPositions.length < 2) return;

    for (int i = 0; i < userPositions.length; i++) {
      for (int j = i + 1; j < userPositions.length; j++) {
        final userA = userPositions[i];
        final userB = userPositions[j];

        final distance = (userA.position - userB.position).distance;

        // 距離に基づいて線の透明度を調整
        if (distance < 200) {
          final opacity = (1.0 - distance / 200) * 0.15;
          final pulseOpacity =
              (sin(animationValue * 2 * pi + i + j) * 0.5 + 0.5) * opacity;

          final paint = Paint()
            ..color = Colors.white.withOpacity(pulseOpacity)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

          canvas.drawLine(userA.position, userB.position, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.userPositions.length != userPositions.length;
}

// Quick action menu widget
class QuickActionMenu extends StatelessWidget {
  final UserModel user;

  const QuickActionMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundMedium,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(Icons.favorite, '❤️', 'いいね'),
              _buildQuickAction(Icons.chat_bubble, '💬', 'メッセージ'),
              _buildQuickAction(Icons.star, '⭐', 'スーパーいいね'),
              _buildQuickAction(Icons.info, '📋', 'プロフィール'),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 1, end: 0, duration: 400.ms);
  }

  Widget _buildQuickAction(IconData icon, String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.planetGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

enum SwipeDirection { left, right, up, down }
