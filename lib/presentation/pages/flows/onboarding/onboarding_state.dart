import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.g.dart';

@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  @override
  OnboardingViewModel build() {
    return const OnboardingViewModel(
      currentPage: 0,
      isCompleted: false,
    );
  }

  void changePage(int index) {
    state = state.copyWith(currentPage: index);
  }

  void nextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = state.copyWith(isCompleted: true);
  }
}

class OnboardingViewModel {
  final int currentPage;
  final bool isCompleted;

  const OnboardingViewModel({
    required this.currentPage,
    required this.isCompleted,
  });

  OnboardingViewModel copyWith({
    int? currentPage,
    bool? isCompleted,
  }) {
    return OnboardingViewModel(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
