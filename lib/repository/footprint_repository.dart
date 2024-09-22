import 'package:app/datasource/footprint_datasource.dart';
import 'package:app/domain/entity/footprint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footprintRepositoryProvider = Provider(
  (ref) => FootprintRepository(
    ref.watch(footprintDatasourceProvider),
  ),
);

class FootprintRepository {
  final FootprintDatasource _datasource;

  FootprintRepository(this._datasource);

  Future<List<Footprint>> getFootprints() async {
    final res = await _datasource.fetchFootprints();
    return res.docs.map((doc) => Footprint.fromJson(doc.data())).toList();
  }

  Future<List<Footprint>> getFootprinteds() async {
    final res = await _datasource.fetchFootprinteds();
    return res.docs.map((doc) => Footprint.fromJson(doc.data())).toList();
  }

  addFootprint(String userId) {
    return _datasource.addFootprint(userId);
  }

  deleteFootprint(String userId) {
    return _datasource.deleteFootprint(userId);
  }
}
