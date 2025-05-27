import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/discovery_provider.dart';

class FloatingControls extends ConsumerWidget {
  const FloatingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlOrb(
            icon: Icons.tune,
            tooltip: 'フィルター設定',
            onTap: () => ref
                .read(discoveryProvider.notifier)
                .toggleDetailPanel(DetailPanelType.filter),
          ),
          const SizedBox(height: 15),
          _buildControlOrb(
            icon: Icons.history,
            tooltip: '発見履歴',
            onTap: () => ref
                .read(discoveryProvider.notifier)
                .toggleDetailPanel(DetailPanelType.history),
          ),
          const SizedBox(height: 15),
          _buildControlOrb(
            icon: Icons.analytics,
            tooltip: '相性分析',
            onTap: () => ref
                .read(discoveryProvider.notifier)
                .toggleDetailPanel(DetailPanelType.analysis),
          ),
        ],
      ),
    );
  }

  Widget _buildControlOrb({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPink.withOpacity(0.9),
                AppColors.primaryBlue.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPink.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: 2.seconds,
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
          )
          .then()
          .scale(
            duration: 2.seconds,
            begin: const Offset(1.05, 1.05),
            end: const Offset(1, 1),
          ),
    );
  }
}
