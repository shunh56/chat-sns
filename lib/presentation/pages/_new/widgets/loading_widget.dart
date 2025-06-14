import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class CosmicLoadingWidget extends StatefulWidget {
  const CosmicLoadingWidget({super.key});

  @override
  State<CosmicLoadingWidget> createState() => _CosmicLoadingWidgetState();
}

class _CosmicLoadingWidgetState extends State<CosmicLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
              _orbitController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: CosmicLoadingPainter(
                  _rotationController.value,
                  _pulseController.value,
                  _orbitController.value,
                ),
                size: const Size(120, 120),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.titleGradient.createShader(bounds),
          child: const Text(
            '宇宙を探索中...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3)),

        const SizedBox(height: 10),

        // Loading dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  delay: (index * 200).ms,
                  duration: 600.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                )
                .then()
                .scale(
                  duration: 600.ms,
                  begin: const Offset(1.5, 1.5),
                  end: const Offset(1, 1),
                );
          }),
        ),
      ],
    );
  }
}

class CosmicLoadingPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double orbit;

  CosmicLoadingPainter(this.rotation, this.pulse, this.orbit);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw central star
    _drawCentralStar(canvas, center, pulse);

    // Draw orbiting planets
    _drawOrbitingPlanets(canvas, center, radius, orbit, rotation);

    // Draw outer ring
    _drawOuterRing(canvas, center, radius, rotation);
  }

  void _drawCentralStar(Canvas canvas, Offset center, double pulse) {
    final starSize = 12 + pulse * 8;

    final starPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primaryYellow, AppColors.primaryOrange],
      ).createShader(Rect.fromCircle(center: center, radius: starSize))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, starSize, starPaint);

    // Star glow
    final glowPaint = Paint()
      ..color = AppColors.primaryYellow.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, starSize * 2, glowPaint);
  }

  void _drawOrbitingPlanets(Canvas canvas, Offset center, double radius,
      double orbit, double rotation) {
    final planetColors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryPurple,
    ];

    for (int i = 0; i < 3; i++) {
      final angle = (orbit + i / 3) * 2 * pi;
      final planetRadius = radius * (0.6 + i * 0.15);
      final planetX = center.dx + cos(angle) * planetRadius;
      final planetY = center.dy + sin(angle) * planetRadius;

      final planetSize = 6 + i * 2;

      final planetPaint = Paint()
        ..color = planetColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          Offset(planetX, planetY), planetSize.toDouble(), planetPaint);

      // Planet trail
      final trailPaint = Paint()
        ..color = planetColors[i].withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawCircle(center, planetRadius, trailPaint);
    }
  }

  void _drawOuterRing(
      Canvas canvas, Offset center, double radius, double rotation) {
    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppColors.primaryPink.withOpacity(0.8),
          Colors.transparent,
          AppColors.primaryBlue.withOpacity(0.8),
          Colors.transparent,
        ],
        transform: GradientRotation(rotation * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CosmicLoadingPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.pulse != pulse ||
      oldDelegate.orbit != orbit;
}

enum SwipeDirection { left, right, up, down }
