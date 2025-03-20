import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// メッセージにアニメーション効果を追加するラッパーウィジェット
class AnimatedMessageWidget extends HookWidget {
  final Widget child;
  final Duration duration;
  final bool slideFromBottom;
  
  /// メッセージに適用するアニメーションの種類
  final AnimationType animationType;

  const AnimatedMessageWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.animationType = AnimationType.fadeIn,
    this.slideFromBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    // アニメーションコントローラーを設定
    final animationController = useAnimationController(
      duration: duration,
    );

    // オパシティのアニメーション
    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      )),
    );

    // スケールのアニメーション
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0)
          .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      )),
    );

    // スライドのアニメーション
    final slideOffset = slideFromBottom ? const Offset(0, 0.2) : 
                       (animationType == AnimationType.slide && child is Row && (child as Row).mainAxisAlignment == MainAxisAlignment.end) 
                       ? const Offset(-0.1, 0) // 右側メッセージは右からスライドイン
                       : const Offset(0.1, 0);  // 左側メッセージは左からスライドイン
    
    final slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    // コンポーネント表示時にアニメーションを開始
    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    // 選択したアニメーションタイプに応じたウィジェットを返す
    switch (animationType) {
      case AnimationType.fadeIn:
        return Opacity(
          opacity: opacityAnimation,
          child: child,
        );
        
      case AnimationType.scale:
        return Transform.scale(
          scale: scaleAnimation,
          child: Opacity(
            opacity: opacityAnimation,
            child: child,
          ),
        );
        
      case AnimationType.slide:
        return SlideTransition(
          position: slideAnimation,
          child: Opacity(
            opacity: opacityAnimation,
            child: child,
          ),
        );
        
      case AnimationType.combined:
        return SlideTransition(
          position: slideAnimation,
          child: Transform.scale(
            scale: scaleAnimation,
            child: Opacity(
              opacity: opacityAnimation,
              child: child,
            ),
          ),
        );
    }
  }
}

/// アニメーションの種類を定義
enum AnimationType {
  fadeIn,   // フェードインのみ
  scale,    // スケール + フェードイン
  slide,    // スライド + フェードイン
  combined, // スライド + スケール + フェードイン
}