import 'package:app/data/datasource/image_datasource.dart';
import 'package:app/presentation/providers/provider/images/images.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final imageRepositoryProvider = Provider(
  (ref) => ImageRepository(
    ref.watch(imageDatasourceProvider),
  ),
);

class ImageRepository {
  final ImageDatasource _datasource;

  ImageRepository(this._datasource);

  UserImage addImage(String imageUrl, {String type = "default"}) {
    final id = const Uuid().v4();
    final json = {
      "id": id,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.now(),
    };
    _datasource.addImage(json);
    return UserImage.fromJson(json);
  }

  Future<List<UserImage>> getImages({String? userId}) async {
    final res = await _datasource.getImages(userId: userId);
    return res.docs.map((doc) {
      final json = doc.data();
      json['id'] ??= doc.id;
      return UserImage.fromJson(json);
    }).toList();
  }

  removeImage(String id) {
    return _datasource.removeImage(id);
  }
}
