import 'package:cloud_firestore/cloud_firestore.dart';

class Relation {
  final String userId;
  final Timestamp createdAt;
  final Timestamp lastOpenedAt;
  final int count;

  const Relation({
    required this.userId,
    required this.createdAt,
    required this.lastOpenedAt,
    required this.count,
  });

  // Create from JSON
  factory Relation.fromJson(Map<String, dynamic> json) {
    return Relation(
      userId: json['userId'] as String? ?? '',
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      lastOpenedAt: json['lastOpenedAt'] as Timestamp? ?? Timestamp.now(),
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'createdAt': createdAt,
      'lastOpenedAt': lastOpenedAt,
      'count': count,
    };
  }

  Relation copyWith({
    String? userId,
    Timestamp? createdAt,
    Timestamp? lastOpenedAt,
    int? count,
  }) {
    return Relation(
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      count: count ?? this.count,
    );
  }

  factory Relation.create(String userId) {
    final now = Timestamp.now();
    return Relation(
      userId: userId,
      createdAt: now,
      lastOpenedAt: now,
      count: 0,
    );
  }

  // Factory method for incrementing count
  Relation incrementCount() {
    return copyWith(
      lastOpenedAt: Timestamp.now(),
      count: count + 1,
    );
  }

  @override
  String toString() {
    return 'Relation{userId: $userId, createdAt: $createdAt, lastOpenedAt: $lastOpenedAt, count: $count}';
  }
}
