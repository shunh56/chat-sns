import 'package:app/datasource/image_datasource.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageRepositoryProvider = Provider(
  (ref) => ImageRepository(
    ref.watch(imageDatasourceProvider),
  ),
);

class ImageRepository {
  final ImageDatasource _datasource;

  ImageRepository(this._datasource);

  addImage(String imageUrl, {String type = "default"}) {
    return _datasource.addImage(imageUrl);
  }

  Future<List<UserImage>> getImages({String? userId}) async {
    final res = await _datasource.getImages(userId: userId);
    return res.docs.map((doc) => UserImage.fromJson(doc.data())).toList();
  }
}
