import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/navigation/navigator.dart';
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

class UserIcon extends ConsumerWidget {
  const UserIcon({
    super.key,
    required this.user,
    this.width = 60.0,
    this.navDisabled = false,
    this.isCircle = false,
  });
  final UserAccount user;
  final double width;
  final bool navDisabled;
  final bool isCircle;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double radius = isCircle ? width / 2 : width * 2 / 9;

    return GestureDetector(
      onTap: () {
        if (!navDisabled) {
          ref.read(navigationRouterProvider(context)).goToProfile(user);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: ThemeColor.accent,
          height: width,
          width: width,
          child: user.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: user.imageUrl!,
                  fadeInDuration: const Duration(milliseconds: 120),
                  imageBuilder: (context, imageProvider) => Container(
                    height: width,
                    width: width,
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
                  size: width * 0.8,
                  color: ThemeColor.stroke,
                ),
        ),
      ),
    );
  }
}

class UserIconCanvasIcon extends ConsumerWidget {
  const UserIconCanvasIcon({
    super.key,
    required this.user,
    this.theme,
  });
  final UserAccount user;
  final CanvasTheme? theme;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasTheme = theme ?? user.canvasTheme;
    const double imageHeight = 80.0;
    return Container(
      padding: EdgeInsets.all(canvasTheme.iconStrokeWidth),
      decoration: BoxDecoration(
        gradient: !canvasTheme.iconHideBorder
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  canvasTheme.iconGradientStartColor,
                  canvasTheme.iconGradientEndColor,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(
          canvasTheme.iconRadius + 12,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12 - canvasTheme.iconStrokeWidth),
        decoration: BoxDecoration(
          color: canvasTheme.bgColor,
          borderRadius: BorderRadius.circular(
            canvasTheme.iconRadius + 12 - canvasTheme.iconStrokeWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(canvasTheme.iconRadius),
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
