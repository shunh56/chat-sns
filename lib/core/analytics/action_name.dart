enum ActionName {
  popup_hashtag,
}

extension ActionNameExtension on ActionName {
  String get value {
    switch (this) {
      case ActionName.popup_hashtag:
        return 'popup-hashtag';
    }
  }
}
