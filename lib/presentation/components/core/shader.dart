// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShaderWidget extends ConsumerWidget {
  const ShaderWidget({required this.child, this.sigma, super.key});
  final Widget child;
  final double? sigma;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma ?? 2.0, sigmaY: sigma ?? 2.0),
        child: child,
      ),
    );
  }
}
