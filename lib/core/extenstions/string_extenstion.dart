extension StringExtension on String {
  /// 文字列がメールアドレスであるか判定する
  bool get isEmail {
    return RegExp(r'^.+@[a-zA-Z]+\.[a-zA-Z]+(\.?[a-zA-Z]+)$').hasMatch(this);
  }

  bool get isUsername {
    return RegExp(r"^(?=.{6,16}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")
        .hasMatch(this);
  }

  String? get usernameError {
    if (isEmpty) return null;
    if (length < 6 || length > 16) return "ユーザー名は6～16文字で入力してください。";
    if (!isUsername) return "そのユーザー名は使用できません。";
    return null;
  }
}
