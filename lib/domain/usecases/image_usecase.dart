import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:app/data/repository/image_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageUsecaseProvider = Provider(
  (ref) => ImageUsecase(
    ref.watch(imageRepositoryProvider),
  ),
);

class ImageUsecase {
  final ImageRepository _repository;

  ImageUsecase(this._repository);

  List<UserImage> addImages(List<String> imageUrls){
    List<UserImage> images = [];
    for(String imageUrl in  imageUrls){
       images.add(_repository.addImage(imageUrl));
    }
    return images;
  }
  getImages({String? userId}) async {
    return _repository.getImages(userId: userId);
  }

  removeImage(UserImage image) {
    return _repository.removeImage(image.id);
  }
}
