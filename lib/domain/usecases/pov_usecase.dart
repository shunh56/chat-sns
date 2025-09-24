/*import 'package:app/domain/entity/pov.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final povUsecaseProvider = Provider(
  (ref) => PovUsecase(
    ref.watch(povRepositoryProvider),
  ),
);

class PovUsecase {
  final PovRepository _repository;

  PovUsecase(
    this._repository,
  );

  //CREATE
  uploadPov(PovState state) async {
    return _repository.uploadPov(state);
  }

  //READ
  Future<List<Pov>> getPovs() async {
    return await _repository.getPovs();
  }

  /*Future<List<Pov>> getPublicPovs() async {
     final res = await _repository.fetchPublicPovs();
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
   
  } */

  /*Future<List<Pov>> getPopularPovs() async {
     final res = await _repository.fetchPopularPovs();
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
  } */

  Future<List<Pov>> getPovsFromUserId(String userId) async {
    return await _repository.getPovsFromUserId(userId);
  }

  Stream<List<Pov>> streamPovReplies(String povId) {
    return _repository.streamPovReplies(povId);
  }

  incrementLikeCount(String id) {
    return _repository.incrementLikeCount(id);
  }

  addReply(String id, String text) {
    return _repository.addReply(id, text);
  }

  incrementLikeCountToReply(String povId, String replyId) {
    return _repository.incrementLikeCountToReply(povId, replyId);
  }
}
 */
