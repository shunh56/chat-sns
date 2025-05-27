import 'dart:async';

import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CosmicBackground extends StatefulWidget {
  const CosmicBackground({super.key});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _generateStars();
    _startStarMovement();
  }

  void _generateStars() {
    for (int i = 0; i < 60; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        brightness: _random.nextDouble(),
        twinkleSpeed: 2.0 + _random.nextDouble() * 3.0,
        color: _getRandomStarColor(),
        size: _getRandomStarSize(),
      ));
    }
  }

  Color _getRandomStarColor() {
    final colors = [
      Colors.white,
      AppColors.primaryBlue.withOpacity(0.8),
      AppColors.primaryPurple.withOpacity(0.6),
      AppColors.primaryPink.withOpacity(0.5),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  double _getRandomStarSize() {
    final sizes = [2.0, 3.0, 2.5];
    return sizes[_random.nextInt(sizes.length)];
  }

  void _startStarMovement() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          for (var star in _stars) {
            star.x = _random.nextDouble();
            star.y = _random.nextDouble();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(_stars, _starController.value),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }
}

class Star {
  double x;
  double y;
  final double brightness;
  final double twinkleSpeed;
  final Color color;
  final double size;

  Star({
    required this.x,
    required this.y,
    required this.brightness,
    required this.twinkleSpeed,
    required this.color,
    required this.size,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarFieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final twinkle =
          sin(animationValue * 2 * pi * star.twinkleSpeed) * 0.5 + 0.5;
      final opacity = (star.brightness * 0.3 + twinkle * 0.7).clamp(0.3, 1.0);
      final currentSize = star.size * (0.8 + twinkle * 0.4);

      final paint = Paint()
        ..color = star.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final center = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      canvas.drawCircle(center, currentSize, paint);

      // Add glow effect for brighter stars
      if (star.brightness > 0.7) {
        final glowPaint = Paint()
          ..color = star.color.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.drawCircle(center, currentSize * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
