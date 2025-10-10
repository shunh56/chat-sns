// lib/presentation/pages/posts/shared/components/base_card.dart
import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 基本的なカードコンポーネント
/// すべての投稿カードの基底となる統一されたスタイルを提供
class BaseCard extends ConsumerWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16.0,
    this.elevation = 0.0,
    this.enableHoverEffect = true,
    this.enableShadow = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double elevation;
  final bool enableHoverEffect;
  final bool enableShadow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? ThemeColor.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: elevation,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: enableHoverEffect
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          highlightColor: enableHoverEffect
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? ThemeColor.cardBorderColor,
                width: 1.0,
              ),
              boxShadow: enableShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
