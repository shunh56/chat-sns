import 'package:app/domain/entity/footprint/footprint_statistics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';

/// 足あと統計情報取得のユースケースプロバイダー
final getFootprintStatisticsUseCaseProvider = Provider((ref) {
  return GetFootprintStatisticsUseCase(
    repository: ref.watch(footprintRepositoryImplProvider),
  );
});

/// 足あと統計情報を取得するユースケース
class GetFootprintStatisticsUseCase {
  final IFootprintRepository repository;

  GetFootprintStatisticsUseCase({required this.repository});

  /// 統計情報を取得
  Future<FootprintStatistics> execute() async {
    try {
      return await repository.getStatistics();
    } catch (e) {
      // エラー時は空の統計情報を返す
      return FootprintStatistics.empty();
    }
  }

  /// リアルタイムで統計情報を監視
  Stream<FootprintStatistics> watch() {
    return Stream.periodic(const Duration(minutes: 1), (_) async {
      return await execute();
    }).asyncMap((event) => event);
  }
}
