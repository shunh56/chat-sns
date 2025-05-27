import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/discovery_mode.dart';
import '../providers/discovery_provider.dart';

class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoveryState = ref.watch(discoveryProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: DiscoveryMode.values.map((mode) {
          final isActive = discoveryState.selectedMode == mode;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  ref.read(discoveryProvider.notifier).changeMode(mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryPink.withOpacity(0.3)
                        : AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? Colors.white.withOpacity(0.4)
                          : AppColors.glassBorder,
                      width: 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    mode.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ).animate(target: isActive ? 1 : 0)
                .scale(end: const Offset(1.05, 1.05), duration: 200.ms),
            ),
          );
        }).toList(),
      ),
    );
  }
}
