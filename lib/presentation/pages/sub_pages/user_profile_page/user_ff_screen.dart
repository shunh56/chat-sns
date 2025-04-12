import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/search_screen/widgets/tiles.dart';

import 'package:app/presentation/providers/new/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/new/providers/follow/followers_list_notifier.dart';
import 'package:app/presentation/providers/new/providers/follow/user_followings_followers.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class UserFFScreen extends ConsumerWidget {
  const UserFFScreen({
    super.key,
    required this.user,
  });

  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            user.name,
            style: textStyle.w600(fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: ThemeColor.background,
        ),
        body: Column(
          children: [
            Container(
              color: ThemeColor.background,
              child: TabBar(
                labelColor: ThemeColor.text,
                unselectedLabelColor: ThemeColor.subText,
                indicatorColor: ThemeColor.highlight,
                dividerColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: GradientTabIndicator(
                  colors: const [
                    ThemeColor.highlight,
                    Colors.cyan,
                  ],
                  weight: 2,
                  width: themeSize.screenWidth / 2.4,
                  radius: 8,
                ),
                tabs: [
                  Tab(
                    child: SizedBox(
                      width: themeSize.screenWidth / 2.4,
                      child: Center(
                        child: Text(
                          "フォロワー",
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      width: themeSize.screenWidth / 2.4,
                      child: Center(
                        child: Text(
                          "フォロー中",
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(4),
            Expanded(
              child: TabBarView(
                children: [
                  _FFListView(
                    user: user,
                    type: FFType.followers,
                  ),
                  _FFListView(
                    user: user,
                    type: FFType.following,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientTabIndicator extends Decoration {
  final BoxPainter _painter;

  GradientTabIndicator({
    required List<Color> colors,
    required double weight,
    required double width,
    required double radius,
  }) : _painter = _GradientPainter(colors, weight, width, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _GradientPainter extends BoxPainter {
  final Paint _paint;
  final double weight;
  final double width;
  final double radius;
  final List<Color> colors;

  _GradientPainter(this.colors, this.weight, this.width, this.radius)
      : _paint = Paint()
          ..isAntiAlias = true
          ..strokeCap = StrokeCap.round
          ..strokeWidth = weight
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Rect rect = offset & configuration.size!;
    final double left = rect.left + (rect.width - width) / 2;
    final double top = rect.bottom - weight;

    // グラデーションの設定
    final gradient = LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    // 丸みを帯びた長方形のパスを作成
    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, weight),
      Radius.circular(radius),
    );

    // グラデーションを適用
    _paint.shader = gradient.createShader(roundedRect.outerRect);

    canvas.drawRRect(roundedRect, _paint);
  }
}

enum FFType { followers, following }

class _FFListView extends ConsumerWidget {
  const _FFListView({
    required this.user,
    required this.type,
  });

  final UserAccount user;
  final FFType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final users = user.userId == ref.read(authProvider).currentUser!.uid
        ? type == FFType.followers
            ? ref.read(followersUserStreamProvider(null)).asData?.value ?? []
            : ref.watch(followingListNotifierProvider).asData?.value ?? []
        : type == FFType.followers
            ? ref.watch(userFollowersProvider(user.userId)).asData?.value ?? []
            : ref.watch(userFollowingsProvider(user.userId)).asData?.value ??
                [];

    return users.isEmpty
        ? _buildEmptyState(textStyle)
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => UserRequestWidget(user: users[index]),
          );
  }

  Widget _buildEmptyState(ThemeTextStyle textStyle) {
    final message =
        type == FFType.followers ? 'フォロワーはいません' : 'フォローしているユーザーはいません';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 48,
            color: ThemeColor.text.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            message,
            style: textStyle.w400(
              fontSize: 14,
              color: ThemeColor.text.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
