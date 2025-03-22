import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FreezedAccountScreen extends HookConsumerWidget {
  const FreezedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.ac_unit_rounded,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('アカウントが凍結されています', style: textStyle.w600(fontSize: 20)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '異常な行動が検知されたため、一時的に利用を制限しています',
                      textAlign: TextAlign.center,
                      style: textStyle.w600(
                        color: ThemeColor.subText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      launchUrl(
                        Uri.parse("https://blank-pj.vercel.app/contact/"),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
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
                          Icons.help_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'サポートに問い合わせ',
                          style: textStyle.w600(
                            fontSize: 14,
                          ),
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
    );
  }
}
