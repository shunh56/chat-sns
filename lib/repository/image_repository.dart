import 'package:app/datasource/image_datasource.dart';
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
}
