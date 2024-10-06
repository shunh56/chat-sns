import 'package:app/repository/image_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageUsecaseProvider = Provider(
  (ref) => ImageUsecase(
    ref.watch(imageRepositoryProvider),
  ),
);

class ImageUsecase {
  final ImageRepository _repository;

  ImageUsecase(this._repository);
  getImages({String? userId}) async {
    return _repository.getImages(userId: userId);
  }
}
