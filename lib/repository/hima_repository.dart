import 'package:app/datasource/hima_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final himaUsersRepositoryProvider = Provider(
  (ref) => HimaUsersRepository(
    ref.watch(himaUsersDatasourceProvider),
  ),
);

class HimaUsersRepository {
  final HimaUsersDatasource _datasource;

  HimaUsersRepository(this._datasource);

  Future<void> addMeToList() async {
    return _datasource.addMeToList();
  }

  Future<List<String>> getHimaUsers() async {
    final res = await _datasource.getHimaUsers();
    return res.docs.map((doc) => doc.id).toList();
  }
}
