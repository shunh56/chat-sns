import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/usecase/push_notification_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO
//　今実装されているのは投稿に対するいいね、DM、フレンドリクエスト

final pushNotificationNotifierProvider = Provider(
  (ref) => PushNotificationNotifier(
    ref,
    ref.watch(pushNotificationUsecaseProvider),
  ),
);

class PushNotificationNotifier {
  final Ref ref;
  final PushNotificationUsecase _usecase;
  PushNotificationNotifier(
    this.ref,
    this._usecase,
  );

  sendDm(UserAccount user, String text) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    _usecase.sendDm(user, me.name, text);
  }

  sendPostReaction(UserAccount user, String type) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (type == "postLike") {
      _usecase.sendReaction(user, me.name, "あなたの投稿にいいねしました。");
    }
    if (type == "postComment") {
      _usecase.sendReaction(user, me.name, "あなたの投稿にコメントしました。");
    }
  }

  sendCurrentStatusPostReaction(UserAccount user, String type) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (type == "currentStatusPostLike") {
      _usecase.sendReaction(user, me.name, "あなたのステータスにいいねしました。");
    }
  }

  sendFriendRequest(UserAccount user) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (user.notificationData.friendRequest && user.fcmToken != null) {
      _usecase.sendmulticast([user.fcmToken!], me.name, "フレンドリクエストが届きました。Ï");
    }
  }

/*  sendCurrentStatusPost() {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    final friendIds = ref
        .read(friendIdListNotifierProvider)
        .asData!
        .value
        .map((item) => item.userId)
        .toList();
    final friends = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => friendIds.contains(user.userId))
        .toList();
    return _usecase.sendPost(friends, "${me.name}がステータスを更新しました。");
  }

  uploadPost() {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    final friendIds = ref
        .read(friendIdListNotifierProvider)
        .asData!
        .value
        .map((item) => item.userId)
        .toList();
    final friends = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => friendIds.contains(user.userId))
        .toList();
    return _usecase.sendPost(friends, "${me.name}が投稿をしました。");
  }
 */

  sendVoiceChat() {}
  sendFriendReqeust() {}

  /*sendMulticast() {
    final friendIds = ref
        .read(friendIdListNotifierProvider)
        .asData!
        .value
        .map((item) => item.userId)
        .toList();
    final friends = ref
        .watch(allUsersNotifierProvider)
        .asData!
        .value
        .values
        .where((user) => friendIds.contains(user.userId))
        .toList();
    return _usecase.sendmulticast(friends, "TITLE", "THIS IS BODY");
  } */
}
