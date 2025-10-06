import 'package:app/domain/entity/footprint/footprint.dart';
import 'package:app/domain/usecases/footprint/get_visitors_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 訪問者リストのステート（ストリーム）
final visitorsProvider = StreamProvider.autoDispose<List<Footprint>>((ref) {
  final usecase = ref.watch(getVisitorsUsecaseProvider);
  return usecase.getProfileVisitors();
});
