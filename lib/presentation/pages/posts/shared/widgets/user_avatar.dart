// lib/presentation/pages/posts/shared/widgets/user_avatar.dart
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/core/utils/theme.dart';
import 'package:flutter/material.dart';

/// 統一されたユーザーアバター表示コンポーネント
/// UserIcon, UserIconPostIcon, UserIconSmallIcon等の機能を統合
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40.0,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.showOnlineStatus = false,
    this.heroTag,
    this.isCircle = true,
    this.borderRadius,
  });

  final UserAccount user;
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showOnlineStatus;
  final String? heroTag;
  final bool isCircle;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget avatar = _buildAvatarContent();

    // ヒーロータグが指定されている場合
    if (heroTag != null) {
      avatar = Hero(
        tag: heroTag!,
        child: avatar,
      );
    }

    // タップ処理
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    // オンラインステータス表示
    if (showOnlineStatus) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildOnlineIndicator(),
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildAvatarContent() {
    final effectiveBorderRadius = isCircle ? size / 2 : (borderRadius ?? 8.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? ThemeColor.accent.withOpacity(0.3),
                width: borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: (borderColor ?? ThemeColor.accent).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: _buildAvatarImage(),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (user.imageUrl != null) {
      return CachedImage.userIcon(user.imageUrl, user.name, size / 2);
    }

    return Container(
      color: ThemeColor.surface,
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: ThemeColor.icon.withOpacity(0.6),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Container(
      width: size * 0.25,
      height: size * 0.25,
      decoration: BoxDecoration(
        color: user.isOnline ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}

/// プリセットサイズのファクトリーコンストラクタ
extension UserAvatarSizes on UserAvatar {
  /// 小さいアバター (24px)
  static UserAvatar small({
    required UserAccount user,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return UserAvatar(
      user: user,
      size: 24,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  /// 中サイズアバター (40px) - デフォルト
  static UserAvatar medium({
    required UserAccount user,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return UserAvatar(
      user: user,
      size: 40,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  /// 大きいアバター (60px)
  static UserAvatar large({
    required UserAccount user,
    VoidCallback? onTap,
    bool showBorder = false,
  }) {
    return UserAvatar(
      user: user,
      size: 60,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  /// 投稿用アバター
  static UserAvatar forPost({
    required UserAccount user,
    VoidCallback? onTap,
  }) {
    return UserAvatar(
      user: user,
      size: 32,
      onTap: onTap,
      showBorder: true,
      borderColor: ThemeColor.accent.withOpacity(0.2),
      borderWidth: 1.5,
    );
  }
}
