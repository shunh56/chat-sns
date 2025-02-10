import 'package:app/core/utils/debug_print.dart';
import 'package:app/datasource/comunity_datasouce.dart';
import 'package:app/domain/entity/room_message.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(
    ref.watch(communityDatasourceProvider),
  ),
);

class CommunityRepository {
  final CommunityDatasource _datasource;
  CommunityRepository(this._datasource);

  Future<Community?> getCommunityFromId(String communityId) async {
    final res = await _datasource.getCommunityFromId(communityId);
    if (!res.exists) return null;
    return Community.fromJson(res.data()!);
  }

  Future<List<Map<String, dynamic>>> getRecentUsers(String communityId,
      {Timestamp? timestamp}) async {
    final res =
        await _datasource.getRecentUsers(communityId, timestamp: timestamp);
    return res.docs
        .map((doc) => {
              "joinedAt": doc.data()["joinedAt"],
              "userId": doc.id,
            })
        .toList();
  }

  Stream<List<Community>> streamJoinedCommunities() {
    final stream = _datasource.streamJoinedCommunities();
    return stream.map((snapshot) {
      return snapshot.map((data) => Community.fromJson(data)).toList();
    });
  }

  Future<List<Community>> getPopularCommunities() async {
    final res = await _datasource.getPopularCommunities();
    return res.docs.map((doc) => Community.fromJson(doc.data())).toList();
  }

  Future<List<Community>> getNewCommunities() async {
    final res = await _datasource.getNewCommunities();
    return res.docs.map((doc) => Community.fromJson(doc.data())).toList();
  }

  Future<List<Community>> searchCommunities(String query) async {
    final nameRes = await _datasource.searchCommunityByName(query);
    return nameRes.docs.map((doc) => Community.fromJson(doc.data())).toList();
  }

  createCommunity(Map<String, dynamic> json) {
    return _datasource.createCommunity(json);
  }

  joinCommunity(String communityId) {
    return _datasource.joinCommunity(communityId);
  }

  leaveCommunity(String communityId) {
    DebugPrint("LEAVE COMMUNITY REPOSITORY");
    return _datasource.leaveCommunity(communityId);
  }

  //MESSAGE
  Future<List<Message>> getMessages(String communityId,
      {Timestamp? lastMessageTimestamp}) async {
    final res = await _datasource.fetchMessages(communityId,
        lastMessageTimestamp: lastMessageTimestamp);
    return res.docs.map((doc) => Message.fromJson(doc.data())).toList();
  }

  //最新メッセージをリアルタイムで取得する
  Stream<List<Message>> streamMessages(String communityId) {
    final stream = _datasource.streamMessages(communityId);
    return stream.map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  //CREATE
  sendMessage(String communityId, String text) {
    return _datasource.sendMessage(communityId, text);
  }

  sendImages(
      String communityId, List<String> imageUrls, List<double> aspectRatios) {
    return _datasource.sendImages(communityId, imageUrls, aspectRatios);
  }
}
