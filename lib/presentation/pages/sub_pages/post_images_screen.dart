import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostImageHero extends ConsumerWidget {
  const PostImageHero({
    super.key,
    required this.imageUrls,
    required this.aspectRatios,
    required this.initialIndex,
    // required this.tag,
  });
  final List<String> imageUrls;
  final List<double> aspectRatios;

  final int initialIndex;
  //final String tag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width - 48;
    final height = MediaQuery.sizeOf(context).height - 240;

    final lockedInWidth = MediaQuery.sizeOf(context).width;
    final lockedInHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: ThemeColor.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AnimatedOpacity(
          opacity: ref.watch(lockedInProvider) ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () {
              if (!ref.watch(lockedInProvider)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          ref.read(lockedInProvider.notifier).state =
              !ref.read(lockedInProvider);
        },
        child: PageView.builder(
          itemCount: imageUrls.length,
          controller: PageController(initialPage: initialIndex),
          itemBuilder: (context, index) {
            final tooHigh = width * aspectRatios[index] > height;
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  curve: Curves.easeInOutQuint,
                  duration: const Duration(milliseconds: 400),
                  width: ref.watch(lockedInProvider)
                      ? lockedInWidth
                      : tooHigh
                          ? height / aspectRatios[index]
                          : width,
                  height: ref.watch(lockedInProvider)
                      ? lockedInHeight
                      : min(
                          height,
                          width * aspectRatios[index],
                        ),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 1.6,
                    child: CachedImage.heroImage(
                      imageUrls[index],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final lockedInProvider = StateProvider((ref) => false);
