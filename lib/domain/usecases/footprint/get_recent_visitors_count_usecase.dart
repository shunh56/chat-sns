import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/data/repository/footprint_repository_impl.dart';
import 'package:app/domain/repository/footprint_repository_interface.dart';

/// 過去24時間以内の足あと件数取得のユースケースプロバイダー
final getRecentVisitorsCountUseCaseProvider = Provider((ref) {
  return GetRecentVisitorsCountUseCase(
    repository: ref.watch(footprintRepositoryImplProvider),
  );
});

/// 過去24時間以内の足あと件数を取得するユースケース
class GetRecentVisitorsCountUseCase {
  final IFootprintRepository repository;

  GetRecentVisitorsCountUseCase({required this.repository});

  /// 過去24時間以内の足あと件数をストリームで取得
  Stream<int> execute() {
    return repository
        .getRecentVisitorsStream()
        .map((visitors) => visitors.length);
  }

  /// 過去24時間以内の未読足あと件数をストリームで取得
  Stream<int> executeUnseen() {
    return repository.getRecentVisitorsStream().map((visitors) {
      return visitors.where((v) => !v.isSeen).length;
    });
  }

  /// 過去24時間以内の足あと件数を即座に取得
  Future<int> getCount() async {
    final visitors = await repository.getRecentVisitorsStream().first;
    return visitors.length;
  }

  /// 過去24時間以内の未読足あと件数を即座に取得
  Future<int> getUnseenCount() async {
    return repository.getRecentUnseenCount();
  }
}
