import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String name;
  final String bio;
  final String avatarUrl;
  final List<String> interests;
  final int compatibility;
  final bool isOnline;
  final UserType type;

  const UserModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.interests,
    required this.compatibility,
    required this.isOnline,
    required this.type,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
    int? compatibility,
    bool? isOnline,
    UserType? type,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
      compatibility: compatibility ?? this.compatibility,
      isOnline: isOnline ?? this.isOnline,
      type: type ?? this.type,
    );
  }
}

enum UserType { primary, secondary, tertiary }
