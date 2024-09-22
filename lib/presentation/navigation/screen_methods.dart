/*// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomiboo/_v2/domain/entity/user/user.dart';
import 'package:nomiboo/_v2/presentation/notifier/firebase/analytics.dart';
import 'package:nomiboo/_v2/presentation/screens/main/main_screen.dart';
import 'package:nomiboo/_v2/presentation/state_providers/users/blocked_list.dart';
import 'package:nomiboo/_v2/presentation/state_providers/users/blocks_list.dart';
import 'package:nomiboo/_v2/presentation/state_providers/users/followings_list.dart';
import 'package:nomiboo/_v2/presentation/state_providers/users/my_user_account.dart';
import 'package:nomiboo/presentation/providers/local/bottom_nav_index.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import 'package:nomiboo/_v2/presentation/screens/main/profile/my_profile_dashboard_screen.dart';
import 'package:nomiboo/core/extensions/widgets/snackbar.dart';
import 'package:nomiboo/core/utils/print.dart';
import 'package:nomiboo/main.dart';

import 'package:nomiboo/_v2/presentation/state_providers/ads/interstitial_ad_provider.dart';
import 'package:nomiboo/presentation/providers/focused_user/focused_id_provider.dart';
import 'package:nomiboo/_v2/presentation/state_providers/in_app_purchase/check_purchase.dart';
import 'package:nomiboo/_v2/presentation/screens/main/chat/chatting_screen.dart';
import 'package:nomiboo/_v2/presentation/screens/proflie_user/user_profile_screen.dart';

class ScreenMethods {
  Future<bool> getPurchaserInfo(CustomerInfo customerInfo) async {
    try {
      DebugPrint("checking purchase info");
      bool subscribed = await updatePurchases(customerInfo, "Premium");
      return subscribed;
    } on PlatformException catch (e) {
      print(" getPurchaserInfo error ${e.toString()}");
      return false;
    }
  }

  Future<bool> updatePurchases(
      CustomerInfo purchaserInfo, String entitlement) async {
    var isPurchased = false;
    final entitlements = purchaserInfo.entitlements.all;
    if (entitlements.isEmpty) {
      isPurchased = false;
    }
    if (!entitlements.containsKey(entitlement)) {
      ///そもそもentitlementが設定されて無い場合
      isPurchased = false;
    } else if (entitlements[entitlement]!.isActive) {
      ///設定されていて、activeになっている場合
      isPurchased = true;
    } else {
      isPurchased = false;
    }

    return isPurchased;
  }

  Future<void> goToProfile(
      BuildContext context, UserAccount user, WidgetRef ref) async {
    ref.read(analyticsNotifierProvider).logEvent("go_to_profile");
    UserAccount me = ref.watch(myAccountNotifierProvider).asData!.value;
    final blocksList = ref.watch(blocksListNotifierProvider).asData!.value;
    final blockedList = ref.watch(blockedsListNotifierProvider).asData!.value;
    if (user.userId == me.userId) {
      if (!Navigator.of(context).canPop()) {
        ref.read(bottomNavIndexProvider.notifier).changeIndex(2);
        ref.read(barsVisibilityProvider.notifier).state = true;
      } else {
        showMessage("自身のアカウントです。");
      }
      return;
    }
    if (blocksList.contains(user.userId)) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_profile_suspended_blocks");
      showMessage("このアカウントをブロックしています。");
      return;
    }
    if (blockedList.contains(user.userId)) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_profile_suspended_blocked");
      showMessage("このアカウントからブロックされています。");
      return;
    }
    if (ref.read(focusedIdProvider) != null &&
        ref.read(focusedIdProvider.notifier).state!.userId == user.userId) {
      showMessage("エラーが発生しました。");
      return;
    }

    if (!ref.read(inAppPurchaseManager.notifier).isSubscribed) {
      if (Random().nextInt(10) == 0 &&
          DateTime.now()
                  .difference(
                      ref.read(lastInterstitialAdSeenDateTime.notifier).state)
                  .inSeconds >=
              60) {
        ref.read(analyticsNotifierProvider).logEvent("interstial_ad_profile");
        ref.read(interstitialAdNotififerProvider.notifier).showAd(ref);
      }
    }
    ref.read(focusedIdProvider.notifier).state = user;
    //ref.read(footPrintsCreatedListNotifierProvider.notifier).addFootPrint(user);
    ref.read(analyticsNotifierProvider).logScreen("user_profile_screen");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserileScreen(
          user: user,
        ),
        settings: const RouteSettings(name: "not_my_friend"),
      ),
    );
  }

  Future<void> goToChatScreen(
      BuildContext context, UserAccount user, WidgetRef ref) async {
    ref.read(analyticsNotifierProvider).logEvent("go_to_chat");
    UserAccount me = ref.watch(myAccountNotifierProvider).asData!.value;
   // final followers = ref.read(myFollowerListNotifierProvider).asData!.value;
    final followings = ref.read(myFollowingListNotifierProvider).asData!.value;
    final blocksList = ref.watch(blocksListNotifierProvider).asData!.value;
    final blockedList = ref.watch(blockedsListNotifierProvider).asData!.value;

    if (user.userId == me.userId) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_chat_suspended_is_me");
      showMessage("自身のアカウントです。");
      return;
    }

    if (blocksList.contains(user.userId)) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_chat_suspended_block");
      showMessage("このアカウントをブロックしています。");
      return;
    }
    if (blockedList.contains(user.userId)) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_chat_suspended_blocked");
      showMessage("このアカウントからブロックされています。");
      return;
    }

    if (!followings.contains(user.userId)) {
      showMessage("チャットをするにはフォローをして下さい。");
      return;
    }
    /*if (!followers.contains(user.userId)) {
      showMessage("相互フォローでないとチャットはできません。");
      return;
    } */

    //TODO 1.2.3
    /*if (me.birthday == null) {
        showMessage("プライバシー保護のため、誕生日を設定してください。");
        return;
      } */

    /* if (user.isDeleted || user.isBanned || user.isFreezed) {
      ref
          .read(analyticsNotifierProvider)
          .logEvent("go_to_chat_suspended_user_freezed");
      goToProfile(context, user, ref);
      return;
    } */

    if (!ref.read(inAppPurchaseManager.notifier).isSubscribed) {
      if (Random().nextInt(10) == 0 &&
          DateTime.now()
                  .difference(
                      ref.read(lastInterstitialAdSeenDateTime.notifier).state)
                  .inSeconds >=
              60) {
        ref.read(analyticsNotifierProvider).logEvent("interstial_ad_chat");
        ref.read(interstitialAdNotififerProvider.notifier).showAd(ref);
      }
    }

    //ref.read(footPrintsCreatedListNotifierProvider.notifier).addFootPrint(user);
    ref.read(analyticsNotifierProvider).logScreen("dm_screen");
    ref.read(analyticsNotifierProvider).logEvent("direct_message_success");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChattingScreen(
          user: user,
        ),
        settings: const RouteSettings(name: "chatting_page"),
      ),
    );
  }

  Future<void> goToMyProfile(BuildContext context, WidgetRef ref) async {
    final asyncMe = ref.read(myAccountNotifierProvider);
    asyncMe.when(
      error: (e, s) => showErrorSnackbar(),
      loading: () {},
      data: (me) async {
        //ref.read(focusedUserDMMessagesProvider.notifier).reload();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileDashboardScreen(),

            //builder: (_) => NotFriendScreen(userId: userId),
            settings: const RouteSettings(name: "not_my_friend"),
          ),
        );
      },
    );
  }

  void reOpenApp(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(isUnderMaintenance: false),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void deleteAccount(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
      (Route<dynamic> route) => false,
    );
    Future.delayed(const Duration(milliseconds: 600));
  }

  void goBackToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
 */