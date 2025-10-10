import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Timestamp用のJsonConverter
class TimestampConverter implements JsonConverter<Timestamp, dynamic> {
  const TimestampConverter();

  @override
  Timestamp fromJson(dynamic json) {
    if (json is Timestamp) {
      return json;
    } else if (json is Map<String, dynamic>) {
      // Firestore形式: { "_seconds": 1234567890, "_nanoseconds": 0 }
      return Timestamp(json['_seconds'] as int, json['_nanoseconds'] as int);
    } else if (json is int) {
      // Unix timestamp (秒)
      return Timestamp.fromMillisecondsSinceEpoch(json * 1000);
    } else {
      throw ArgumentError('Invalid Timestamp format: $json');
    }
  }

  @override
  dynamic toJson(Timestamp timestamp) => timestamp;
}
