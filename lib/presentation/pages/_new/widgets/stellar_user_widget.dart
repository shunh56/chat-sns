import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_model.dart';
import 'user_detail_popup.dart';
import 'dart:math';

class StellarUserWidget extends StatefulWidget {
  final UserModel user;
  final int index;

  const StellarUserWidget({
    super.key,
    required this.user,
    required this.index,
  });

  @override
  State<StellarUserWidget> createState() => _StellarUserWidgetState();
}

class _StellarUserWidgetState extends State<StellarUserWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _hoverController;
  late AnimationController _clickController;
  bool _isHovered = true;

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

    _clickController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  Duration _getFloatDuration() {
    switch (widget.user.type) {
      case UserType.primary:
        return const Duration(seconds: 8);
      case UserType.secondary:
        return const Duration(seconds: 12);
      case UserType.tertiary:
        return const Duration(seconds: 10);
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
      animation: Listenable.merge(
          [_floatController, _hoverController, _clickController]),
      builder: (context, child) {
        final floatOffset = _getFloatOffset();
        final hoverScale = 1.0 + (_hoverController.value * 0.15);
        final clickRotation = _clickController.value * 2 * pi;

        return Transform.translate(
          offset: floatOffset,
          child: Transform.scale(
            scale: hoverScale,
            child: Transform.rotate(
              angle: clickRotation,
              child: MouseRegion(
                onEnter: (_) => _onHover(true),
                onExit: (_) => _onHover(false),
                child: GestureDetector(
                  onTap: _onTap,
                  child: SizedBox(
                    width: size * 1.5,
                    height: size * 1.5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildPlanetCore(size),
                        _buildUserAvatar(size),
                        if (_isHovered) _buildCompatibilityIndicator(size),
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

  Offset _getFloatOffset() {
    final t = _floatController.value;

    switch (widget.user.type) {
      case UserType.primary:
        return Offset(
          sin(t * 2 * pi) * 3,
          cos(t * 2 * pi) * 8,
        );
      case UserType.secondary:
        final angle = t * 2 * pi + (widget.index * pi / 2);
        return Offset(
          sin(angle) * 6,
          cos(angle) * 12 + sin(t * 4 * pi) * 4,
        );
      case UserType.tertiary:
        return Offset(
          sin(t * 2 * pi + widget.index) * 4,
          cos(t * 3 * pi) * 6,
        );
    }
  }

  Widget _buildPlanetCore(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getPlanetGradient(),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.user.isOnline
                ? Colors.green
                : AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }

  Gradient _getPlanetGradient() {
    switch (widget.user.type) {
      case UserType.primary:
        return AppColors.planetGradient;
      case UserType.secondary:
        return const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserType.tertiary:
        return const LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildUserAvatar(double size) {
    final avatarSize = size;
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image.network(
          widget.user.avatarUrl,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryPurple.withOpacity(0.3),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompatibilityIndicator(double size) {
    return Positioned(
      bottom: size * 0.1,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${widget.user.compatibility}% 相性',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.3, end: 0, duration: 200.ms);
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

  void _onTap() {
    _clickController.forward().then((_) {
      _clickController.reset();
      _showEngagementSuccess();
    });
  }

  void _showEngagementSuccess() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                '✨ 接続成功!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.3, end: 0, duration: 300.ms)
          .then(delay: 2000.ms)
          .fadeOut(duration: 500.ms)
          .slideY(begin: 0, end: -0.3, duration: 500.ms),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _hoverController.dispose();
    _clickController.dispose();
    super.dispose();
  }
}
