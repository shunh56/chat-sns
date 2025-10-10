import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/tiles/user_request_widget.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/providers/follow/follow_list_notifier.dart';
import 'package:app/presentation/providers/follow/followers_list_notifier.dart';
import 'package:app/presentation/providers/follow/user_followings_followers.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';

class UserFFScreen extends ConsumerWidget {
  const UserFFScreen({
    super.key,
    required this.user,
    this.index = 0,
  });

  final UserAccount user;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return DefaultTabController(
      length: 2,
      initialIndex: index,
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

class _FFListView extends HookConsumerWidget {
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
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final ids = user.userId == ref.read(authProvider).currentUser!.uid
        ? type == FFType.followers
            ? ref.watch(followersListNotifierProvider).asData?.value ?? []
            : ref.watch(followingListNotifierProvider).asData?.value ?? []
        : type == FFType.followers
            ? ref.watch(userFollowersProvider(user.userId)).asData?.value ?? []
            : ref.watch(userFollowingsProvider(user.userId)).asData?.value ??
                [];

    if (ids.isEmpty) {
      return _buildEmptyState(textStyle, type);
    }

    return Column(
      children: [
        // 検索バー
        Container(
          padding: const EdgeInsets.all(12),
          color: ThemeColor.background,
          child: TextField(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            decoration: InputDecoration(
              hintText: '検索...',
              hintStyle: const TextStyle(color: ThemeColor.subText),
              prefixIcon: const Icon(Icons.search, color: ThemeColor.subText),
              suffixIcon: searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: ThemeColor.subText),
                      onPressed: () {
                        searchController.clear();
                        searchQuery.value = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: ThemeColor.accent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: const TextStyle(color: ThemeColor.text),
          ),
        ),
        // リスト
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: ids.length,
            itemBuilder: (context, index) => UserWidget(
              userId: ids[index],
              builder: (user) {
                // 検索フィルター
                if (searchQuery.value.isNotEmpty) {
                  final query = searchQuery.value.toLowerCase();
                  if (!user.name.toLowerCase().contains(query) &&
                      !user.username.toLowerCase().contains(query) &&
                      !user.aboutMe.toLowerCase().contains(query)) {
                    return const SizedBox.shrink();
                  }
                }
                return UserRequestWidget(user: user);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeTextStyle textStyle, FFType type) {
    final isFollowers = type == FFType.followers;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: ThemeColor.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFollowers ? Icons.people_outline : Icons.person_add_outlined,
                size: 64,
                color: ThemeColor.subText,
              ),
            ),
            const Gap(24),
            Text(
              isFollowers ? 'フォロワーはまだいません' : 'まだ誰もフォローしていません',
              style: textStyle.w600(
                fontSize: 18,
                color: ThemeColor.text,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            Text(
              isFollowers
                  ? '他のユーザーがあなたをフォローすると\nここに表示されます'
                  : '興味のあるユーザーをフォローして\nつながりましょう',
              style: textStyle.w400(
                fontSize: 14,
                color: ThemeColor.subText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
