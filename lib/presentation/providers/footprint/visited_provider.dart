import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visited_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 自分が訪問したユーザー一覧（ストリーム）
final visitedProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitedUsecaseProvider);
  return usecase.getVisitedProfiles();
});
