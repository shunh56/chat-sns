import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FloatingControls extends HookWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onReset;
  final VoidCallback? onFilter;
  final bool isVisible;

  const FloatingControls({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.onReset,
    this.onFilter,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: fadeController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    final slideAnimation = useAnimation(
      Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: slideController,
          curve: Curves.elasticOut,
        ),
      ),
    );

    useEffect(() {
      if (isVisible) {
        fadeController.forward();
        slideController.forward();
      } else {
        fadeController.reverse();
        slideController.reverse();
      }
      return null;
    }, [isVisible]);

    return Positioned(
      right: 20,
      top: 100,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: fadeController, curve: Curves.easeInOut)),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: slideController, curve: Curves.elasticOut)),
          child: Column(
            children: [
              // Zoom In Button
              _FloatingControlButton(
                icon: Icons.zoom_in,
                onTap: onZoomIn,
                tooltip: 'Zoom In',
              ),
              
              const SizedBox(height: 12),
              
              // Zoom Out Button
              _FloatingControlButton(
                icon: Icons.zoom_out,
                onTap: onZoomOut,
                tooltip: 'Zoom Out',
              ),
              
              const SizedBox(height: 12),
              
              // Reset View Button
              _FloatingControlButton(
                icon: Icons.center_focus_strong,
                onTap: onReset,
                tooltip: 'Reset View',
              ),
              
              const SizedBox(height: 12),
              
              // Filter Button
              _FloatingControlButton(
                icon: Icons.tune,
                onTap: onFilter,
                tooltip: 'Filter Users',
              ),
              
              const SizedBox(height: 20),
              
              // Mini Compass
              _CosmicCompass(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingControlButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const _FloatingControlButton({
    required this.icon,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final hoverController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: hoverController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => hoverController.forward(),
      onTapUp: (_) => hoverController.reverse(),
      onTapCancel: () => hoverController.reverse(),
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Transform.scale(
          scale: scaleAnimation,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _CosmicCompass extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final rotationController = useAnimationController(
      duration: const Duration(seconds: 10),
    );

    final rotationAnimation = useAnimation(
      Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(
          parent: rotationController,
          curve: Curves.linear,
        ),
      ),
    );

    useEffect(() {
      rotationController.repeat();
      return rotationController.dispose;
    }, []);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.blue.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Transform.rotate(
        angle: rotationAnimation,
        child: CustomPaint(
          painter: _CompassPainter(),
          size: const Size(50, 50),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Draw outer ring
    final ringPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius, ringPaint);

    // Draw cardinal points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // North point
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius + 3),
      2,
      pointPaint,
    );

    // Draw constellation lines
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw connecting lines between points
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final x1 = center.dx + math.cos(angle) * (radius - 8);
      final y1 = center.dy + math.sin(angle) * (radius - 8);
      final x2 = center.dx + math.cos(angle) * (radius - 15);
      final y2 = center.dy + math.sin(angle) * (radius - 15);
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }

    // Draw center star
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 3, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Speed Control Widget
class SpeedControl extends HookWidget {
  final double speed;
  final ValueChanged<double>? onSpeedChanged;

  const SpeedControl({
    super.key,
    required this.speed,
    this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.blue.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Universe Speed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 8),
          
          SliderTheme(
            data: SliderThemeData(
              thumbColor: Colors.blue,
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.blue.withOpacity(0.3),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: speed,
              min: 0.1,
              max: 3.0,
              divisions: 29,
              onChanged: onSpeedChanged,
            ),
          ),
          
          Text(
            '${speed.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}