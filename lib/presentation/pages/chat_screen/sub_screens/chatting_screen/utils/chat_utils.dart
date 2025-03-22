import 'package:app/domain/entity/user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/presentation/providers/provider/followers_list_notifier.dart';
import 'package:app/presentation/providers/provider/following_list_notifier.dart';
import 'package:app/presentation/providers/provider/users/blocks_list.dart';

/// チャット関連のユーティリティ関数を提供するクラス
class ChatUtils {
  /// ユーザー間のフォロー関係を確認
  static bool checkMutualFollow(WidgetRef ref, UserAccount user) {
    final followings =
        ref.read(followingListNotifierProvider).asData?.value ?? [];
    final followers =
        ref.read(followersListNotifierProvider).asData?.value ?? [];

    final isFollowing =
        followings.any((follow) => follow.userId == user.userId);
    final isFollowed = followers.any((follow) => follow.userId == user.userId);

    return isFollowing && isFollowed;
  }

  /// ユーザーがブロックされているか確認
  static bool isUserBlocked(WidgetRef ref, UserAccount user) {
    final blockeds = ref.read(blockedsListNotifierProvider).asData?.value ?? [];
    return blockeds.any((userId) => userId == user.userId);
  }

  /// ユーザーをブロックしているか確認
  static bool isBlockingUser(WidgetRef ref, UserAccount user) {
    final blocks = ref.read(blocksListNotifierProvider).asData?.value ?? [];
    return blocks.any((userId) => userId == user.userId);
  }

  /// ブロック関係があるかどうか確認
  static bool hasBlockRelationship(WidgetRef ref, UserAccount user) {
    return isUserBlocked(ref, user) || isBlockingUser(ref, user);
  }

  /// ランダムなウェルカムメッセージを取得
  static List<String> getWelcomeMessages(String userName) {
    return [
      "お待たせしました！$userNameさんとのチャットの舞台が開幕です。さぁ、メッセージの交換を始めましょう！",
      "おっす！ここからが$userNameさんとのチャットのスタート地点。面白い会話をガンガン繰り広げよう！",
      "$userNameさんとのチャットの魔法が始まるよ！この先にはどんな会話が待っているのか、楽しみだね。",
      "$userNameさんとのチャットの時間がやってきました。さあ、楽しいおしゃべりを始めましょう！",
      "新しい物語の始まりだ！ここからチャットの冒険がスタートします。さぁ、話を続けよう！",
      "$userNameさんとのチャットの世界へようこそ！ここからが本格的な会話の始まりだ。楽しんでね！"
    ];
  }
}
