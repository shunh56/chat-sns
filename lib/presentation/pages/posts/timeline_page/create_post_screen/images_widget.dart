import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/transition/fade_transition_widget.dart';
import 'package:app/presentation/providers/state/create_post/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostImagesWidget extends ConsumerStatefulWidget {
  const PostImagesWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostImagesWidgetState();
}

class _PostImagesWidgetState extends ConsumerState<PostImagesWidget> {
  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageListNotifierProvider);
    final themeSize = ref.watch(themeSizeProvider(context));
    if (images.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        height: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: images.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: themeSize.horizontalPadding - 4,
          ),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: FadeTransitionWidget(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 160,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            ref
                                .read(imageListNotifierProvider.notifier)
                                .removeItem(index);
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox();
  }
}
