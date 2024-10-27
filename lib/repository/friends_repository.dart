import 'package:app/datasource/friends_datasource.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsRepositoryProvider = Provider(
  (ref) => FriendsRepository(
    ref.watch(friendsDatasourceProvider),
  ),
);

class FriendsRepository {
  final FriendsDatasource _datasource;

  FriendsRepository(this._datasource);

  //CREATE
  sendFriendRequest(String userId) {
    return _datasource.sendFriendRequest(userId);
  }

  void admitFriendRequested(String userId) {
    return _datasource.admitFriendRequested(userId);
  }

  void addFriend(String userId) {
    return _datasource.addFriend(userId);
  }

  void addEngagement(String userId) {
    _datasource.addEngagement(userId);
  }

  //READ
  Stream<List<String>> streamFriendRequesteds() {
    final stream = _datasource.streamFriendRequesteds();
    return stream.map((event) => event.docs.map((doc) => doc.id).toList());
  }

  Stream<List<String>> streamFriendRequests() {
    final stream = _datasource.streamFriendRequests();
    return stream.map((event) => event.docs.map((doc) => doc.id).toList());
  }

  Stream<List<FriendInfo>> streamFriends() {
    final stream = _datasource.streamFriends();
    return stream.map((event) => event.docs.map(
          (doc) {
            final json = doc.data();
            return FriendInfo(
              createdAt: json["createdAt"],
              userId: json["userId"],
              engagementCount: json["engagementCount"] ?? 0,
            );
          },
        ).toList());
  }

  Future<List<String>> getFriends(String userId) async {
    final res = await _datasource.fetchFriends(userId);
    return res.docs.map((doc) => doc.id).toList();
  }

  //UPDATE

  //DELETE
  void cancelRequest(String userId) {
    return _datasource.deleteRequest(userId);
  }

  void deleteRequested(String userId) {
    return _datasource.deleteRequested(userId);
  }

  void deleteFriend(String userId) {
    return _datasource.deleteFriend(userId);
  }

  Future<List<String>> getDeletes() async {
    final res = await _datasource.fetchDeletes();
    return res.docs.map((doc) => doc.id).toList();
  }

  void deleteUser(String userId) {
    return _datasource.deleteUser(userId);
  }
}
