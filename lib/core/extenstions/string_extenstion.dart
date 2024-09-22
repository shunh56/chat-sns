extension StringExtension on String {
  /// 文字列がメールアドレスであるか判定する
  bool get isEmail {
    return RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+(\.?[a-zA-Z]+)$').hasMatch(this);
  }

  bool get isUsername {
    return RegExp(r"^(?=.{0,16}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(this);
  }
}
