import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class StatBubble extends StatefulWidget {
  final String value;
  final String label;
  final String tooltip;
  final Duration delay;
  final IconData icon;

  const StatBubble({
    super.key,
    required this.value,
    required this.label,
    required this.tooltip,
    required this.delay,
    required this.icon,
  });

  @override
  State<StatBubble> createState() => _StatBubbleState();
}

class _StatBubbleState extends State<StatBubble>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundMedium,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _hoverController,
              _pulseController,
              _sparkleController,
            ]),
            builder: (context, child) {
              final hoverScale = 1.0 + (_hoverController.value * 0.1);
              final pulseGlow = sin(_pulseController.value * 2 * pi) * 0.5 + 0.5;
              
              return Transform.scale(
                scale: hoverScale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.glassBackground,
                        AppColors.glassBackground.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _isHovered
                          ? AppColors.primaryBlue.withOpacity(0.6)
                          : AppColors.glassBorder,
                      width: _isHovered ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(pulseGlow * 0.3),
                        blurRadius: _isHovered ? 20 : 10,
                        spreadRadius: _isHovered ? 2 : 1,
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
                      // Sparkle effects
                      if (_isHovered) _buildSparkleEffects(),
                      
                      // Main content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.icon,
                                color: AppColors.primaryBlue,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.primaryPurple,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  widget.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ).animate(delay: widget.delay)
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSparkleEffects() {
    return Positioned.fill(
      child: CustomPaint(
        painter: SparklePainter(_sparkleController.value),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
      HapticFeedback.selectionClick();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    // Could trigger detailed stats view
  }
}

class SparklePainter extends CustomPainter {
  final double progress;

  SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.7),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkleProgress = (progress + i * 0.25) % 1.0;
      final opacity = (sin(sparkleProgress * 2 * pi) * 0.5 + 0.5) * 0.8;
      final size = 2 + sparkleProgress * 3;

      final paint = Paint()
        ..color = AppColors.primaryBlue.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkles[i], size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}