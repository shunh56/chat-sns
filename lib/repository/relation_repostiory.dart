import 'package:app/datasource/relation_datasouce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final relationRepositoryProvider = Provider(
  (ref) => RelationRepository(
    ref.watch(relationDatasourceProvider),
  ),
);

class RelationRepository {
  final RelationDatasource _datasource;
  RelationRepository(this._datasource);

  sendRequest(String userId) {
    return _datasource.sendRequest(userId);
  }

  admitRequested(String userId) {
    return _datasource.admitRequested(userId);
  }

  deleteRequest(String userId) {
    return _datasource.deleteRequest(userId);
  }

  deleteRequested(String userId) {
    return _datasource.deleteRequested(userId);
  }
}
