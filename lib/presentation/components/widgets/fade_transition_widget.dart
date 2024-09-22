// Flutter imports:
import 'package:flutter/widgets.dart';

class FadeTransitionWidget extends StatefulWidget {
  const FadeTransitionWidget({super.key, required this.child, this.ms});
  final Widget child;
  final int? ms;
  @override
  State<FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.ms ?? 400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );
    _controller!.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation!,
      child: widget.child,
    );
  }
}
