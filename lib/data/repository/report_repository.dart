import 'package:app/data/datasource/report_datasource.dart';
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

  reportBug(Map<String, dynamic> json) {
    return _datasource.reportBug(json);
  }

  reportForm(Map<String, dynamic> json) {
    return _datasource.reportForm(json);
  }
}
