import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CosmicBackground extends HookWidget {
  const CosmicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 60),
    );

    useEffect(() {
      animationController.repeat();
      return null;
    }, []);

    return Stack(
      children: [
        // グラデーション背景
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF1a0033),
                Color(0xFF0a0011),
                Colors.black,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        
        // 星々のパーティクル
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: StarFieldPainter(
                animation: animationController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // 星雲エフェクト
        ...List.generate(3, (index) {
          return Positioned(
            left: index * 200.0 - 100,
            top: index * 150.0,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: animationController.value * 2 * math.pi * (index + 1) * 0.1,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        
        // オーロラエフェクト
        Positioned.fill(
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: AuroraPainter(
                  animation: animationController.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final double animation;
  final List<Star> stars = List.generate(200, (index) => Star());

  StarFieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final opacity = (math.sin(animation * 2 * math.pi * star.twinkleSpeed) + 1) / 2;
      paint.color = Colors.white.withOpacity(opacity * star.brightness);
      
      canvas.drawCircle(
        Offset(
          star.x * size.width,
          star.y * size.height,
        ),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}

class Star {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = math.Random().nextDouble() * 2 + 0.5;
  final double brightness = math.Random().nextDouble() * 0.8 + 0.2;
  final double twinkleSpeed = math.Random().nextDouble() * 2 + 0.5;
}

class AuroraPainter extends CustomPainter {
  final double animation;

  AuroraPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.greenAccent.withOpacity(0.1),
          Colors.blueAccent.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

    for (int i = 0; i < 5; i++) {
      final offset = i * 100.0;
      final waveHeight = math.sin(animation * 2 * math.pi + i) * 20;
      
      path.moveTo(0, offset);
      for (double x = 0; x <= size.width; x += 10) {
        final y = offset + math.sin(x / 50 + animation * 2 * math.pi) * waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, offset);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) => true;
}