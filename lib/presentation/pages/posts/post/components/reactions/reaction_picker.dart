import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReactionData {
  final String emoji;
  final String type;
  final Color color;

  ReactionData(this.emoji, this.type, this.color);
}

class ReactionPicker extends HookConsumerWidget {
  final Function(String) onReactionSelected;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
      ),
    );

    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    final reactions = [
      ReactionData('❤️', 'love', Colors.red),
      ReactionData('🔥', 'fire', Colors.orange),
      ReactionData('😍', 'wow', Colors.pink),
      ReactionData('👏', 'clap', Colors.yellow),
      ReactionData('😂', 'laugh', Colors.blue),
      ReactionData('😢', 'sad', Colors.blue.shade300),
    ];

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Transform.scale(
          scale: scaleAnimation,
          child: Opacity(
            opacity: opacityAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.stroke,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: reactions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final reaction = entry.value;
                      return GestureDetector(
                        onTap: () {
                          onReactionSelected(reaction.type);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: reaction.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            reaction.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Gap(12),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeColor.stroke.withOpacity(0.8),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeColor.stroke,
                            ThemeColor.background,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: ThemeColor.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
