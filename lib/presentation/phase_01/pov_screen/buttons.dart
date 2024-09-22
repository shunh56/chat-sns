import 'package:app/domain/entity/pov.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeLeftButton extends ConsumerWidget {
  const SwipeLeftButton({
    super.key,
    required this.controller,
    required this.list,
  });
  final AppinioSwiperController controller;
  final List<Pov> list;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final SwiperPosition? position = controller.position;
        final SwiperActivity? activity = controller.swipeActivity;
        final double horizontalProgress =
            (activity is Swipe || activity == null) &&
                    position != null &&
                    position.offset.toAxisDirection().isHorizontal
                ? -1 * position.progressRelativeToThreshold.clamp(-1, 1)
                : 0;
        final Color color = Color.lerp(
          const Color(0xFFFF3868),
          CupertinoColors.systemGrey2,
          (-1 * horizontalProgress).clamp(0, 1),
        )!;
        return GestureDetector(
          onTap: () {
            if ((controller.cardIndex!) < list.length) {
              controller.swipeLeft();
            }
          },
          child: Transform.scale(
            // Increase the button size as we swipe towards it.
            scale: 1 + .1 * horizontalProgress.clamp(0, 1),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.9),
                    spreadRadius: -10,
                    blurRadius: 20,
                    offset: const Offset(0, 20), // changes position of shadow
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close,
                color: CupertinoColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SwipeRightButton extends ConsumerWidget {
  const SwipeRightButton(
      {super.key, required this.controller, required this.list});
  final AppinioSwiperController controller;
  final List<Pov> list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final SwiperPosition? position = controller.position;
        final SwiperActivity? activity = controller.swipeActivity;
        // Lets measure the progress of the swipe iff it is a horizontal swipe.
        final double progress = (activity is Swipe || activity == null) &&
                position != null &&
                position.offset.toAxisDirection().isHorizontal
            ? position.progressRelativeToThreshold.clamp(-1, 1)
            : 0;
        // Lets animate the button according to the
        // progress. Here we'll color the button more grey as we swipe away from
        // it.
        final Color color = Color.lerp(
          CupertinoColors.activeGreen,
          CupertinoColors.systemGrey2,
          (-1 * progress).clamp(0, 1),
        )!;
        return GestureDetector(
          onTap: () {
            if ((controller.cardIndex!) < list.length) {
              controller.swipeRight();
            }
          },
          child: Transform.scale(
            scale: 1 + .1 * progress.clamp(0, 1),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.9),
                    spreadRadius: -10,
                    blurRadius: 20,
                    offset: const Offset(0, 20), // changes position of shadow
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                color: CupertinoColors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
}

class UnSwipeButton extends ConsumerWidget {
  const UnSwipeButton({super.key, required this.controller});
  final AppinioSwiperController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => controller.unswipe(),
      child: Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        child: const Icon(
          Icons.rotate_left_rounded,
          color: CupertinoColors.systemGrey2,
        ),
      ),
    );
  }
}

class TutorialAnimationButton extends ConsumerWidget {
  const TutorialAnimationButton({super.key, required this.onTap});

  final Function onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        onTap(ref);
      },
      child: const Icon(
        Icons.question_mark,
        color: CupertinoColors.systemGrey2,
      ),
    );
  }
}
