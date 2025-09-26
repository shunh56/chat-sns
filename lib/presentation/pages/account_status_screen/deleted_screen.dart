import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/auth_notifier.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeletedAccountScreen extends HookConsumerWidget {
  const DeletedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    // アニメーションコントローラー
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // フェードインアニメーション
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    // スケールアニメーション
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    // コンポーネントが表示されたときにアニメーションを開始
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Opacity(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アイコン
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 削除メッセージ
                  Text('アカウントが削除されています', style: textStyle.w600(fontSize: 20)),

                  const SizedBox(height: 12),

                  // 説明文
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'アカウントを再開するには以下のボタンをタップしてください',
                      textAlign: TextAlign.center,
                      style: textStyle.w600(
                        color: ThemeColor.subText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 再起動ボタン
                  Consumer(
                    builder: (context, ref, _) => FilledButton(
                      onPressed: () {
                        // アニメーション付きのフィードバック
                        HapticFeedback.mediumImpact();
                        ref
                            .read(myAccountNotifierProvider.notifier)
                            .rebootAccount();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ThemeColor.stroke,
                        foregroundColor: ThemeColor.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'アカウントを再開',
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // キャンセルボタン
                  TextButton(
                    onPressed: () {
                      ref.read(authNotifierProvider).signout();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    child: Text(
                      'キャンセル',
                      style: textStyle.w600(
                        fontSize: 14,
                        color: ThemeColor.subText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
