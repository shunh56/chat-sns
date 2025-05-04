// lib/domain/entities/tag_stat.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TagStat {
  final String id;
  final String text;
  final int count;
  final Timestamp lastUpdated;
  
  TagStat({
    required this.id,
    required this.text,
    required this.count,
    required this.lastUpdated,
  });
}

// lib/domain/entities/tag_user.dart
class TagUser {
  final String userId;
  final Timestamp createdAt;
  final String status; // 'active', 'removed'
  final Timestamp? updatedAt;
  
  TagUser({
    required this.userId,
    required this.createdAt,
    required this.status,
    this.updatedAt,
  });
}

// lib/domain/entities/tag_history.dart
class TagHistory {
  final String tagId;
  final int count;
  final Timestamp timestamp;
  
  TagHistory({
    required this.tagId,
    required this.count,
    required this.timestamp,
  });
}