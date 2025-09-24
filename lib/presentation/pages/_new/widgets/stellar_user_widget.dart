import 'package:app/presentation/pages/_new/discovery_screen.dart';
import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_model.dart';
import 'dart:math';

class StellarUserWidget extends StatefulWidget {
  final UserModel user;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(SwipeDirection) onSwipe;

  const StellarUserWidget({
    super.key,
    required this.user,
    required this.index,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipe,
  });

  @override
  State<StellarUserWidget> createState() => _StellarUserWidgetState();
}

class _StellarUserWidgetState extends State<StellarUserWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _pulseController;

  bool _isHovered = false;
  bool _isPressed = false;
  Offset _panStart = Offset.zero;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: _getFloatDuration(),
      vsync: this,
    )..repeat(reverse: true);

    _hoverController = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  Duration _getFloatDuration() {
    switch (widget.user.type) {
      case UserType.primary:
        return const Duration(seconds: 6);
      case UserType.secondary:
        return const Duration(seconds: 9);
      case UserType.tertiary:
        return const Duration(seconds: 7);
    }
  }

  double _getPlanetSize() {
    switch (widget.user.type) {
      case UserType.primary:
        return AppConstants.primaryPlanetSize;
      case UserType.secondary:
        return AppConstants.secondaryPlanetSize;
      case UserType.tertiary:
        return AppConstants.tertiaryPlanetSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _getPlanetSize();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _hoverController,
        _tapController,
        _pulseController
      ]),
      builder: (context, child) {
        final floatOffset = _getEnhancedFloatOffset();
        final hoverScale = 1.0 + (_hoverController.value * 0.2);
        final pressScale = _isPressed ? 0.95 : 1.0;
        final tapRotation = _tapController.value * 4 * pi;
        final pulseScale = 1.0 + (sin(_pulseController.value * 2 * pi) * 0.05);

        return Transform.translate(
          offset: floatOffset,
          child: Transform.scale(
            scale: hoverScale * pressScale * pulseScale,
            child: Transform.rotate(
              angle: tapRotation,
              child: GestureDetector(
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                onTap: _handleTap,
                onLongPress: _handleLongPress,
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                child: MouseRegion(
                  onEnter: (_) => _onHover(true),
                  onExit: (_) => _onHover(false),
                  child: SizedBox(
                    width: size * 1.8,
                    height: size * 1.8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildEnhancedPlanetCore(size),
                        _buildEnhancedUserAvatar(size),
                        if (_isHovered || _isPressed)
                          _buildEnhancedCompatibilityIndicator(size),
                        //if (widget.user.isOnline) _buildOnlineIndicator(size),
                        _buildInteractionRipples(size),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _getEnhancedFloatOffset() {
    final t = _floatController.value;
    final hoverOffset = _isHovered ? 3.0 : 0.0;

    switch (widget.user.type) {
      case UserType.primary:
        return Offset(
          sin(t * 2 * pi + widget.index) * (4 + hoverOffset),
          cos(t * 2 * pi) * (10 + hoverOffset) + sin(t * 6 * pi) * 2,
        );
      case UserType.secondary:
        final angle = t * 2 * pi + (widget.index * pi / 3);
        return Offset(
          sin(angle) * (7 + hoverOffset) + cos(t * 4 * pi) * 2,
          cos(angle) * (15 + hoverOffset) + sin(t * 5 * pi) * 3,
        );
      case UserType.tertiary:
        return Offset(
          sin(t * 3 * pi + widget.index) * (5 + hoverOffset),
          cos(t * 2.5 * pi + widget.index) * (8 + hoverOffset),
        );
    }
  }

  Widget _buildEnhancedPlanetCore(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEnhancedPlanetGradient(),
        border: Border.all(
          color: Colors.white.withOpacity(_isHovered ? 0.6 : 0.3),
          width: _isHovered ? 3 : 2,
        ),
        boxShadow: [
          // Primary glow
          BoxShadow(
            color: widget.user.isOnline
                ? Colors.green.withOpacity(0.6)
                : _getPrimaryColor().withOpacity(0.4),
            blurRadius: _isHovered ? 30 : 20,
            spreadRadius: _isHovered ? 4 : 2,
          ),
          // Secondary glow for depth
          BoxShadow(
            color: _getSecondaryColor().withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 1,
          ),
          // Inner shadow for dimension
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: -2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Gradient _getEnhancedPlanetGradient() {
    switch (widget.user.type) {
      case UserType.primary:
        return RadialGradient(
          colors: [
            AppColors.primaryPink.withOpacity(0.9),
            AppColors.primaryPurple.withOpacity(0.8),
            AppColors.primaryBlue.withOpacity(0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        );
      case UserType.secondary:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.9),
            AppColors.primaryPurple.withOpacity(0.8),
            AppColors.primaryPink.withOpacity(0.6),
          ],
        );
      case UserType.tertiary:
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryPurple.withOpacity(0.9),
            AppColors.primaryPink.withOpacity(0.8),
            AppColors.primaryOrange.withOpacity(0.7),
          ],
        );
    }
  }

  Color _getPrimaryColor() {
    switch (widget.user.type) {
      case UserType.primary:
        return AppColors.primaryPink;
      case UserType.secondary:
        return AppColors.primaryBlue;
      case UserType.tertiary:
        return AppColors.primaryPurple;
    }
  }

  Color _getSecondaryColor() {
    switch (widget.user.type) {
      case UserType.primary:
        return AppColors.primaryPurple;
      case UserType.secondary:
        return AppColors.primaryPink;
      case UserType.tertiary:
        return AppColors.primaryOrange;
    }
  }

  Widget _buildEnhancedUserAvatar(double size) {
    final avatarSize = size * 0.85;
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(_isHovered ? 0.8 : 0.5),
          width: _isHovered ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          widget.user.avatarUrl,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: _getEnhancedPlanetGradient(),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.8),
                size: avatarSize * 0.5,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedCompatibilityIndicator(double size) {
    return Positioned(
      bottom: size * 0.05,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.9),
                AppColors.backgroundDark.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _getPrimaryColor().withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPrimaryColor().withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppColors.primaryPink,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.user.compatibility}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
        begin: 0.5, end: 0, duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildOnlineIndicator(double size) {
    return Positioned(
      top: size * 0.1,
      right: size * 0.1,
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
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: 1.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
          )
          .then()
          .scale(
            duration: 1.seconds,
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
          ),
    );
  }

  Widget _buildInteractionRipples(double size) {
    if (!_isPressed && !_isHovered) return const SizedBox.shrink();

    return Positioned.fill(
      child: CustomPaint(
        painter: RipplePainter(
          _hoverController.value,
          _getPrimaryColor(),
          _isPressed,
        ),
      ),
    );
  }

  void _setPressed(bool pressed) {
    setState(() {
      _isPressed = pressed;
    });

    if (pressed) {
      HapticFeedback.lightImpact();
    }
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reset();
    });

    HapticFeedback.mediumImpact();
    _showSuccessEffect();
    widget.onTap();
  }

  void _handleLongPress() {
    HapticFeedback.heavyImpact();
    widget.onLongPress();
  }

  void _handlePanStart(DragStartDetails details) {
    _panStart = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Visual feedback during drag
  }

  void _handlePanEnd(DragEndDetails details) {
    final delta = details.localPosition - _panStart;
    final distance = delta.distance;

    if (distance > 50) {
      SwipeDirection direction;
      if (delta.dx.abs() > delta.dy.abs()) {
        direction = delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      } else {
        direction = delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      }

      widget.onSwipe(direction);
    }
  }

  void _showSuccessEffect() {
    // Create floating success indicator
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5 - 50,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPink.withOpacity(0.9),
                    AppColors.primaryPurple.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.user.name}と接続しました！',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(
              begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack)
          .then(delay: 2000.ms)
          .fadeOut(duration: 500.ms)
          .slideY(begin: 0, end: -0.5, duration: 500.ms),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 3000), () {
      overlayEntry.remove();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _hoverController.dispose();
    _tapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isPressed;

  RipplePainter(this.progress, this.color, this.isPressed);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * progress;

    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);

    if (isPressed) {
      final innerPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius * 0.8, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isPressed != isPressed;
}
