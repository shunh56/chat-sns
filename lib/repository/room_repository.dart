import 'package:app/datasource/room_datasource.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final roomRepositoryProvider = Provider(
  (ref) => RoomRepository(
    ref.watch(roomDatasourceProvider),
  ),
);

class RoomRepository {
  final RoomDatasource _datasource;
  RoomRepository(this._datasource);

  sendMessage(String text) {
    return _datasource.sendMessage(text);
  }

  sendImages(List<String> imageUrls, List<double> aspectRatios) {
    return _datasource.sendImages(imageUrls, aspectRatios);
  }
}
