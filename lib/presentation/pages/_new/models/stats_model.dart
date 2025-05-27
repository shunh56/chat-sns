import 'package:flutter/foundation.dart';

@immutable
class StatsModel {
  final int discoveredCount;
  final int matchPercentage;
  final int mutualLikes;

  const StatsModel({
    required this.discoveredCount,
    required this.matchPercentage,
    required this.mutualLikes,
  });

  StatsModel copyWith({
    int? discoveredCount,
    int? matchPercentage,
    int? mutualLikes,
  }) {
    return StatsModel(
      discoveredCount: discoveredCount ?? this.discoveredCount,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      mutualLikes: mutualLikes ?? this.mutualLikes,
    );
  }
}
