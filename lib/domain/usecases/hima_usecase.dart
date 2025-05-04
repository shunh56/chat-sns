import 'package:app/data/repository/hima_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final himaUsersUsecaseProvider = Provider(
  (ref) => HimaUsersUsecase(
    ref.watch(himaUsersRepositoryProvider),
  ),
);

class HimaUsersUsecase {
  final HimaUsersRepository _repository;
  HimaUsersUsecase(this._repository);
  Future<void> addMeToList() async {
    return _repository.addMeToList();
  }

  Future<List<String>> getHimaUsers() async {
    return _repository.getHimaUsers();
  }
}
