/*import 'package:app/data/repository/footprint_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateNotifySettingUsecaseProvider = Provider(
  (ref) => UpdateNotifySettingUsecase(
    ref.watch(footprintRepositoryProvider),
  ),
);

class UpdateNotifySettingUsecase {
  final FootprintRepository _repository;

  UpdateNotifySettingUsecase(this._repository);

  // 足あとの通知設定を更新
  Future<void> setFootprintNotifications(bool notify) {
    return _repository.updateNotifyOnNew(notify);
  }
} */
