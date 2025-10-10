import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserIconPostIcon extends ConsumerWidget {
  const UserIconPostIcon({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double imageHeight = 40;
    double radius = imageHeight * 2 / 9;
    return GestureDetector(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: ThemeColor.accent,
            height: imageHeight,
            width: imageHeight,
            child: user.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    fadeInDuration: const Duration(milliseconds: 120),
                    imageBuilder: (context, imageProvider) => Container(
                      height: imageHeight,
                      width: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  )
                : Icon(
                    Icons.person_outline,
                    size: imageHeight * 0.8,
                    color: ThemeColor.stroke,
                  ),
          ),
        ),
      ),
    );
  }
}

// currentStatus stories nowWithUsers
class UserIconSmallIcon extends ConsumerWidget {
  const UserIconSmallIcon({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double imageHeight = 32;
    double radius = imageHeight * 2 / 9;
    return GestureDetector(
      onTap: () {
        ref.read(navigationRouterProvider(context)).goToProfile(user);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColor.background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: ThemeColor.accent,
            height: imageHeight,
            width: imageHeight,
            child: user.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    fadeInDuration: const Duration(milliseconds: 120),
                    imageBuilder: (context, imageProvider) => Container(
                      height: imageHeight,
                      width: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  )
                : Icon(
                    Icons.person_outline,
                    size: imageHeight * 0.8,
                    color: ThemeColor.stroke,
                  ),
          ),
        ),
      ),
    );
  }
}

// currentStatus stories seenUsers
class UserIconMiniIcon extends ConsumerWidget {
  const UserIconMiniIcon({super.key, required this.user});
  final UserAccount user;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double imageHeight = 24;
    double radius = imageHeight / 2;
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: ThemeColor.accent,
          height: imageHeight,
          width: imageHeight,
          child: user.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: user.imageUrl!,
                  fadeInDuration: const Duration(milliseconds: 120),
                  imageBuilder: (context, imageProvider) => Container(
                    height: imageHeight,
                    width: imageHeight,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const SizedBox(),
                  errorWidget: (context, url, error) => const SizedBox(),
                )
              : Icon(
                  Icons.person_outline,
                  size: imageHeight * 0.8,
                  color: ThemeColor.stroke,
                ),
        ),
      ),
    );
  }
}

class UserIconStoryIcon extends ConsumerWidget {
  const UserIconStoryIcon(
      {super.key, required this.user, required this.isSeen});
  final UserAccount user;
  final bool isSeen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double strokeWidth = 2.4;
    const double padding = 4;
    const double boxHeight = 80.0;
    const double imageHeight = boxHeight - padding - strokeWidth;
    double radius = imageHeight * 2 / 9;
    return Container(
      width: boxHeight,
      height: boxHeight,
      padding: const EdgeInsets.all(strokeWidth),
      decoration: BoxDecoration(
        gradient: !isSeen
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purpleAccent,
                  Colors.cyan,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.2),
                ],
              ),
        borderRadius: BorderRadius.circular(
          radius + padding + strokeWidth,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: ThemeColor.background,
          borderRadius: BorderRadius.circular(
            radius + padding,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: ThemeColor.accent,
            height: imageHeight,
            width: imageHeight,
            child: user.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: user.imageUrl!,
                    fadeInDuration: const Duration(milliseconds: 120),
                    imageBuilder: (context, imageProvider) => Container(
                      height: imageHeight,
                      width: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(),
                    errorWidget: (context, url, error) => const SizedBox(),
                  )
                : const Icon(
                    Icons.person_outline,
                    size: imageHeight * 0.8,
                    color: ThemeColor.stroke,
                  ),
          ),
        ),
      ),
    );
  }
}

enum IconType {
  post,
  profile,
}

class UserIcon extends ConsumerWidget {
  const UserIcon({
    super.key,
    required this.user,
    this.iconType = IconType.post,
    this.navDisabled = false,
    this.enableDecoration = false,
    this.r,
  });
  final UserAccount user;
  final double? r;
  final IconType iconType;
  final bool navDisabled;
  final bool enableDecoration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double radius;
    if (r != null) {
      radius = r!;
    } else {
      switch (iconType) {
        case IconType.post:
          radius = 20;
        case IconType.profile:
          radius = 56;
        default:
          radius = 20;
      }
    }
    return GestureDetector(
      onTap: navDisabled
          ? null
          : () {
              // プロフィールアイコンで画像が存在する場合はオーバーレイ表示
              if (iconType == IconType.profile && user.imageUrl != null) {
                _showImageOverlay(context, user);
              } else {
                // それ以外はプロフィール画面に遷移

                ref.read(navigationRouterProvider(context)).goToProfile(user);
              }
            },
      child: Container(
        padding: enableDecoration ? const EdgeInsets.all(2) : EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: user.imageUrl != null
                ? CachedImage.userIcon(user.imageUrl!, user.name, radius)
                : Container(
                    color: const Color(0xFF2A2A2A),
                    child: Icon(
                      Icons.person,
                      size: radius,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showImageOverlay(BuildContext context, UserAccount user) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return UserImageOverlay(
            user: user,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// 画像オーバーレイウィジェット
class UserImageOverlay extends StatefulWidget {
  const UserImageOverlay({
    super.key,
    required this.user,
  });

  final UserAccount user;

  @override
  State<UserImageOverlay> createState() => _UserImageOverlayState();
}

class _UserImageOverlayState extends State<UserImageOverlay>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animationReset;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationReset!.addListener(() {
      _transformationController.value = _animationReset!.value;
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 120;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              // メイン画像表示エリア
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 2.0,
                    onInteractionEnd: (details) {
                      // ズームアウトしすぎた場合はリセット
                      if (_transformationController.value.getMaxScaleOnAxis() <
                          1.0) {
                        _resetAnimation();
                      }
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      child: UserIcon(
                        user: widget.user,
                        r: radius,
                        navDisabled: true,
                      ),
                    ),
                  ),
                ),
              ),

              // 閉じるボタン
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
