import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/repository/friends_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsUsecaseProvider = Provider(
  (ref) => FriendsUsecase(
    ref.watch(friendsRepositoryProvider),
  ),
);

class FriendsUsecase {
  final FriendsRepository _repository;

  FriendsUsecase(this._repository);

  //CREATE

  sendFriendRequest(UserAccount user) {
    return _repository.sendFriendRequest(user.userId);
  }

  void admitFriendRequested(String userId) {
    return _repository.admitFriendRequested(userId);
  }

  void addFriend(String userId) {
    return _repository.addFriend(userId);
  }

  void addEngagement(String userId) {
    _repository.addEngagement(userId);
  }

  //READ
  Stream<List<String>> streamFriendRequesteds() {
    return _repository.streamFriendRequesteds();
  }

  Stream<List<String>> streamFriendRequests() {
    return _repository.streamFriendRequests();
  }

  Stream<List<FriendInfo>> streamFriends() {
    return _repository.streamFriends();
  }

  Future<List<String>> getFriends(userId) {
    return _repository.getFriends(userId);
  }

  //UPDATE

  //DELETE
  void cancelRequest(String userId) {
    return _repository.cancelRequest(userId);
  }

  void deleteRequested(String userId) {
    return _repository.deleteRequested(userId);
  }

  void deleteFriend(String userId) {
    return _repository.deleteFriend(userId);
  }

  Future<List<String>> getDeletes() async {
    return _repository.getDeletes();
  }

  void deleteUser(UserAccount user) {
    return _repository.deleteUser(user.userId);
  }
}
