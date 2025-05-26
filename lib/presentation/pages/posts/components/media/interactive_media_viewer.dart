import 'dart:math';

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
final currentImageIndexProvider =
    StateProvider.family<int, String>((ref, viewerId) => 0);

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

    final pageController = usePageController();
    final currentFilter = ref.watch(currentFilterProvider(viewerId));
    final hearts = ref.watch(heartsProvider(viewerId));
    final currentImageIndex = ref.watch(currentImageIndexProvider(viewerId));

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
      nextFilter();
    }

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
                          : _buildMultipleImagesDisplay(
                              pageController, ref, viewerId),
                    ),
                  ),
                );
              },
            ),

            // フィルター名表示
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

            // 複数画像の場合のインジケーター
            if (mediaUrls.length > 1) ...[
              // 画像カウンター（右上）
              Positioned(
                top: 8,
                right: currentFilter > 0 ? 80 : 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentImageIndex + 1}/${mediaUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ページドットインジケーター（下部中央）
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: _buildPageIndicator(currentImageIndex, mediaUrls.length),
              ),
            ],

            // ハートアニメーション
            ...hearts.map((heart) => _buildHeartAnimation(heart)).toList(),

            // 操作ヒント
            Positioned(
              bottom: mediaUrls.length > 1 ? 32 : 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mediaUrls.length > 1
                      ? 'スワイプで画像切替・ダブルタップでフィルター'
                      : 'ダブルタップでフィルター',
                  style: const TextStyle(
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
      aspectRatio: aspectRatios.isNotEmpty
          ? aspectRatios[0] < 1
              ? min(1 / aspectRatios[0], 16 / 9)
              : max(1 / aspectRatios[0], 4 / 5)
          : 16 / 9,
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

  Widget _buildMultipleImagesDisplay(
      PageController pageController, WidgetRef ref, String viewerId) {
    return Stack(
      children: [
        // メイン画像表示エリア
        AspectRatio(
          aspectRatio: _calculateOptimalAspectRatio(),
          child: PageView.builder(
            controller: pageController,
            itemCount: mediaUrls.length,
            onPageChanged: (index) {
              ref.read(currentImageIndexProvider(viewerId).notifier).state =
                  index;
            },
            itemBuilder: (context, index) {
              return Image.network(
                mediaUrls[index],
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
              );
            },
          ),
        ),

        // 複数画像があることを示すスタック表示（左上）
        if (mediaUrls.length > 1)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildImageStackIndicator(),
          ),
      ],
    );
  }

  Widget _buildImageStackIndicator() {
    return Container(
      width: 48,
      height: 60, // 5:4の比率 (48:60 = 4:5)
      child: Stack(
        children: [
          // 背景の画像カード（3枚重ね）- 後ろから前に向かって配置
          for (int i = min(3, mediaUrls.length) - 1; i >= 0; i--)
            Positioned(
              left: i * 6.0, // より大きなオフセットでスタック感を強調
              top: i * 4.0,
              child: Transform.rotate(
                angle: i * 0.05, // 微細な回転でより自然なスタック効果
                child: Container(
                  width: 32 - (i * 2), // 5:4の比率を維持
                  height: 40 - (i * 2.5),
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.white : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25 + (i * 0.1)),
                        blurRadius: 4 + (i * 2),
                        offset: Offset(1 + i.toDouble(), 2 + i.toDouble()),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.5),
                      child: Image.network(
                        mediaUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int currentIndex, int totalPages) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            min(totalPages, 5), // 最大5個のドットまで表示
            (index) {
              final isActive = index == currentIndex;
              final shouldShowDots = totalPages > 5 && currentIndex > 2;
              final displayIndex =
                  shouldShowDots ? currentIndex - 2 + index : index;

              if (shouldShowDots && displayIndex >= totalPages)
                return SizedBox();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: isActive ? 8 : 6,
                height: isActive ? 8 : 6,
                decoration: BoxDecoration(
                  color:
                      isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
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

  double _calculateOptimalAspectRatio() {
    if (aspectRatios.isEmpty) return 16 / 9;

    // 複数画像の場合は平均的なアスペクト比を計算
    final avgRatio = aspectRatios.reduce((a, b) => a + b) / aspectRatios.length;
    return avgRatio < 1 ? min(1 / avgRatio, 16 / 9) : max(1 / avgRatio, 4 / 5);
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
