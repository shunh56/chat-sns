import 'dart:math' as math;
import 'package:app/domain/entity/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StellarUserWidget extends HookWidget {
  final UserAccount user;
  final VoidCallback? onTap;
  final double orbitRadius;
  final double angle;
  final bool isActive;

  const StellarUserWidget({
    super.key,
    required this.user,
    this.onTap,
    required this.orbitRadius,
    required this.angle,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 3),
    );

    final pulseAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    final glowAnimation = useAnimation(
      Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    useEffect(() {
      if (isActive) {
        animationController.repeat(reverse: true);
      } else {
        animationController.stop();
        animationController.reset();
      }
      return null;
    }, [isActive]);

    // Calculate position based on angle and radius
    final x = math.cos(angle) * orbitRadius;
    final y = math.sin(angle) * orbitRadius;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.scale(
          scale: isActive ? pulseAnimation : 1.0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: Colors.blue.withOpacity(glowAnimation * 0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // User avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? Colors.blue.withOpacity(glowAnimation)
                          : Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.imageUrl!,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                ),

                // Online indicator
                if (user.isOnline)
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                // Name label below avatar
                Positioned(
                  bottom: -25,
                  left: -20,
                  right: -20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension method for the stellar discovery screen
extension StellarDiscoveryExtension on Widget {
  Widget buildStellarUserWidget({
    required UserAccount user,
    VoidCallback? onTap,
    required double orbitRadius,
    required double angle,
    bool isActive = false,
  }) {
    return StellarUserWidget(
      user: user,
      onTap: onTap,
      orbitRadius: orbitRadius,
      angle: angle,
      isActive: isActive,
    );
  }
}

// Particle effects for cosmic ambiance
class StarParticle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const StarParticle({
    super.key,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.5),
            blurRadius: size * 2,
          ),
        ],
      ),
    );
  }
}

// Orbit ring visualization
class OrbitRing extends StatelessWidget {
  final double radius;
  final Color color;
  final double strokeWidth;

  const OrbitRing({
    super.key,
    required this.radius,
    required this.color,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: strokeWidth,
        ),
      ),
    );
  }
}

// Gravitational effect widget
class GravitationalField extends StatelessWidget {
  final double intensity;
  final Color color;

  const GravitationalField({
    super.key,
    required this.intensity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(intensity * 0.1),
            color.withOpacity(intensity * 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
    );
  }
}
