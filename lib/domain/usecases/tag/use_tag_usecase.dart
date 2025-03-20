// lib/domain/usecases/tag/use_tag_usecase.dart

import 'package:app/data/providers/tag_providers.dart';
import 'package:app/domain/repositories/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final useTagUsecaseProvider = Provider(
  (ref) => UseTagUsecase(
    ref.watch(tagRepositoryProvider),
  ),
);

class UseTagUsecase {
  final TagRepository _tagRepository;

  UseTagUsecase(this._tagRepository);

  // タグの使用回数を増加
  Future<void> incrementTagUsage(String tagId) async {
    await _tagRepository.incrementTagUsage(tagId);
  }
}