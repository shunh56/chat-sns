import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/discovery_mode.dart';
import '../providers/discovery_provider.dart';
import 'dart:math';

class ModeSelector extends ConsumerStatefulWidget {
  const ModeSelector({super.key});

  @override
  ConsumerState<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends ConsumerState<ModeSelector>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late AnimationController _transitionController;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _transitionController = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundDark.withOpacity(0.8),
            AppColors.backgroundMedium.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background glow
              _buildBackgroundGlow(),

              // Mode buttons
              Row(
                children: DiscoveryMode.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mode = entry.value;
                  final isActive = discoveryState.selectedMode == mode;

                  return Expanded(
                    child: _buildModeButton(mode, isActive, index),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    final glowOpacity = sin(_glowController.value * 2 * pi) * 0.3 + 0.7;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(glowOpacity * 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(DiscoveryMode mode, bool isActive, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: GestureDetector(
        onTap: () => _handleModeChange(mode),
        child: AnimatedContainer(
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPink.withOpacity(0.8),
                      AppColors.primaryPurple.withOpacity(0.6),
                      AppColors.primaryBlue.withOpacity(0.4),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(25),
            border: isActive
                ? Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Shimmer effect for active button
              if (isActive) _buildShimmerEffect(),

              // Button content
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getModeIcon(mode),
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mode.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontSize: 9,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate(target: isActive ? 1 : 0).scale(
              end: const Offset(1.05, 1.05),
              duration: 200.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _glowController.value * 2, 0),
                end: Alignment(1.0 + _glowController.value * 2, 0),
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getModeIcon(DiscoveryMode mode) {
    switch (mode) {
      case DiscoveryMode.compatibility:
        return Icons.favorite;
      case DiscoveryMode.interests:
        return Icons.interests;
      case DiscoveryMode.activity:
        return Icons.online_prediction;
      case DiscoveryMode.nearby:
        return Icons.location_on;
    }
  }

  void _handleModeChange(DiscoveryMode mode) {
    HapticFeedback.mediumImpact();

    // Trigger transition animation
    _transitionController.forward().then((_) {
      _transitionController.reverse();
    });

    ref.read(discoveryProvider.notifier).changeMode(mode);

    // Visual feedback
    _showModeChangeEffect(mode);
  }

  void _showModeChangeEffect(DiscoveryMode mode) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPink.withOpacity(0.9),
                    AppColors.primaryPurple.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getModeIcon(mode),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mode.displayName}モードに切り替えました',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.3, end: 0, duration: 400.ms)
          .then(delay: 1500.ms)
          .fadeOut(duration: 300.ms)
          .slideY(begin: 0, end: -0.3, duration: 300.ms),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2200), () {
      overlayEntry.remove();
    });
  }
}
