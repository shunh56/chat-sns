import 'package:app/domain/repository_interface/follow_repository.dart';
import 'package:app/data/datasource/follow_datasource.dart';
import 'package:app/data/repository/follow_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followRepositoryProvider = Provider<FollowRepository>(
  (ref) => FollowRepositoryImpl(
    ref.watch(followDatasourceProvider),
  ),
);
