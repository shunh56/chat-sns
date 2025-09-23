import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../constants/tempo_colors.dart';

class TempoUserAvatar extends HookWidget {
  final String? imageUrl;
  final double size;
  final bool isOnline;
  final String? mood;
  final bool showEditButton;
  final VoidCallback? onTap;

  const TempoUserAvatar({
    super.key,
    this.imageUrl,
    required this.size,
    this.isOnline = false,
    this.mood,
    this.showEditButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    final breathingAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    useEffect(() {
      if (isOnline) {
        animationController.repeat(reverse: true);
      } else {
        animationController.stop();
        animationController.reset();
      }
      return null;
    }, [isOnline]);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Avatar
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: isOnline ? breathingAnimation : 1.0,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // より控えめなオンライン状態の表現
                    gradient: isOnline ? LinearGradient(
                      colors: [
                        TempoColors.primary.withOpacity(0.1),
                        TempoColors.secondary.withOpacity(0.05),
                      ],
                    ) : null,
                    color: isOnline ? null : TempoColors.surface,
                    border: Border.all(
                      color: isOnline 
                          ? TempoColors.primary.withOpacity(0.3)
                          : TempoColors.textTertiary.withOpacity(0.2),
                      width: isOnline ? 2 : 1,
                    ),
                    boxShadow: isOnline ? [
                      BoxShadow(
                        color: TempoColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: imageUrl != null 
                          ? Image.network(
                              imageUrl!,
                              width: size - 6,
                              height: size - 6,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar();
                              },
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                ),
              );
            },
          ),

          // Mood Indicator
          if (mood != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  color: TempoColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TempoColors.background,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    mood!,
                    style: TextStyle(
                      fontSize: size * 0.2,
                    ),
                  ),
                ),
              ),
            ),

          // Online Indicator
          if (isOnline && mood == null)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: TempoColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TempoColors.background,
                    width: 2,
                  ),
                ),
              ),
            ),

          // Edit Button
          if (showEditButton)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  // 編集ボタンも控えめに
                  color: TempoColors.primary.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TempoColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TempoColors.primary.withOpacity(0.1),
            TempoColors.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        color: TempoColors.textSecondary,
        size: size * 0.4,
      ),
    );
  }
}