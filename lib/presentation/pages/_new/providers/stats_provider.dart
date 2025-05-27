import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats_model.dart';
import 'dart:async';
import 'dart:math';

class StatsNotifier extends StateNotifier<StatsModel> {
  StatsNotifier() : super(const StatsModel(
    discoveredCount: 24,
    matchPercentage: 87,
    mutualLikes: 8,
  )) {
    _startPeriodicUpdate();
  }
  
  Timer? _timer;
  
  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _updateStats();
    });
  }
  
  void _updateStats() {
    final random = Random();
    state = state.copyWith(
      matchPercentage: (state.matchPercentage + random.nextInt(3) - 1)
          .clamp(75, 95),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, StatsModel>(
  (ref) => StatsNotifier(),
);