import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseRemoteConfigProvider =
    Provider<FirebaseRemoteConfig>((ref) => FirebaseRemoteConfig.instance);

final remoteConfigProvider = FutureProvider<void>((ref) async {
  final remoteConfig = ref.read(firebaseRemoteConfigProvider);
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1)));
  await remoteConfig.fetchAndActivate();
});
