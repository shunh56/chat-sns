// アニメーションのための状態プロバイダー

/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// アニメーションのための状態プロバイダー

class FloatingShakeScreen extends ConsumerStatefulWidget {
  const FloatingShakeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FloatingShakeScreenState();
}

class _FloatingShakeScreenState extends ConsumerState<FloatingShakeScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Future.delayed(const Duration(milliseconds: 30));
    ref.read(animationControllerProvider.notifier).state = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    ref.read(animationControllerProvider)?.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        HapticFeedback.heavyImpact();
      }
    });
    await Future.delayed(const Duration(milliseconds: 60));
  }

  @override
  void dispose() {
    ref.watch(animationControllerProvider.notifier).state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPressed = ref.watch(isPressedProvider);
    final animationController = ref.watch(animationControllerProvider);

    // animationControllerがnullでないことを確認

    return Scaffold(
      appBar: AppBar(
        title: Text('Riverpod Floating Shake Animation'),
      ),
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) {
            animationController?.repeat(reverse: true);
            ref.read(isPressedProvider.state).state = true;
          },
          onLongPressEnd: (_) {
            animationController?.stop();
            ref.read(isPressedProvider.state).state = false;
          },
          child: (animationController == null)
              ? Center(child: CircularProgressIndicator())
              : AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    final scaleAnimation =
                        Tween<double>(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: animationController,
                        curve: Curves.easeOut,
                      ),
                    );

                    final shakeAnimation =
                        Tween<double>(begin: -pi / 24, end: pi / 24).animate(
                      CurvedAnimation(
                          parent: animationController, curve: Curves.easeInOut),
                    );
                    if (isPressed) {
                      return Transform.rotate(
                        angle: isPressed ? shakeAnimation.value : 0,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Long Press',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Long Press',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class AnimationControllerWidget extends ConsumerStatefulWidget {
  final Widget child;

  AnimationControllerWidget({required this.child});

  @override
  _AnimationControllerWidgetState createState() =>
      _AnimationControllerWidgetState();
}

class _AnimationControllerWidgetState
    extends ConsumerState<AnimationControllerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    ref.read(animationControllerProvider.notifier).state = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/*class FloatingShakeScreen extends StatefulWidget {
  @override
  _FloatingShakeScreenState createState() => _FloatingShakeScreenState();
}

class _FloatingShakeScreenState extends State<FloatingShakeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart() {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _onLongPressEnd() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floating Shake Animation'),
      ),
      body: Center(
        child: GestureDetector(
          onLongPressStart: (_) => _onLongPressStart(),
          onLongPressEnd: (_) => _onLongPressEnd(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Long Press',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
 */
*/