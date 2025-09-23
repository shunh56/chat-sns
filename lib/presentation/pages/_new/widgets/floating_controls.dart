import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/discovery_provider.dart';
import 'dart:math';

class FloatingControls extends ConsumerStatefulWidget {
  const FloatingControls({super.key});

  @override
  ConsumerState<FloatingControls> createState() => _FloatingControlsState();
}

class _FloatingControlsState extends ConsumerState<FloatingControls>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _expandController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _expandController = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _expandController]),
        builder: (context, child) {
          final floatOffset = sin(_floatController.value * 2 * pi) * 5;
          
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expanded controls
                if (_isExpanded) ..._buildExpandedControls(),
                
                // Main FAB
                const SizedBox(height: 12),
                _buildMainFAB(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildExpandedControls() {
    final controls = [
      _ControlData(
        icon: Icons.tune,
        tooltip: 'フィルター設定',
        color: AppColors.primaryBlue,
        onTap: () => _handleControlTap(DetailPanelType.filter),
      ),
      _ControlData(
        icon: Icons.history,
        tooltip: '発見履歴',
        color: AppColors.primaryPurple,
        onTap: () => _handleControlTap(DetailPanelType.history),
      ),
      _ControlData(
        icon: Icons.analytics,
        tooltip: '相性分析',
        color: AppColors.primaryPink,
        onTap: () => _handleControlTap(DetailPanelType.analysis),
      ),
    ];

    return controls.asMap().entries.map((entry) {
      final index = entry.key;
      final control = entry.value;
      final delay = (controls.length - index - 1) * 50;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildEnhancedControlOrb(
          icon: control.icon,
          tooltip: control.tooltip,
          color: control.color,
          onTap: control.onTap,
        ).animate()
          .fadeIn(delay: delay.ms, duration: 200.ms)
          .slideX(begin: 1, end: 0, delay: delay.ms, duration: 300.ms, curve: Curves.easeOutBack)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), delay: delay.ms, duration: 300.ms),
      );
    }).toList();
  }

  Widget _buildMainFAB() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPink,
              AppColors.primaryPurple,
              AppColors.primaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shimmer effect
            _buildFABShimmer(),
            
            // Icon
            Center(
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0,
                duration: AppConstants.fastAnimation,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 3.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        )
        .then()
        .scale(
          duration: 3.seconds,
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
        );
  }

  Widget _buildFABShimmer() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _floatController.value * 2, -1.0 + _floatController.value * 2),
                end: Alignment(1.0 + _floatController.value * 2, 1.0 + _floatController.value * 2),
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
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

  Widget _buildEnhancedControlOrb({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Icon
              Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: 2.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
          )
          .then()
          .scale(
            duration: 2.seconds,
            begin: const Offset(1.03, 1.03),
            end: const Offset(1, 1),
          ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
    
    HapticFeedback.mediumImpact();
  }

  void _handleControlTap(DetailPanelType panelType) {
    HapticFeedback.lightImpact();
    ref.read(discoveryProvider.notifier).toggleDetailPanel(panelType);
    
    // Auto-collapse after selection
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _toggleExpanded();
      }
    });
  }
}

class _ControlData {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  _ControlData({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });
}