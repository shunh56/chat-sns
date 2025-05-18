enum ScreenName {
  homePage,
  timelinePage,
  chatPage,
  profilePage,

  //
  footprintPage,
}

extension ScreenNameExtension on ScreenName {
  String get value {
    switch (this) {
      case ScreenName.homePage:
        return 'Home-Page';
      case ScreenName.timelinePage:
        return 'Timeline-Page';
      case ScreenName.chatPage:
        return 'Chat-Page';
      case ScreenName.profilePage:
        return 'Profile-Page';
      case ScreenName.footprintPage:
        return 'Footprint-Screen';
    }
  }
}
