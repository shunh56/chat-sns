import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoAlbum3d extends ConsumerStatefulWidget {
  const PhotoAlbum3d(
      {super.key,
      required this.child,
      required this.color,
      required this.function});
  final Widget child;
  final Color color;
  final Function function;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PhotoAlbum3dState();
}

class _PhotoAlbum3dState extends ConsumerState<PhotoAlbum3d> {
  double _position = 4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) {
        setState(() {
          _position = 4;
        });
      },
      onTapDown: (_) {
        setState(() {
          _position = 0;
        });
      },
      onTap: () async {
        widget.function();
        setState(() {
          _position = 0;
        });
        await Future.delayed(const Duration(milliseconds: 70));
        setState(() {
          _position = 4;
        });
      },
      onTapCancel: () {
        setState(() {
          _position = 4;
        });
      },
      child: SizedBox(
        height: 40 + 4,
        width: 162,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                height: 40,
                width: 162,
                decoration: BoxDecoration(
                  color: widget.color.darker(0.3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              curve: Curves.easeIn,
              left: 4,
              bottom: _position,
              duration: const Duration(milliseconds: 70),
              child: Container(
                height: 40,
                width: 162,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ColorDarker on Color {
  /// Makes a color darker by a given amount.
  ///
  /// [amount] should be between 0 and 1, where 0 is the original color and 1 is black.
  Color darker(double amount) {
    assert(amount >= 0 && amount <= 1, 'Amount should be between 0 and 1');
    double f = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}
