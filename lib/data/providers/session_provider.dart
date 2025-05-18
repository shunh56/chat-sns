import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/plugins/device_info.dart';
import 'package:app/data/datasource/session_datasource.dart';
import 'package:app/data/repository/session_repository_impl.dart';
import 'package:app/domain/repository_interface/session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(
    ref.watch(authProvider),
    ref.watch(sessionDatasourceProvider),
    ref.watch(deviceInfoDatasourceProvider),
  );
});
