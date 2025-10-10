/// メインページのタブインデックス定数
class MainPageTabIndex {
  MainPageTabIndex._();

  /// ホーム（検索）タブ
  static const int home = 0;

  /// タイムラインタブ
  static const int timeline = 1;

  /// チャット（ソーシャル）タブ
  static const int chat = 2;

  /// プロフィールタブ
  static const int profile = 3;

  /// Tempoタブ（将来的な使用）
  static const int tempo = 4;

  /// 利用可能なタブの総数
  static const int totalCount = 4;

  /// 有効なタブインデックスかチェック
  static bool isValidIndex(int index) {
    return index >= 0 && index < totalCount;
  }
}

/// ナビゲーションアイテムの設定
class NavigationItemConfig {
  final String label;
  final String iconPath;
  final bool hasNotification;

  const NavigationItemConfig({
    required this.label,
    required this.iconPath,
    this.hasNotification = false,
  });
}

/// ナビゲーションアイテムの定数
class NavigationItems {
  NavigationItems._();

  static const Map<int, NavigationItemConfig> items = {
    MainPageTabIndex.home: NavigationItemConfig(
      label: "ホーム",
      iconPath: "assets/images/icons/home.svg",
    ),
    MainPageTabIndex.timeline: NavigationItemConfig(
      label: "タイムライン",
      iconPath: "assets/images/icons/send.svg",
    ),
    MainPageTabIndex.chat: NavigationItemConfig(
      label: "ソーシャル",
      iconPath: "assets/images/icons/chat.svg",
      hasNotification: true,
    ),
    MainPageTabIndex.profile: NavigationItemConfig(
      label: "プロフィール",
      iconPath: "assets/images/icons/profile.svg",
    ),
  };
}
