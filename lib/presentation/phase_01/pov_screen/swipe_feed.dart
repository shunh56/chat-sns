import 'dart:developer';

import 'package:app/domain/entity/pov.dart';
import 'package:app/presentation/phase_01/pov_screen/buttons.dart';
import 'package:app/presentation/phase_01/pov_screen/card.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

final swipeController = Provider((ref) => AppinioSwiperController());

class SwipePage extends ConsumerStatefulWidget {
  const SwipePage({super.key, required this.list});
  final List<Pov> list;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SwipePageState();
}

class _SwipePageState extends ConsumerState<SwipePage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      //_shakeCard(ref);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    final controller = ref.watch(swipeController);
    return Column(
      children: [
        const Gap(12),
        Expanded(
          child: AppinioSwiper(
            invertAngleOnBottomDrag: false,
            backgroundCardCount: 2,
            swipeOptions: const SwipeOptions.only(
              left: true,
              right: true,
            ),
            controller: controller,
            onCardPositionChanged: (
              SwiperPosition position,
            ) {},
            onSwipeEnd: _swipeEnd,
            onEnd: _onEnd,
            cardCount: list.length,
            cardBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onDoubleTap: () async {
                  HapticFeedback.lightImpact();
                  await _shakeCard(ref);
                  controller.swipeRight();
                },
                child: PovCard(
                  pov: list[index],
                ),
              );
            },
          ),
        ),
        const Gap(12),
        IconTheme.merge(
          data: const IconThemeData(size: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TutorialAnimationButton(
                onTap: _shakeCard,
              ),
              const SizedBox(
                width: 20,
              ),
              SwipeLeftButton(
                controller: controller,
                list: list,
              ),
              const SizedBox(
                width: 20,
              ),
              SwipeRightButton(
                controller: controller,
                list: list,
              ),
              const SizedBox(
                width: 20,
              ),
              UnSwipeButton(controller: controller),
            ],
          ),
        ),
        const Gap(12),
      ],
    );
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      //左右のどちらからにスワイプ
      case Swipe():
        log('The card was swiped to the : ${activity.direction}');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        //巻き戻し
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      //スワイプを途中キャンセル
      case CancelSwipe():
        log('A swipe was cancelled');
        break;
      // ?を押した時
      case DrivenActivity():
        log('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    log('end reached!');
  }

  // Animates the card back and forth to teach the user that it is swipable.
  Future<void> _shakeCard(WidgetRef ref) async {
    final controller = ref.watch(swipeController);
    try {
      const double distance = 30;
      // We can animate back and forth by chaining different animations.
      await controller.animateTo(
        const Offset(-distance, 0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
      await controller.animateTo(
        const Offset(distance, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      await controller.animateTo(
        const Offset(-distance, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      await controller.animateTo(
        const Offset(distance, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
      //   We need to animate back to the center because `animateTo` does not center
      //   the card for us.
      await controller.animateTo(
        const Offset(0, 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } catch (e) {}
  }
}
