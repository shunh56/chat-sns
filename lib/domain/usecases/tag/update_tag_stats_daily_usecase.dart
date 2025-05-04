// lib/domain/usecases/tag/update_tag_stats_daily_usecase.dart
import 'package:app/data/repository/tag_repository_impl.dart';
import 'package:app/domain/repository_interface/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateTagStatsDailyUsecaseProvider =
    Provider<UpdateTagStatsDailyUsecase>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return UpdateTagStatsDailyUsecase(repository);
});

class UpdateTagStatsDailyUsecase {
  final TagRepository repository;

  UpdateTagStatsDailyUsecase(this.repository);

  Future<void> execute() async {
    await repository.updateTagStatsDaily();
  }
}
