// Flutter imports:

import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';

class StickyTabBarDelegete extends SliverPersistentHeaderDelegate {
  const StickyTabBarDelegete(this.tabBar, {this.bgColor});
  final TabBar tabBar;
  final Color? bgColor;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor ?? ThemeColor.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(StickyTabBarDelegete oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
