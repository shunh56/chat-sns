// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'87f7c0811db991852c74d72376df550977c6d6db';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = FutureProviderRef<SharedPreferences>;
String _$initialOnboardingStateHash() =>
    r'dbf3e004a812773582b765ad06724b56f533846b';

/// See also [InitialOnboardingState].
@ProviderFor(InitialOnboardingState)
final initialOnboardingStateProvider =
    AsyncNotifierProvider<InitialOnboardingState, OnboardingViewModel>.internal(
  InitialOnboardingState.new,
  name: r'initialOnboardingStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialOnboardingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InitialOnboardingState = AsyncNotifier<OnboardingViewModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
