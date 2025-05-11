import 'dart:io';

import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/repository/room_repository.dart';
import 'package:app/domain/usecases/image_uploader_usecase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final roomUsecaseProvider = Provider(
  (ref) => RoomUsecase(
    ref,
    ref.watch(roomRepositoryProvider),
  ),
);

class RoomUsecase {
  final Ref _ref;
  final RoomRepository _repository;

  RoomUsecase(this._ref, this._repository);

  

  sendMessage(String text) {
    return _repository.sendMessage(text);
  }

  sendImages(String userId, List<File> images) async {
    final id = _ref.watch(authProvider).currentUser!.uid;
    final uploader = _ref.read(imageUploadUsecaseProvider);
    final imageUrls = await uploader.uploadRoomImages(id, images);
    final aspectRatios = uploader.getAspectRatios(images);
    return _repository.sendImages(imageUrls, aspectRatios);
  }
}
