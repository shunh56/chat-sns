import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math' as math;
import '../constants/tempo_colors.dart';
import '../constants/tempo_text_styles.dart';

class TempoTimeIndicator extends HookWidget {
  final Duration remaining;
  final Duration total;
  final double size;

  const TempoTimeIndicator({
    super.key,
    required this.remaining,
    required this.total,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remaining.inSeconds / total.inSeconds;
    final isWarning = remaining.inHours < 1;
    
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final pulseAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    useEffect(() {
      if (isWarning) {
        animationController.repeat(reverse: true);
      } else {
        animationController.stop();
        animationController.reset();
      }
      return null;
    }, [isWarning]);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isWarning ? pulseAnimation : 1.0,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Background Circle - より控えめに
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TempoColors.surface.withOpacity(0.5),
                    border: Border.all(
                      color: TempoColors.textTertiary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                
                // Progress Circle
                CustomPaint(
                  size: Size(size, size),
                  painter: _CircularProgressPainter(
                    progress: progress,
                    color: isWarning ? TempoColors.warning : TempoColors.primary.withOpacity(0.6),
                    strokeWidth: 2.0, // より細く
                  ),
                ),
                
                // Center Text
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${remaining.inHours}',
                        style: TempoTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isWarning 
                              ? TempoColors.warning 
                              : TempoColors.textPrimary, // より読みやすい色に
                          fontSize: size * 0.22, // 少し大きく
                        ),
                      ),
                      Text(
                        'h',
                        style: TempoTextStyles.overline.copyWith(
                          fontSize: size * 0.14,
                          color: TempoColors.textSecondary, // より読みやすい色に
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CircularProgressPainter &&
        (oldDelegate.progress != progress ||
         oldDelegate.color != color ||
         oldDelegate.strokeWidth != strokeWidth);
  }
}