import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VibeData {
  final String icon;
  final String text;
  final List<Color> colors;

  VibeData(this.icon, this.text, this.colors);
}

class ParticleData {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  ParticleData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class VibeIndicator extends HookConsumerWidget {
  final String mood;
  final Color? color; // 外部から色を指定可能に
  final bool isAnimated;

  const VibeIndicator({
    super.key,
    required this.mood,
    this.color,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final particleController = useAnimationController(
      duration: const Duration(seconds: 3),
    );

    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final particles = useMemoized(() {
      return List.generate(10, (index) {
        return ParticleData(
          x: Random().nextDouble(),
          y: Random().nextDouble(),
          size: Random().nextDouble() * 3 + 1,
          speed: Random().nextDouble() * 0.03 + 0.01,
          opacity: Random().nextDouble() * 0.5 + 0.2,
        );
      });
    }, []);

    useEffect(() {
      if (isAnimated) {
        particleController.repeat();
        pulseController.repeat(reverse: true);
      }
      return null;
    }, [isAnimated]);

    final vibeData = _getVibeData(mood);

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: vibeData.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: vibeData.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isAnimated)
            CustomPaint(
              painter: ParticlePainter(
                animation: particleController,
                particles: particles,
                color: Colors.white.withOpacity(0.6),
              ),
              size: const Size(double.infinity, 24),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (pulseController.value * 0.1),
                    child: Text(
                      vibeData.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                vibeData.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  VibeData _getVibeData(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return VibeData(
          '😊',
          'Happy',
          [Colors.yellow.shade400, Colors.orange.shade400],
        );
      case 'creative':
        return VibeData(
          '✨',
          'Creative',
          [Colors.purple.shade400, Colors.pink.shade400],
        );
      case 'energetic':
        return VibeData(
          '🔥',
          'Energetic',
          [Colors.orange.shade400, Colors.red.shade400],
        );
      case 'chill':
        return VibeData(
          '🌙',
          'Chill',
          [Colors.blue.shade400, Colors.indigo.shade400],
        );
      default:
        return VibeData(
          '💫',
          'Inspired',
          [Colors.green.shade400, Colors.teal.shade400],
        );
    }
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<ParticleData> particles;
  final Color color;

  ParticlePainter({
    required this.animation,
    required this.particles,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.y = (particle.y - particle.speed * animation.value) % 1.0;

      final x = particle.x * size.width;
      final y = particle.y * size.height;

      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
