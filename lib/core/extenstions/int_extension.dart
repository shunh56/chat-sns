extension IntExtension on int {
  String get autoZero {
    if (this < 10) {
      return "0$this";
    } else {
      return toString();
    }
  }
}
