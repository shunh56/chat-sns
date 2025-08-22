// lib/presentation/components/notification/dm_notification_banner.dart
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/providers/dm_notification_provider.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DMNotificationBanner extends HookConsumerWidget {
  const DMNotificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dmNotificationState = ref.watch(dmNotificationProvider);
    final notification = dmNotificationState.notification;
    final isVisible = dmNotificationState.isVisible;

    // アニメーションコントローラー
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // スライドアニメーション
    final slideAnimation = useMemoized(() {
      return Tween<Offset>(
        begin: const Offset(0, -1), // 画面上から
        end: const Offset(0, 0), // 目標位置
      ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));
    }, [animationController]);

    // アニメーションの変化を監視
    useAnimation(animationController);

    // 表示状態に応じてアニメーション
    useEffect(() {
      if (isVisible) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isVisible]);

    // 通知がない場合は何も表示しない
    if (notification == null) {
      return const SizedBox.shrink();
    }

    final senderId = notification.sender.userId;
    final senderName = notification.sender.name;
    final messageText = notification.content.body;
    final senderImage = notification.sender.imageUrl;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              color: ThemeColor.accent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  // 通知を非表示にして画面遷移
                  ref.read(dmNotificationProvider.notifier).hideNotification();
                  ref
                      .read(navigationRouterProvider(context))
                      .goToChat(null, userId: senderId);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // プロフィール画像
                      CachedImage.userIcon(senderImage, senderName, 16),
                      const Gap(12),
                      // メッセージ内容
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              senderName,
                              style: const TextStyle(
                                color: ThemeColor.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.1,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              messageText,
                              style: const TextStyle(
                                color: ThemeColor.white,
                                fontSize: 15,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
