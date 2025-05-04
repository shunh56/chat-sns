import 'package:app/domain/entity/user.dart';
import 'package:app/data/repository/friends_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsUsecaseProvider = Provider(
  (ref) => FriendsUsecase(
    ref.watch(friendsRepositoryProvider),
  ),
);

class FriendsUsecase {
  final FriendsRepository _repository;

  FriendsUsecase(this._repository);

  Stream<List<String>> streamFriends() {
    return _repository.streamFriends();
  }

  Future<List<String>> getFriendIds(String userId) async {
    return _repository.getFriendIds(userId);
  }

  addFriend(String userId) {
    return _repository.addFriend(userId);
  }

  deleteFriend(String userId) {
    return _repository.deleteFriend(userId);
  }

  Future<List<String>> getDeletes() async {
    return _repository.getDeletes();
  }

  void deleteUser(UserAccount user) {
    return _repository.deleteUser(user.userId);
  }
}
