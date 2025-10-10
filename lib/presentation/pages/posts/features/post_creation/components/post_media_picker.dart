import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/presentation/components/transition/fade_transition_widget.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';

/// 投稿メディア表示・管理コンポーネント
///
/// 機能:
/// - 選択された画像の表示
/// - 複数画像のレイアウト対応
/// - 画像削除機能
/// - レスポンシブデザイン
class PostMediaPicker extends ConsumerWidget {
  const PostMediaPicker({
    super.key,
    this.onImagePicked,
    this.onVideoPicked,
  });

  final Function(List<String>)? onImagePicked;
  final Function(String)? onVideoPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageListNotifierProvider);

    if (images.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;

    // 単一画像レイアウト
    if (images.length == 1) {
      return _buildSingleImageLayout(ref, screenWidth, images);
    }

    // 複数画像レイアウト
    return _buildMultipleImagesLayout(ref, images);
  }

  Widget _buildSingleImageLayout(
    WidgetRef ref,
    double screenWidth,
    List<dynamic> images,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FadeTransitionWidget(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: screenWidth,
                child: Image.file(
                  images[0],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _buildRemoveButton(ref, 0),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleImagesLayout(
    WidgetRef ref,
    List<dynamic> images,
  ) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: images.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: FadeTransitionWidget(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 160,
                      height: 200,
                      child: Image.file(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  _buildRemoveButton(ref, index, isCompact: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemoveButton(
    WidgetRef ref,
    int index, {
    bool isCompact = false,
  }) {
    return Positioned(
      top: isCompact ? 6 : 12,
      right: isCompact ? 6 : 12,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 4 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
        ),
        child: GestureDetector(
          onTap: () {
            ref.read(imageListNotifierProvider.notifier).removeItem(index);
          },
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
