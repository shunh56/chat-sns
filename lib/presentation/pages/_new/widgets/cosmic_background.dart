import 'dart:async';
import 'dart:math';
import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';

class CosmicBackground extends StatefulWidget {
  final AnimationController controller;

  const CosmicBackground({super.key, required this.controller});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> {
  final List<EnhancedStar> _stars = [];
  final List<Nebula> _nebulae = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateStars();
    _generateNebulae();
    _startPeriodicEffects();
  }

  void _generateStars() {
    for (int i = 0; i < 80; i++) {
      _stars.add(EnhancedStar(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        brightness: _random.nextDouble(),
        twinkleSpeed: 1.0 + _random.nextDouble() * 4.0,
        color: _getRandomStarColor(),
        size: _getRandomStarSize(),
        pulsePhase: _random.nextDouble() * 2 * pi,
        shootingStar: _random.nextDouble() < 0.1,
      ));
    }
  }

  void _generateNebulae() {
    for (int i = 0; i < 5; i++) {
      _nebulae.add(Nebula(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 100 + _random.nextDouble() * 200,
        color: AppColors
            .cosmicGradient[_random.nextInt(AppColors.cosmicGradient.length)],
        drift: _random.nextDouble() * 0.5,
      ));
    }
  }

  Color _getRandomStarColor() {
    final colors = [
      Colors.white,
      AppColors.primaryBlue.withOpacity(0.9),
      AppColors.primaryPurple.withOpacity(0.7),
      AppColors.primaryPink.withOpacity(0.6),
      AppColors.primaryYellow.withOpacity(0.5),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  double _getRandomStarSize() {
    final weights = [0.7, 0.2, 0.08, 0.02];
    final sizes = [2.0, 3.5, 5.0, 7.0];

    final random = _random.nextDouble();
    double cumulative = 0;

    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (random <= cumulative) {
        return sizes[i];
      }
    }
    return sizes[0];
  }

  void _startPeriodicEffects() {
    Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        setState(() {
          // Occasionally add shooting stars
          if (_random.nextDouble() < 0.3) {
            final shootingStarIndex = _random.nextInt(_stars.length);
            _stars[shootingStarIndex].shootingStar = true;

            Timer(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _stars[shootingStarIndex].shootingStar = false;
                });
              }
            });
          }

          // Slowly drift nebulae
          for (var nebula in _nebulae) {
            nebula.x = (nebula.x + nebula.drift * 0.01) % 1.0;
            nebula.y = (nebula.y + nebula.drift * 0.005) % 1.0;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: EnhancedStarFieldPainter(
              _stars, _nebulae, widget.controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class EnhancedStar {
  double x;
  double y;
  final double brightness;
  final double twinkleSpeed;
  final Color color;
  final double size;
  final double pulsePhase;
  bool shootingStar;

  EnhancedStar({
    required this.x,
    required this.y,
    required this.brightness,
    required this.twinkleSpeed,
    required this.color,
    required this.size,
    required this.pulsePhase,
    this.shootingStar = false,
  });
}

class Nebula {
  double x;
  double y;
  final double size;
  final Color color;
  final double drift;

  Nebula({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.drift,
  });
}

class EnhancedStarFieldPainter extends CustomPainter {
  final List<EnhancedStar> stars;
  final List<Nebula> nebulae;
  final double animationValue;

  EnhancedStarFieldPainter(this.stars, this.nebulae, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw nebulae first
    for (var nebula in nebulae) {
      _drawNebula(canvas, size, nebula);
    }

    // Draw stars
    for (var star in stars) {
      if (star.shootingStar) {
        _drawShootingStar(canvas, size, star);
      } else {
        _drawStar(canvas, size, star);
      }
    }
  }

  void _drawNebula(Canvas canvas, Size size, Nebula nebula) {
    final center = Offset(nebula.x * size.width, nebula.y * size.height);
    final opacity = (sin(animationValue * pi + nebula.drift) * 0.3 + 0.7) * 0.1;

    final paint = Paint()
      ..color = nebula.color.withOpacity(opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, nebula.size * 0.3);

    canvas.drawCircle(center, nebula.size, paint);
  }

  void _drawStar(Canvas canvas, Size size, EnhancedStar star) {
    final twinkle =
        sin(animationValue * 2 * pi * star.twinkleSpeed + star.pulsePhase) *
                0.5 +
            0.5;
    final pulse =
        sin(animationValue * pi * star.twinkleSpeed * 0.5 + star.pulsePhase) *
                0.2 +
            0.8;
    final opacity = (star.brightness * 0.4 + twinkle * 0.6).clamp(0.2, 1.0);
    final currentSize = star.size * (0.7 + twinkle * 0.6) * pulse;

    final paint = Paint()
      ..color = star.color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(star.x * size.width, star.y * size.height);

    // Main star
    canvas.drawCircle(center, currentSize, paint);

    // Cross pattern for larger stars
    if (star.size > 4.0) {
      final crossPaint = Paint()
        ..color = star.color.withOpacity(opacity * 0.8)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final crossSize = currentSize * 2;
      canvas.drawLine(
        Offset(center.dx - crossSize, center.dy),
        Offset(center.dx + crossSize, center.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - crossSize),
        Offset(center.dx, center.dy + crossSize),
        crossPaint,
      );
    }

    // Glow effect for bright stars
    if (star.brightness > 0.7) {
      final glowPaint = Paint()
        ..color = star.color.withOpacity(opacity * 0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(center, currentSize * 2.5, glowPaint);
    }
  }

  void _drawShootingStar(Canvas canvas, Size size, EnhancedStar star) {
    final progress = (animationValue * 3) % 1.0;
    final startX = star.x * size.width;
    final startY = star.y * size.height;
    final endX = startX + 100;
    final endY = startY + 50;

    final currentX = startX + (endX - startX) * progress;
    final currentY = startY + (endY - startY) * progress;

    final opacity = (1.0 - progress) * 0.8;

    // Trail
    final trailPaint = Paint()
      ..color = star.color.withOpacity(opacity * 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(currentX, currentY),
      Offset(currentX - 30 * progress, currentY - 15 * progress),
      trailPaint,
    );

    // Main shooting star
    final paint = Paint()
      ..color = star.color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(currentX, currentY), star.size * 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant EnhancedStarFieldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
