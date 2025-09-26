/*import 'package:app/data/datasource/pov_datasource.dart';
import 'package:app/domain/entity/pov.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final povRepositoryProvider = Provider(
  (ref) => PovRepository(
    ref.watch(povDatasourceProvider),
  ),
);

class PovRepository {
  final PovDatasource _datasource;

  PovRepository(
    this._datasource,
  );

  //CREATE
  uploadPov(PovState state) async {
    return _datasource.uploadPov(state);
  }

  //READ
  Future<List<Pov>> getPovs() async {
    final res = await _datasource.getPovs();
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
  }

  /*Future<List<Pov>> getPublicPovs() async {
     final res = await _datasource.fetchPublicPovs();
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
   
  } */

  /*Future<List<Pov>> getPopularPovs() async {
     final res = await _datasource.fetchPopularPovs();
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
  } */

  Future<List<Pov>> getPovsFromUserId(String userId) async {
    final res = await _datasource.getPovsFromUserId(userId);
    return res.docs.map((doc) => Pov.fromJson(doc.data())).toList();
  }

  Stream<List<Pov>> streamPovReplies(String povId) {
    final stream = _datasource.streamPovReplies(povId);
    return stream
        .map((e) => e.docs.map((doc) => Pov.fromJson(doc.data())).toList());
  }

  incrementLikeCount(String id) {
    return _datasource.incrementLikeCount(id, 1);
  }

  addReply(String id, String text) {
    return _datasource.addReply(id, text);
  }

  incrementLikeCountToReply(
    String povId,
    String replyId,
  ) {
    return _datasource.incrementLikeCountToReply(povId, replyId, 1);
  }
}
 */
