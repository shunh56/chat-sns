import 'package:app/presentation/providers/heart_animation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HeartAnimation {
  final Offset position;
  final AnimationController controller;

  HeartAnimation({
    required this.position,
    required this.controller,
  });
}

final currentFilterProvider =
    StateProvider.family<int, String>((ref, viewerId) => 0);
final heartsProvider =
    StateProvider.family<List<HeartAnimation>, String>((ref, viewerId) => []);

class InteractiveMediaViewer extends HookConsumerWidget {
  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final Function(Offset)? onDoubleTap;

  const InteractiveMediaViewer({
    Key? key,
    required this.mediaUrls,
    required this.aspectRatios,
    this.onDoubleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewerId =
        useMemoized(() => mediaUrls.hashCode.toString(), [mediaUrls]);

    final filterController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final currentFilter = ref.watch(currentFilterProvider(viewerId));
    final hearts = ref.watch(heartsProvider(viewerId));

    final filters = [
      const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
      ColorFilter.mode(Colors.orange.withOpacity(0.3), BlendMode.multiply),
      ColorFilter.mode(Colors.purple.withOpacity(0.3), BlendMode.multiply),
      ColorFilter.mode(Colors.blue.withOpacity(0.3), BlendMode.multiply),
    ];

    void nextFilter() {
      ref.read(currentFilterProvider(viewerId).notifier).update(
            (state) => (state + 1) % filters.length,
          );
      filterController.forward().then((_) => filterController.reverse());
    }

    void previousFilter() {
      ref.read(currentFilterProvider(viewerId).notifier).update((state) {
        final newFilter = (state - 1) % filters.length;
        return newFilter < 0 ? filters.length - 1 : newFilter;
      });
      filterController.forward().then((_) => filterController.reverse());
    }

    void handleDoubleTap(TapDownDetails details) {
      //nextFilter();
      nextFilter();
    }

    /* void changeFilter(DragUpdateDetails details) {
      if (details.delta.dx > 5) {
        nextFilter();
      } else if (details.delta.dx < -5) {
        previousFilter();
      }
    } */

    if (mediaUrls.isEmpty) return const SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onDoubleTapDown: handleDoubleTap,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: filterController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (filterController.value * 0.05),
                  child: ColorFiltered(
                    colorFilter: filters[currentFilter],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: mediaUrls.length == 1
                          ? _buildSingleImage()
                          : _buildImageCarousel(),
                    ),
                  ),
                );
              },
            ),
            if (currentFilter > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFilterName(currentFilter),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ...hearts.map((heart) => _buildHeartAnimation(heart)).toList(),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ダブルタップでフィルター',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return AspectRatio(
      aspectRatio: aspectRatios.isNotEmpty ? aspectRatios[0] : 16 / 9,
      child: Image.network(
        mediaUrls[0],
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                mediaUrls[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeartAnimation(HeartAnimation heart) {
    return AnimatedBuilder(
      animation: heart.controller,
      builder: (context, child) {
        final progress = heart.controller.value;
        return Positioned(
          left: heart.position.dx - 15,
          top: heart.position.dy - (progress * 50) - 15,
          child: Opacity(
            opacity: 1.0 - progress,
            child: Transform.scale(
              scale: 1.0 + (progress * 0.5),
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFilterName(int index) {
    switch (index) {
      case 1:
        return 'Warm';
      case 2:
        return 'Cool';
      case 3:
        return 'Ocean';
      default:
        return 'Original';
    }
  }
}
