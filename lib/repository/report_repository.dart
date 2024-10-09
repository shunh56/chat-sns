import 'package:app/datasource/report_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider(
  (ref) => ReportRepository(
    ref.watch(reportDatasourceProvider),
  ),
);

class ReportRepository {
  final ReportDatasource _datasource;
  ReportRepository(this._datasource);

  reportUser(Map<String, dynamic> json) {
    return _datasource.reportUser(json);
  }
}
