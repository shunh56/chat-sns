import 'package:app/core/extenstions/int_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampExtension on Timestamp {
  /// 文字列がメールアドレスであるか判定する
  String get xxAgo {
    Timestamp now = Timestamp.now();
    final diff = now.seconds - seconds;
    if (diff < 60 * 60) {
      return "${diff ~/ 60}分前";
    } else if (diff < 60 * 60 * 24) {
      return "${diff ~/ (60 * 60)}時間前";
    } else {
      return "${diff ~/ (60 * 60 * 24)}日前";
    }
  }

  String get toDateStr {
    final DateTime dateTime = toDate();
    return "${dateTime.year}年${dateTime.month}月${dateTime.day}日";
  }

  String get toTimeStr {
    final DateTime dateTime = toDate();
    return "${dateTime.hour.autoZero}:${dateTime.minute.autoZero}";
  }

  String get xxStatus {
    Timestamp now = Timestamp.now();
    final diff = now.seconds - seconds;
    if (diff < 60 * 60) {
      return "${diff ~/ 60}min";
    } else if (diff < 60 * 60 * 24) {
      return "${diff ~/ (60 * 60)}hrs";
    } else {
      return "${diff ~/ (60 * 60 * 24)}day";
    }
  }
}
