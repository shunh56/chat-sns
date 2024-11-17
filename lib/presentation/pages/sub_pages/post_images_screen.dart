import 'dart:math';

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

    //final designSize = DesignSize(MediaQuery.sizeOf(context).width);

    return Stack(
      children: [
        GestureDetector(
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

        /* Positioned(
          top: MediaQuery.of(context).viewPadding.top,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: ref.watch(lockedInProvider) ? 0 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!ref.watch(lockedInProvider)) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ) */
      ],
      //  ),
    );
  }
}

final lockedInProvider = StateProvider((ref) => false);
