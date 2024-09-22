import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserIcon {
  static Widget postIcon(UserAccount user) {
    final canvasTheme = CanvasTheme.defaultCanvasTheme();
    const double strokeWidth = 1.6;
    const double padding = 4.0;
    double imageHeight = 36;
    double radius = imageHeight * 1 / 9;
    return Container(
      padding: const EdgeInsets.all(strokeWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            canvasTheme.iconGradientStartColor,
            canvasTheme.iconGradientEndColor,
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
          child: SizedBox(
            height: imageHeight,
            width: imageHeight,
            child: CachedNetworkImage(
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
            ),
          ),
        ),
      ),
    );
  }

  static Widget tileIcon(UserAccount user, {double? width}) {
    final canvasTheme = CanvasTheme.defaultCanvasTheme();

    const double strokeWidth = 2.0;
    const double padding = 4.0;
    double imageHeight = width ?? 60;
    double radius = imageHeight * 2 / 9;
    return Container(
      padding: const EdgeInsets.all(strokeWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            canvasTheme.iconGradientStartColor,
            canvasTheme.iconGradientEndColor,
          ],
        ),
        borderRadius: BorderRadius.circular(
          radius + padding,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8 - strokeWidth),
        decoration: BoxDecoration(
          color: ThemeColor.background,
          borderRadius: BorderRadius.circular(
            radius + padding - strokeWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: imageHeight,
            width: imageHeight,
            child: CachedNetworkImage(
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
            ),
          ),
        ),
      ),
    );
  }

  static Widget bottomSheetIcon(UserAccount user) {
    final canvasTheme = CanvasTheme.defaultCanvasTheme();

    const double strokeWidth = 2.0;
    const double padding = 4.0;
    double imageHeight = 48;
    double radius = imageHeight * 2 / 9;
    return Container(
      padding: const EdgeInsets.all(strokeWidth),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            canvasTheme.iconGradientStartColor,
            canvasTheme.iconGradientEndColor,
          ],
        ),
        borderRadius: BorderRadius.circular(
          radius + padding,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8 - strokeWidth),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
            radius + padding - strokeWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            height: imageHeight,
            width: imageHeight,
            child: CachedNetworkImage(
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
            ),
          ),
        ),
      ),
    );
  }

  static Widget circleIcon(UserAccount user, {double? radius}) {
    radius = radius ?? 20;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: CachedNetworkImage(
          imageUrl: user.imageUrl!,
          fadeInDuration: const Duration(milliseconds: 120),
          imageBuilder: (context, imageProvider) => Container(
            height: radius! * 2,
            width: radius * 2,
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
        ),
      ),
    );
  }
}
