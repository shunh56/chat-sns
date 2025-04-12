// 改善版 - 独立した状態管理を持つカードスタックUI
import 'dart:math';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/new/providers/follow/follow_list_notifier.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

// ----- 状態管理の改善 -----

// プロバイダーファミリーを使用して、各インスタンスごとに独立した状態を持つよう修正
final userCardStackProvider = StateNotifierProviderFamily<UserCardStackNotifier,
    UserCardStackState, String>(
  (ref, id) => UserCardStackNotifier(),
);

class UserCardStackState {
  final int currentIndex;
  final bool isLoading;
  final bool isCompleted;
  final int followCount;

  UserCardStackState({
    this.currentIndex = 0,
    this.isLoading = true,
    this.isCompleted = false,
    this.followCount = 0,
  });

  UserCardStackState copyWith({
    int? currentIndex,
    bool? isLoading,
    bool? isCompleted,
    int? followCount,
  }) {
    return UserCardStackState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      followCount: followCount ?? this.followCount,
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

  void setCompleted(bool isCompleted) {
    state = state.copyWith(isCompleted: isCompleted);
  }

  void incrementFollow() {
    state = state.copyWith(followCount: state.followCount + 1);
  }

  void resetFollowCount() {
    state = state.copyWith(followCount: 0);
  }

  // 状態を完全にリセットするメソッドを追加
  void resetState() {
    state = UserCardStackState();
  }
}

class UserCardStackScreen extends ConsumerStatefulWidget {
  // プロバイダーIDとユーザータイプを追加して状態を区別
  const UserCardStackScreen({
    super.key,
    required this.users,
    required this.userGroupId, // 例："new_users", "online_users" など
    this.userGroupTitle = "",
  });

  final List<UserAccount> users;
  final String userGroupId;
  final String userGroupTitle;

  @override
  ConsumerState<UserCardStackScreen> createState() =>
      _UserCardStackScreenState();
}

enum CardStatus { idle, swiping, like, nope }

class _UserCardStackScreenState extends ConsumerState<UserCardStackScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  List<UserAccount> _remainingUsers = [];

  // プロバイダーIDを取得するためのgetter
  String get _providerId => widget.userGroupId;

  // スワイプアニメーション用の変数
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;
  double _angle = 0;
  CardStatus _status = CardStatus.idle;

  // スワイプ判定の閾値
  final double _swipeThreshold = 0.3;

  // スワイプ後のアニメーション用コントローラー
  late AnimationController _animationController;

  // カードアニメーション用の変数を追加
  final bool _isNewCardAnimating = false;
  bool _isProcessingSwipe = false; // スワイプ処理中フラグ
  final _cardAnimationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // 最初はすべてのユーザーを表示
    _remainingUsers = List.from(widget.users);

    // アニメーションコントローラー初期化
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // アニメーション完了時にスワイプ処理を実行
        _handleSwipeComplete();

        // アニメーション変数をリセット（次のアニメーションのため）
        setState(() {
          _position = Offset.zero;
          _angle = 0;
          _status = CardStatus.idle;
        });
        _animationController.reset();
      }
    });

    // 画像のプリロード完了を模擬
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(userCardStackProvider(_providerId).notifier).setLoading(false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // スワイプ完了処理（カードアニメーション完了後に呼ばれる）
  void _handleSwipeComplete() async {
    if (_remainingUsers.isEmpty || _isProcessingSwipe) return;

    setState(() {
      _isProcessingSwipe = true;
    });

    final user = _remainingUsers.first;
    final wasLiked = _status == CardStatus.like;
    ScaffoldMessenger.of(context).clearSnackBars();

    // ステータスをリセットする前に処理
    if (wasLiked) {
      // フォロー時のフィードバック
      final notifier = ref.read(followingListNotifierProvider.notifier);
      final isFollowing = notifier.isFollowing(user.userId);
      if (!isFollowing) {
        try {
          await notifier.followUser(user);
          ref
              .read(userCardStackProvider(_providerId).notifier)
              .incrementFollow();
          showMessage("${user.name}をフォローしました！");
        } catch (e) {
          showErrorSnackbar(error: e);
        }
      } else {
        showMessage("既に${user.name}をフォローしています。");
      }
    }

    // 次のカードがアニメーションで前に移動する時間を確保
    await Future.delayed(const Duration(milliseconds: 250));

    // カードを削除
    setState(() {
      _remainingUsers.removeAt(0);
      _isProcessingSwipe = false;
    });

    // すべてのカードをスワイプし終わった場合
    if (_remainingUsers.isEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref
              .read(userCardStackProvider(_providerId).notifier)
              .setCompleted(true);
          _confettiController.play();
        }
      });
    }
  }

  // 手動スワイプ開始
  void _startSwipe(int direction) {
    if (_remainingUsers.isEmpty || _status != CardStatus.idle) return;

    _status = direction > 0 ? CardStatus.like : CardStatus.nope;

    // 画面外へのスワイプアニメーション
    final targetX =
        direction > 0 ? _screenSize.width + 200.0 : -_screenSize.width - 200.0;

    _animationController.addListener(() {
      setState(() {
        _position = Offset(targetX * _animationController.value, _position.dy);
        _angle = direction * 0.5 * _animationController.value;
      });
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCardStackProvider(_providerId));
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.userGroupTitle.isNotEmpty
            ? Text(widget.userGroupTitle)
            : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // コンフェッティアニメーション
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // 下方向
              maxBlastForce: 7, // より力強く
              minBlastForce: 3,
              emissionFrequency: 0.5, // より頻繁に
              numberOfParticles: 10, // パーティクル数増加
              gravity: 0.2, // 重力を少し強く
              particleDrag: 0.05, // 空気抵抗を追加
              minimumSize: const Size(10, 10), // パーティクルサイズ最小
              maximumSize: const Size(15, 15), // パーティクルサイズ最大
              shouldLoop: false, // ループさせない
              colors: const [
                Colors.pink,
                Colors.purple,
                Colors.blue,
                Colors.cyan,
                Colors.teal,
                Colors.amber,
                Colors.orange,
              ],
            ),
          ),

          // メインコンテンツ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: state.isLoading
                ? _buildLoadingState()
                : state.isCompleted
                    ? _buildCompletionScreen(state.followCount)
                    : _buildCardStack(),
          ),
        ],
      ),
    );
  }

  // パンジェスチャーが更新されたときの処理を修正
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;

      // 角度の計算（ドラッグの横移動に応じて回転）
      final newAngle = 45.0 * (_position.dx / _screenSize.width);
      _angle = newAngle.clamp(-45.0, 45.0) * pi / 180;

      // ドラッグ中はまだ判定を確定せず、ドラッグの方向に応じたインジケーションのみ表示
      if (_position.dx > _screenSize.width * 0.1) {
        _status = CardStatus.like; // 右方向への十分な移動でフォローの可能性を示唆
      } else if (_position.dx < -_screenSize.width * 0.1) {
        _status = CardStatus.nope; // 左方向への十分な移動でスキップの可能性を示唆
      } else {
        _status = CardStatus.idle; // わずかな移動では判定なし
      }

      // カードの動きに応じて次のカードのスケールとオパシティを調整
      // アニメーションウィジェットで使用するため不要になりました
      // _nextCardScale = 0.9 + (min(_position.dx.abs(), 100) / 100) * 0.05;
      // _nextCardOpacity = 0.6 + (min(_position.dx.abs(), 100) / 100) * 0.3;
    });
  }

// パンジェスチャーが終了したときの処理を修正
  void _onPanEnd(DragEndDetails details) {
    final threshold = _screenSize.width * _swipeThreshold;

    // 閾値を超えたかチェック - 実際の判定はここで確定する
    if (_position.dx.abs() > threshold) {
      // スワイプが成立
      final isRight = _position.dx > 0;
      final targetX =
          isRight ? _screenSize.width + 200.0 : -_screenSize.width - 200.0;

      _animationController.addListener(() {
        setState(() {
          _position = Offset(
              _position.dx +
                  (targetX - _position.dx) * _animationController.value,
              _position.dy);
        });
      });

      // 判定を確定
      _status = isRight ? CardStatus.like : CardStatus.nope;
      _animationController.forward();
    } else {
      // スワイプが不成立 - 元の位置に戻り、判定もリセット
      _animationController.addListener(() {
        setState(() {
          _position = Offset(_position.dx * (1 - _animationController.value),
              _position.dy * (1 - _animationController.value));
          _angle = _angle * (1 - _animationController.value);
        });
      });

      // 判定をリセット
      _status = CardStatus.idle;
      _animationController.forward();
    }
  }

  Widget _buildCardStack() {
    if (_remainingUsers.isEmpty) {
      return Container(); // すべてのカードを見終わった場合は空のコンテナ
    }

    return Stack(
      children: [
        // カードセクション
        Positioned.fill(
          top: 80,
          bottom: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景カード（次のカード）
              if (_remainingUsers.length > 1)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                      begin: 0.9, end: _status != CardStatus.idle ? 0.95 : 0.9),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                            begin: 0.6,
                            end: _status != CardStatus.idle ? 0.9 : 0.6),
                        builder: (context, opacity, _) {
                          return Opacity(
                            opacity: opacity,
                            child: _buildCard(_remainingUsers[1],
                                isBackground: true),
                          );
                        },
                      ),
                    );
                  },
                ),

              // アニメーションスペースホルダー（メイン処理中に表示）
              if (_isProcessingSwipe && _remainingUsers.length > 1)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.95, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0.9, end: 1.0),
                        builder: (context, opacity, _) {
                          return Opacity(
                            opacity: opacity,
                            child: _buildCard(_remainingUsers[1],
                                isBackground: false),
                          );
                        },
                      ),
                    );
                  },
                ),

              // メインカード - ドラッグ可能
              if (!_isProcessingSwipe)
                Positioned(
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: _position,
                      child: Transform.rotate(
                        angle: _angle,
                        child: Stack(
                          children: [
                            _buildCard(_remainingUsers[0]),

                            // スワイプフィードバック
                            if (_status != CardStatus.idle)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                top: 40,
                                right: _status == CardStatus.like ? 20 : null,
                                left: _status == CardStatus.nope ? 20 : null,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: 1.0,
                                  curve: Curves.easeInOut,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween<double>(begin: 0.8, end: 1.0),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: _buildSwipeIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // アクションボタン
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedActionButton(
                    onTap: () => _startSwipe(-1),
                    icon: Icons.close_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4B6B), Color(0xFFFF6B8B)],
                    ),
                    label: 'スキップ',
                  ),
                  const SizedBox(width: 16),
                  AnimatedActionButton(
                    onTap: () => _startSwipe(1),
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
        ),
      ],
    );
  }

  Widget _buildSwipeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _status == CardStatus.like
              ? const Color(0xFF4ADE80).withOpacity(0.8)
              : const Color(0xFFF87171).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _status == CardStatus.like
                ? const Color(0xFF4ADE80).withOpacity(0.3)
                : const Color(0xFFF87171).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _status == CardStatus.like
                ? Icons.add_circle_outline_rounded
                : Icons.remove_circle_outline_rounded,
            color: _status == CardStatus.like
                ? const Color(0xFF4ADE80)
                : const Color(0xFFF87171),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _status == CardStatus.like ? 'FOLLOW' : 'SKIP',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(int followCount) {
    return Container(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeColor.accent.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Gap(24),
              const Text(
                'スワイプ完了',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Gap(16),
              Container(
                height: 1,
                width: 40,
                color: Colors.white.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              const Gap(16),
              Text(
                followCount > 0
                    ? '$followCount人のユーザーをフォローしました'
                    : '全てのユーザーを見終わりました',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ホームへ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildCard(UserAccount user, {bool isBackground = false}) {
    return AnimatedOpacity(
      duration: _cardAnimationDuration,
      opacity: _isNewCardAnimating && !isBackground ? 0.95 : 1.0,
      child: AnimatedScale(
        duration: _cardAnimationDuration,
        scale: _isNewCardAnimating && !isBackground ? 0.95 : 1.0,
        child: GestureDetector(
          onTap: () {
            ref.read(navigationRouterProvider(context)).goToProfile(user);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.66,
            decoration: BoxDecoration(
              color: ThemeColor.accent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isBackground
                  ? []
                  : [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CachedImage.usersCard(
                      user.imageUrl ?? '',
                      //fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
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

  Widget _buildUserStats(UserAccount user) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people_outline_rounded,
          value: "123", // "${user.followerCount}",
          label: "フォロワー",
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

class AnimatedActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Gradient gradient;
  final String label;

  const AnimatedActionButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.gradient,
    required this.label,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // タップ時のスケールアニメーション
    _controller.forward(from: 0.0);

    // 触覚フィードバック
    HapticFeedback.mediumImpact();

    // 短い遅延後にアクションを実行
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        Text(
          widget.label,
          style: TextStyle(
            color: widget.gradient.colors.first,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
