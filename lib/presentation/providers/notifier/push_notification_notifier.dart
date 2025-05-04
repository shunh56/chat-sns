import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/domain/usecases/push_notification_usecase.dart';
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
    if (type == "postLike") {
      _usecase.sendPostLike(user);
    }
    if (type == "postComment") {
      _usecase.sendPostComment(user);
    }
  }

  sendFriendRequest(UserAccount user) {
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    if (user.notificationData.friendRequest && user.fcmToken != null) {
      _usecase.sendmulticast([user.fcmToken!], me.name, "フレンドリクエストが届きました。");
    }
  }

  sendVoiceChat() {}
}
