import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../constants/tempo_colors.dart';
import '../constants/tempo_text_styles.dart';
import '../constants/tempo_spacing.dart';
import 'home/discover_page.dart';
import 'home/connections_page.dart';
import 'home/profile_page.dart';

class TempoHomePage extends HookConsumerWidget {
  const TempoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final pageController = usePageController();

    final pages = [
      const DiscoverPage(),
      const ConnectionsPage(), 
      const ProfilePage(),
    ];

    final tabItems = [
      const _TabItem(
        icon: Icons.explore,
        activeIcon: Icons.explore_rounded,
        label: '発見',
        gradient: TempoColors.primaryGradient,
      ),
      const _TabItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: '繋がり',
        gradient: TempoColors.warmGradient,
      ),
      const _TabItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'プロフィール',
        gradient: TempoColors.successGradient,
      ),
    ];

    return Scaffold(
      backgroundColor: TempoColors.background,
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          currentIndex.value = index;
        },
        children: pages,
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: TempoColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TempoSpacing.lg,
              vertical: TempoSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = currentIndex.value == index;

                return _TabButton(
                  item: item,
                  isActive: isActive,
                  onTap: () {
                    currentIndex.value = index;
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final LinearGradient gradient;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
  });
}

class _TabButton extends HookWidget {
  final _TabItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
      ),
    );

    useEffect(() {
      if (isActive) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [isActive]);

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(
            horizontal: TempoSpacing.md,
            vertical: TempoSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isActive ? item.gradient : null,
            borderRadius: BorderRadius.circular(16),
            border: isActive ? null : Border.all(
              color: TempoColors.textTertiary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 24,
                color: isActive ? Colors.white : TempoColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TempoTextStyles.caption.copyWith(
                  color: isActive ? Colors.white : TempoColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}