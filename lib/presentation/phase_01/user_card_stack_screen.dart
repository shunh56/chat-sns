// pubspec.yaml に追加
// card_swiper: ^3.0.1
// shimmer: ^3.0.0

import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

// Providerの定義
final userCardStackProvider =
    StateNotifierProvider<UserCardStackNotifier, UserCardStackState>((ref) {
  return UserCardStackNotifier();
});

class UserCardStackState {
  final int currentIndex;
  final bool isLoading;

  UserCardStackState({
    this.currentIndex = 0,
    this.isLoading = true,
  });

  UserCardStackState copyWith({
    int? currentIndex,
    bool? isLoading,
  }) {
    return UserCardStackState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserCardStackNotifier extends StateNotifier<UserCardStackState> {
  UserCardStackNotifier() : super(UserCardStackState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

class UserCardStackScreen extends ConsumerStatefulWidget {
  const UserCardStackScreen({super.key, required this.users});
  final List<UserAccount> users;

  @override
  ConsumerState<UserCardStackScreen> createState() =>
      _UserCardStackScreenState();
}

class _UserCardStackScreenState extends ConsumerState<UserCardStackScreen> {
  late SwiperController _controller;
  final Set<String> seenUserIds = {};

  @override
  void initState() {
    super.initState();
    _controller = SwiperController();
    // 画像のプリロード完了を模擬
    Future.delayed(const Duration(milliseconds: 800), () {
      ref.read(userCardStackProvider.notifier).setLoading(false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCardStackProvider);
    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: state.isLoading
          ? _buildLoadingState()
          : Stack(
              children: [
                // カードスワイパー
                Swiper(
                  controller: _controller,
                  itemCount: 10000,
                  itemBuilder: (context, index) {
                    final filteredUsers = widget.users
                        .where((user) => !seenUserIds.contains(user.userId))
                        .toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Text(
                          "すべてのカードをスワイプし終わりました",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      );
                    }

                    final userIndex = index % filteredUsers.length;
                    return _buildCard(filteredUsers[userIndex]);
                  },
                  itemWidth: MediaQuery.of(context).size.width * 0.9,
                  itemHeight: MediaQuery.of(context).size.height * 0.66,
                  layout: SwiperLayout.STACK,
                  axisDirection: AxisDirection.right,
                  onIndexChanged: (index) {
                    final filteredUsers = widget.users
                        .where((user) => !seenUserIds.contains(user.userId))
                        .toList();
                    if (filteredUsers.isNotEmpty) {
                      final userIndex = index % filteredUsers.length;
                      seenUserIds.add(filteredUsers[userIndex].userId);
                      ref
                            .read(userCardStackProvider.notifier)
                            .setIndex(index);
                    }
                  },
                ),

                // アクションボタン
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          onTap: () => _controller.next(),
                          icon: Icons.close_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4B6B), Color(0xFFFF6B8B)],
                          ),
                          label: 'スキップ',
                        ),
                        _buildActionButton(
                          onTap: () => _controller.next(),
                          icon: Icons.person_add_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          ),
                          label: 'フォロー',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: ThemeColor.surface,
      highlightColor: ThemeColor.accent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(UserAccount user) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Expanded(
              child: CachedImage.usersCard(
                user.imageUrl ?? '',
                //fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    user.aboutMe,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(16),
                  _buildUserStats(user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*idget _buildCard(UserAccount user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景画像
            CachedImage.userCard(
              user.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
            
            // グラデーションオーバーレイ
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            
            // ユーザー情報
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      user.aboutMe,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(16),
                    _buildUserStats(user),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } */
  Widget _buildUserStats(UserAccount user) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people_outline_rounded,
          value: "123", // "${user.followerCount}",
          label: "フォロワー",
        ),
        const Gap(24),
        _buildStatItem(
          icon: Icons.favorite_border_rounded,
          value: "12", //${user.likeCount}",
          label: "いいね",
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white70,
        ),
        const Gap(6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Gradient gradient,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: TextStyle(
            color: gradient.colors.first,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
