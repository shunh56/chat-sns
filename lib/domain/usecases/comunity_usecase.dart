import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/room_message.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/data/repository/community_repository.dart';
import 'package:app/domain/usecases/image_uploader_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityUsecaseProvider = Provider(
  (ref) => CommunityUsecase(
    ref,
    ref.watch(communityRepositoryProvider),
  ),
);

class CommunityUsecase {
  final Ref _ref;
  final CommunityRepository _repository;
  CommunityUsecase(this._ref, this._repository);

  Future<Community?> getCommunityFromId(String communityId) async {
    return _repository.getCommunityFromId(communityId);
  }

  Future<List<Map<String, dynamic>>> getRecentUsers(String communityId,
      {Timestamp? timestamp}) async {
    return _repository.getRecentUsers(
      communityId,
      timestamp: timestamp,
    );
  }

  Stream<List<Community>> streamJoinedCommunities() {
    return _repository.streamJoinedCommunities();
  }

  Future<List<Community>> getPopularCommunities() async {
    return _repository.getPopularCommunities();
  }

  Future<List<Community>> getNewCommunities() async {
    return _repository.getNewCommunities();
  }

  Future<List<Community>> searchCommunities(String query) async {
    return _repository.searchCommunities(query);
  }

  createCommunity(Community community) async {
    return _repository.createCommunity(community.toJson());
  }

  joinCommunity(Community community) {
    return _repository.joinCommunity(community.id);
  }

  leaveCommunity(Community community) {
    DebugPrint("LEAVE COMMUNITY USECASE");
    return _repository.leaveCommunity(community.id);
  }

  // messsages
  Future<List<Message>> getMessages(String communityId,
      {Timestamp? lastMessageTimestamp}) async {
    return _repository.getMessages(communityId);
  }

  //最新メッセージをリアルタイムで取得する
  Stream<List<Message>> streamMessages(String communityId) {
    return _repository.streamMessages(communityId);
  }

  //CREATE
  sendMessage(String communityId, String text) {
    return _repository.sendMessage(communityId, text);
  }

  sendImages(String communityId, List<File> images) async {
    final uploader = _ref.read(imageUploadUsecaseProvider);
    final imageUrls = await uploader.uploadCommunityImages(communityId, images);
    final aspectRatios = uploader.getAspectRatios(images);
    return _repository.sendImages(communityId, imageUrls, aspectRatios);
  }
}
