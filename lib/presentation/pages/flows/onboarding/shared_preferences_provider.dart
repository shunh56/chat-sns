// lib/providers/shared_preferences_provider.dart
import 'package:app/presentation/pages/flows/onboarding/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

// lib/providers/onboarding_provider.dart
@Riverpod(keepAlive: true)
class InitialOnboardingState extends _$InitialOnboardingState {
  @override
  Future<OnboardingViewModel> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final isCompleted = prefs.getBool('onboarding_completed') ?? false;

    return OnboardingViewModel(
      currentPage: 0,
      isCompleted: isCompleted,
    );
  }
}
