import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThreeDimensionalTextButton extends ConsumerStatefulWidget {
  const ThreeDimensionalTextButton(
      {super.key,
      required this.child,
      required this.color,
      required this.function});
  final Widget child;
  final Color color;
  final Function function;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ThreeDimensionalTextButtonState();
}

class _ThreeDimensionalTextButtonState
    extends ConsumerState<ThreeDimensionalTextButton> {
  double _position = 12;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) {
        setState(() {
          _position = 12;
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
          _position = 12;
        });
      },
      onTapCancel: () {
        setState(() {
          _position = 12;
        });
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          //..setEntry(3, 1, -0.0003)
          ..setEntry(3, 2, 0.001) // 立体的な効果のための透視設定
          //..rotateZ(-pi / 120)
          //..rotateX(-pi / 48) // X軸に少し傾ける
          ..rotateY(-pi / 12), // Y軸に少し傾ける
        child: SizedBox(
          height: 240 + 12,
          width: 240 + 12,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    color: widget.color.darker(0.3),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                ),
              ),
              ...List.generate(
                12,
                (index) => Positioned(
                  left: index.toDouble(),
                  bottom: index.toDouble() / 2,
                  child: Container(
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      color: widget.color.brighter((12 - index) / 4),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                curve: Curves.easeIn,
                left: _position,
                bottom: _position / 2,
                duration: const Duration(milliseconds: 70),
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
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

  Color brighter(double amount) {
    assert(amount >= 0, 'Amount should be bigger thant 0');
    double f = amount;
    return Color.fromARGB(
      alpha,
      (red * (1 + f)).round(),
      (green * (1 + f)).round(),
      (blue * (1 + f)).round(),
    );
  }
}
