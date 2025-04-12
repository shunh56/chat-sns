import 'package:app/domain/repositories/follow_repository.dart';
import 'package:app/infrastructure/datasource/follow_datasource.dart';
import 'package:app/infrastructure/repository/follow_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followRepositoryProvider = Provider<FollowRepository>(
  (ref) => FollowRepositoryImpl(
    ref.watch(followDatasourceProvider),
  ),
);
