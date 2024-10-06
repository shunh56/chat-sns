import 'package:app/core/utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class CachedImage {
  static threadIcon(String imageUrl, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fadeInDuration: const Duration(milliseconds: 120),
          imageBuilder: (context, imageProvider) => Container(
            height: radius * 2,
            width: radius * 2,
            decoration: BoxDecoration(
              color: Colors.white,
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

  static threadThumbnailImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      child: SizedBox(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fadeInDuration: const Duration(milliseconds: 120),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
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

  static userImage(String imageUrl, double imageWidth) {
    return SizedBox(
      width: imageWidth,
      height: imageWidth * 5 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fadeInDuration: const Duration(milliseconds: 120),
          imageBuilder: (context, imageProvider) => Container(
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

  static Widget userIcon(
    String? imageUrl,
    String name,
    double radius,
  ) {
    if (name.length > 1) {
      name = name.substring(0, 1);
    }
    if (imageUrl == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: radius * 2,
          width: radius * 2,
          color: ThemeColor.icon,
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: radius,
                fontWeight: FontWeight.w600,
                color: ThemeColor.background,
              ),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fadeInDuration: const Duration(milliseconds: 120),
          imageBuilder: (context, imageProvider) => Container(
            height: radius * 2,
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

  static image(String imageUrl, String hash, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => BlurHash(hash: hash),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: const Center(
          child: Icon(Icons.error_outline_rounded, color: ThemeColor.beige),
        ),
      ),
    );
  }

  static Widget postImage(String imageUrl, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      color: ThemeColor.beige,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: ThemeColor.beige,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: ThemeColor.beige,
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: ThemeColor.highlight,
          ),
        ),
      ),
    );
  }

  static Widget profileBoardImage(String imageUrl, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      color: ThemeColor.beige,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: ThemeColor.beige,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: ThemeColor.beige,
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: ThemeColor.highlight,
          ),
        ),
      ),
    );
  }

  static heroImage(String imageUrl, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: ThemeColor.beige,
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: ThemeColor.button,
          ),
        ),
      ),
    );
  }

  /*static imageWithNoHash(String imageUrl, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: MainThemeColors.username,
          ),
        ),
      ),
    );
  }
 */
  /* static heroImage(String imageUrl, {int ms = 300}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: Duration(milliseconds: ms),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: MainThemeColors.username,
          ),
        ),
      ),
    );
  } */
}
