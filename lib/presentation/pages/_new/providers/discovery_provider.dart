import 'dart:math';

import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/discovery_mode.dart';

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>(
  (ref) => DiscoveryNotifier(ref),
);

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final Ref ref;
  DiscoveryNotifier(this.ref) : super(DiscoveryState.initial()) {
    _loadUsers();
  }

  void _loadUsers() async {
    final res = await ref.read(allUsersNotifierProvider.notifier).getNewUsers();
    final users = res
        .map(
          (user) => UserModel(
            id: user.userId,
            name: user.name,
            bio: user.aboutMe,
            avatarUrl: user.imageUrl ??
                'https://picsum.photos/seed/${user.userId}80/80',
            interests: user.tags,
            compatibility: 70 + Random().nextInt(30),
            isOnline: user.isOnline,
            type: Random().nextInt(30) % 5 == 1
                ? UserType.primary
                : Random().nextInt(30) % 3 == 1
                    ? UserType.secondary
                    : UserType.tertiary,
          ),
        )
        .toList();

    state = state.copyWith(users: users);
  }

  void changeMode(DiscoveryMode mode) {
    state = state.copyWith(selectedMode: mode);
  }

  void toggleDetailPanel(DetailPanelType? type) {
    state = state.copyWith(activePanel: type);
  }
}

class DiscoveryState {
  final List<UserModel> users;
  final DiscoveryMode selectedMode;
  final DetailPanelType? activePanel;

  const DiscoveryState({
    required this.users,
    required this.selectedMode,
    this.activePanel,
  });

  factory DiscoveryState.initial() {
    return const DiscoveryState(
      users: [],
      selectedMode: DiscoveryMode.compatibility,
      activePanel: null,
    );
  }

  DiscoveryState copyWith({
    List<UserModel>? users,
    DiscoveryMode? selectedMode,
    DetailPanelType? activePanel,
  }) {
    return DiscoveryState(
      users: users ?? this.users,
      selectedMode: selectedMode ?? this.selectedMode,
      activePanel: activePanel,
    );
  }
}

enum DetailPanelType { filter, history, analysis }
