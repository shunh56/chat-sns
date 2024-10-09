import 'package:app/presentation/providers/state/report_form.dart';
import 'package:app/repository/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportUsecaseProvider = Provider(
  (ref) => ReportUsecase(
    ref.watch(reportRepositoryProvider),
  ),
);

class ReportUsecase {
  final ReportRepository _repository;

  ReportUsecase(this._repository);

  reportUser(ReportForm form) {
    return _repository.reportUser(form.toJson());
  }
}
