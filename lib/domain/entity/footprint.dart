import 'package:cloud_firestore/cloud_firestore.dart';

class Footprint {
  final String userId;
  int count;
  Timestamp updatedAt;

  Footprint(
      {required this.userId, required this.count, required this.updatedAt});

  factory Footprint.fromJson(Map<String, dynamic> json) {
    return Footprint(
      userId: json["userId"],
      count: json["count"],
      updatedAt: json["updatedAt"],
    );
  }
}
