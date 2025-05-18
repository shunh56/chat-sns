/*import 'package:app/data/datasource/friends_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsRepositoryProvider = Provider(
  (ref) => FriendsRepository(
    ref.watch(friendsDatasourceProvider),
  ),
);

class FriendsRepository {
  final FriendsDatasource _datasource;

  FriendsRepository(this._datasource);

  Stream<List<String>> streamFriends() {
    final res = _datasource.streamFriends();
    return res.map((snap) => List<String>.from(snap.data()?["data"] ?? []));
  }

  Future<List<String>> getFriendIds(String userId) async {
    final res = await _datasource.fetchFriendIds(userId);
    return List<String>.from(res.data()?["data"] ?? []);
  }

  addFriend(String userId) {
    return _datasource.addFriend(userId);
  }

  deleteFriend(String userId) {
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
 */