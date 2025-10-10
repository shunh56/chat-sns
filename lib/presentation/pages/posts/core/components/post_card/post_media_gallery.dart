// lib/presentation/pages/posts/core/components/post_card/post_media_gallery.dart
import 'dart:math';
import 'package:app/presentation/pages/posts/core/components/style/post_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/user/post_images_screen.dart';
import 'package:gap/gap.dart';

/// メディア表示のレイアウトタイプ
enum MediaLayoutType {
  single, // 単一画像
  multiple, // 複数画像
  grid, // グリッド表示
}

/// メディアギャラリーの状態プロバイダー
final mediaGalleryStateProvider =
    StateProvider.family<MediaGalleryState, String>(
  (ref, galleryId) => MediaGalleryState(),
);

/// メディアギャラリーの状態
class MediaGalleryState {
  final int currentFilterIndex;
  final int currentImageIndex;
  final bool isLoading;

  MediaGalleryState({
    this.currentFilterIndex = 0,
    this.currentImageIndex = 0,
    this.isLoading = false,
  });

  MediaGalleryState copyWith({
    int? currentFilterIndex,
    int? currentImageIndex,
    bool? isLoading,
  }) {
    return MediaGalleryState(
      currentFilterIndex: currentFilterIndex ?? this.currentFilterIndex,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 投稿のメディアギャラリーウィジェット
class PostMediaGallery extends HookConsumerWidget {
  const PostMediaGallery({
    super.key,
    required this.mediaUrls,
    required this.aspectRatios,
    this.layoutType,
    this.maxHeight = 400,
    this.borderRadius = 12,
    this.enableFilters = true,
    this.enableInteraction = false,
    this.onImageTap,
    this.onDoubleTap,
  });

  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final MediaLayoutType? layoutType;
  final double maxHeight;
  final double borderRadius;
  final bool enableFilters;
  final bool enableInteraction;
  final Function(int index)? onImageTap;
  final Function(Offset position)? onDoubleTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaUrls.isEmpty) return const SizedBox();

    final galleryId =
        useMemoized(() => mediaUrls.hashCode.toString(), [mediaUrls]);
    final galleryState = ref.watch(mediaGalleryStateProvider(galleryId));
    final layoutType = this.layoutType ?? _determineLayoutType();

    return _buildMediaLayout(context, ref, galleryId, galleryState, layoutType);
  }

  /// レイアウトタイプを決定
  MediaLayoutType _determineLayoutType() {
    if (mediaUrls.length == 1) {
      return MediaLayoutType.single;
    } else if (mediaUrls.length <= 4) {
      return MediaLayoutType.multiple;
    } else {
      return MediaLayoutType.grid;
    }
  }

  /// メディアレイアウトを構築
  Widget _buildMediaLayout(
    BuildContext context,
    WidgetRef ref,
    String galleryId,
    MediaGalleryState galleryState,
    MediaLayoutType layoutType,
  ) {
    switch (layoutType) {
      case MediaLayoutType.single:
        return _buildSingleImage(context, ref, galleryId, galleryState);
      case MediaLayoutType.multiple:
        return _buildMultipleImages(context, ref, galleryId, galleryState);
      case MediaLayoutType.grid:
        return _buildGridImages(context, ref, galleryId, galleryState);
    }
  }

  /// 単一画像の表示
  Widget _buildSingleImage(
    BuildContext context,
    WidgetRef ref,
    String galleryId,
    MediaGalleryState galleryState,
  ) {
    final aspectRatio = aspectRatios.isNotEmpty
        ? aspectRatios[0] < 1
            ? min(1 / aspectRatios[0], 16 / 9)
            : max(1 / aspectRatios[0], 4 / 5)
        : 16 / 9;

    return _buildImageContainer(
      context: context,
      ref: ref,
      galleryId: galleryId,
      galleryState: galleryState,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _buildFilteredImage(
          mediaUrls[0],
          galleryState.currentFilterIndex,
          fit: BoxFit.cover,
          onTap: () => _handleImageTap(context, 0),
          onDoubleTap: onDoubleTap,
        ),
      ),
    );
  }

  /// 複数画像の表示
  Widget _buildMultipleImages(
    BuildContext context,
    WidgetRef ref,
    String galleryId,
    MediaGalleryState galleryState,
  ) {
    final pageController = usePageController();

    return _buildImageContainer(
      context: context,
      ref: ref,
      galleryId: galleryId,
      galleryState: galleryState,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _calculateOptimalAspectRatio(),
            child: PageView.builder(
              controller: pageController,
              itemCount: mediaUrls.length,
              onPageChanged: (index) {
                ref.read(mediaGalleryStateProvider(galleryId).notifier).update(
                    (state) => state.copyWith(currentImageIndex: index));
              },
              itemBuilder: (context, index) {
                return _buildFilteredImage(
                  mediaUrls[index],
                  galleryState.currentFilterIndex,
                  fit: BoxFit.cover,
                  onTap: () => _handleImageTap(context, index),
                  onDoubleTap: onDoubleTap,
                );
              },
            ),
          ),

          // ページインジケーター
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: _buildPageIndicator(
                  galleryState.currentImageIndex, mediaUrls.length),
            ),

          // 画像カウンター
          if (mediaUrls.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: _buildImageCounter(
                  galleryState.currentImageIndex, mediaUrls.length),
            ),
        ],
      ),
    );
  }

  /// グリッド画像の表示
  Widget _buildGridImages(
    BuildContext context,
    WidgetRef ref,
    String galleryId,
    MediaGalleryState galleryState,
  ) {
    return _buildImageContainer(
      context: context,
      ref: ref,
      galleryId: galleryId,
      galleryState: galleryState,
      child: SizedBox(
        height: maxHeight,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: min(mediaUrls.length, 6),
          itemBuilder: (context, index) {
            if (index == 5 && mediaUrls.length > 6) {
              return _buildMoreImagesOverlay(context, index);
            }

            return _buildFilteredImage(
              mediaUrls[index],
              galleryState.currentFilterIndex,
              fit: BoxFit.cover,
              onTap: () => _handleImageTap(context, index),
              onDoubleTap: onDoubleTap,
            );
          },
        ),
      ),
    );
  }

  /// 画像コンテナを構築
  Widget _buildImageContainer({
    required BuildContext context,
    required WidgetRef ref,
    required String galleryId,
    required MediaGalleryState galleryState,
    required Widget child,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        ),

        // フィルター名表示
        if (enableFilters && galleryState.currentFilterIndex > 0)
          Positioned(
            top: 8,
            left: 8,
            child: _buildFilterIndicator(galleryState.currentFilterIndex),
          ),

        // 操作ヒント
        if (enableInteraction)
          Positioned(
            bottom: 8,
            left: 8,
            child: _buildInteractionHint(),
          ),
      ],
    );
  }

  /// フィルター付き画像を構築
  Widget _buildFilteredImage(
    String imageUrl,
    int filterIndex, {
    BoxFit fit = BoxFit.cover,
    VoidCallback? onTap,
    Function(Offset)? onDoubleTap,
  }) {
    final filters = MediaFilterManager.getFilters();

    return GestureDetector(
      onTap: onTap,
      onDoubleTapDown: (details) {
        if (enableFilters) {
          onDoubleTap?.call(details.localPosition);
        }
      },
      child: ColorFiltered(
        colorFilter: filters[filterIndex],
        child: CachedImage.postImage(
          imageUrl,
          /*fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          }, */
        ),
      ),
    );
  }

  /// ページインジケーターを構築
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
            min(totalPages, 5),
            (index) {
              final isActive = index == currentIndex;
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

  /// 画像カウンターを構築
  Widget _buildImageCounter(int currentIndex, int totalImages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library,
            color: Colors.white,
            size: 12,
          ),
          const Gap(4),
          Text(
            '${currentIndex + 1}/$totalImages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// フィルターインジケーターを構築
  Widget _buildFilterIndicator(int filterIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        MediaFilterManager.getFilterName(filterIndex),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 操作ヒントを構築
  Widget _buildInteractionHint() {
    final hintText =
        mediaUrls.length > 1 ? 'スワイプで画像切替・ダブルタップでフィルター' : 'ダブルタップでフィルター';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hintText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  /// 追加画像オーバーレイを構築
  Widget _buildMoreImagesOverlay(BuildContext context, int index) {
    final remainingCount = mediaUrls.length - 5;

    return GestureDetector(
      onTap: () => _handleImageTap(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildFilteredImage(
            mediaUrls[index],
            0,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 最適なアスペクト比を計算
  double _calculateOptimalAspectRatio() {
    if (aspectRatios.isEmpty) return 16 / 9;

    final avgRatio = aspectRatios.reduce((a, b) => a + b) / aspectRatios.length;
    return avgRatio < 1 ? min(1 / avgRatio, 16 / 9) : max(1 / avgRatio, 4 / 5);
  }

  /// 画像タップ処理
  void _handleImageTap(BuildContext context, int index) {
    if (onImageTap != null) {
      onImageTap!(index);
    } else {
      Navigator.push(
        context,
        PageTransitionMethods.fadeIn(
          PostImageHero(
            imageUrls: mediaUrls,
            aspectRatios: aspectRatios,
            initialIndex: index,
          ),
        ),
      );
    }
  }
}

/// メディアギャラリーのスケルトンローディング
class PostMediaGallerySkeleton extends StatelessWidget {
  const PostMediaGallerySkeleton({
    super.key,
    this.aspectRatio = 16 / 9,
    this.borderRadius = 12,
  });

  final double aspectRatio;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            color: Colors.grey.withOpacity(0.3),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
