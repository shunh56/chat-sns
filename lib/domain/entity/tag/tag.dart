// lib/domain/entities/tag/tag.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final int usageCount;
  final bool isActive;
  final Timestamp createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.usageCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  // copyWith メソッド
  Tag copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? usageCount,
    bool? isActive,
    Timestamp? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // fromJson メソッド
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : Timestamp.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }

  // toJson メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  // Firestore 変換メソッド
  factory Tag.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tag(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      category: data['category'],
      usageCount: data['usageCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  // toString メソッド
  @override
  String toString() =>
      'Tag(id: $id, name: $name, category: $category, usageCount: $usageCount)';
}
