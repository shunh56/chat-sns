// Package imports:
import 'dart:io';

import 'package:app/domain/entity/invite_code.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/onboarding_providers.dart';
import 'package:app/domain/usecases/image_uploader_usecase.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/invite_code_usecase.dart';
import 'package:app/domain/usecases/user_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myAccountNotifierProvider = StateNotifierProvider.autoDispose<
    MyAccountNotifier, AsyncValue<UserAccount>>(
  (ref) => MyAccountNotifier(
    ref,
    ref.watch(userUsecaseProvider),
  )..initialize(),
);

class MyAccountNotifier extends StateNotifier<AsyncValue<UserAccount>> {
  MyAccountNotifier(this.ref, this.usecase)
      : super(const AsyncValue<UserAccount>.loading());
  final Ref ref;
  final UserUsecase usecase;

  Future<void> initialize() async {
    UserAccount? userAccount =
        await usecase.getUserByUid(ref.watch(authProvider).currentUser!.uid);
    if (mounted) {
      if (userAccount != null) {
        state = AsyncValue.data(userAccount);
        ref
            .read(allUsersNotifierProvider.notifier)
            .addUserAccounts([userAccount]);
      } else {
        state = AsyncValue.data(UserAccount.nullUser());
        usecase.createUser(UserAccount.nullUser());
      }
    }
  }

  Future<void> update(UserAccount user) async {
    if (user.userId == ref.read(authProvider).currentUser!.uid) {
      usecase.updateUser(user);
      ref.read(allUsersNotifierProvider.notifier).addUserAccounts([user]);
    }
  }

  Future<void> updateField({
    String? name,
    Bio? bio,
    String? aboutMe,
    Links? links,
    String? imageUrl,
    List<String>? tags,
    List<String>? topFriends,
    CurrentStatus? currentStatus,
    Privacy? privacy,
    NotificationData? notificationData,
    CanvasTheme? canvasTheme,
    bool? isOnline,
    String? fcmToken,
    String? voipToken,
    String? usedCode,
    AccountStatus? accountStatus,
    String? location,
    String? job,
  }) async {
    final user = state.asData!.value;

    // 新しいユーザー状態を作成
    final updatedUser = user.copyWith(
      name: name,
      bio: bio,
      aboutMe: aboutMe,
      links: links,
      imageUrl: imageUrl,
      tags: tags,
      topFriends: topFriends,
      currentStatus: currentStatus,
      privacy: privacy,
      notificationData: notificationData,
      canvasTheme: canvasTheme,
      isOnline: isOnline,
      fcmToken: fcmToken,
      voipToken: voipToken,
      usedCode: usedCode,
      accountStatus: accountStatus,
      lastOpenedAt: isOnline != null ? Timestamp.now() : null,
      location: location,
      job: job,
    );

    // 状態を更新
    state = AsyncValue.data(updatedUser);

    // Firestoreを更新
    if (updatedUser.userId == ref.read(authProvider).currentUser!.uid) {
      await usecase.updateUser(updatedUser);
      ref
          .read(allUsersNotifierProvider.notifier)
          .addUserAccounts([updatedUser]);
    }
  }

  onOpen() async {
    final user = state.asData!.value;
    await Future.delayed(const Duration(milliseconds: 50));
    if (!kDebugMode) {
      final token = await FirebaseMessaging.instance.getToken();
      final voipToken = Platform.isIOS
          ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
          : null;
      final updatedUser = user.copyWith(
        isOnline: true,
        lastOpenedAt: Timestamp.now(),
        fcmToken: token,
        voipToken: voipToken,
      );
      state = AsyncValue.data(updatedUser);
      update(updatedUser);
    } else {
      final updatedUser = user.copyWith(
        isOnline: true,
        lastOpenedAt: Timestamp.now(),
      );
      state = AsyncValue.data(updatedUser);
      update(updatedUser);
    }

    //final token = await FirebaseMessaging.instance.getAPNSToken();
  }

  onClosed() {
    if (state.asData == null) {
      return;
    }
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      isOnline: false,
      lastOpenedAt: Timestamp.now(),
    );
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  onSignOut() async {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      isOnline: false,
      lastOpenedAt: Timestamp.now(),
    );
    await update(updatedUser);
    state = const AsyncValue.loading();
  }

  //usedCodeにしようするコードを書き換える => ホームに行けるようになる
  useInviteCode(InviteCode code) {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(usedCode: code.id);
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  waitInLine() {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(usedCode: "WAITING");
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  createUser(
    String username,
    String name,
    File? iconImage,
    String doing,
  ) async {
    ref.read(creatingProcessProvider.notifier).state = true;
    await Future.delayed(const Duration(seconds: 1));
    final user = state.asData!.value;
    if (user.validCode) {
      final code = await ref
          .read(inviteCodeUsecaseProvider)
          .getInviteCode(user.usedCode!);
      if (code.getStatus == InviteCodeStatus.valid) {
        ref.read(inviteCodeUsecaseProvider).useCode(user.usedCode!);
        // ref.read(friendsUsecaseProvider).addFriend(code.userId);
      }
    }
    final String userId = ref.watch(authProvider).currentUser!.uid;

    String? imageUrl = iconImage != null
        ? await ref.read(imageUploadUsecaseProvider).uploadIconImage(iconImage)
        : null;
    final updatedUser = user.create(
      userId: userId,
      username: username,
      name: name,
      imageUrl: imageUrl,
    );
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
    final otherIds = ref.read(selectedOtherIdsProvider);
    if (otherIds.isNotEmpty) {
      for (String userId in otherIds) {
        //ref.read(relationUsecaseProvider).sendRequest(userId);
      }
    }
  }

  changeColor(CanvasTheme canvasTheme) {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(canvasTheme: canvasTheme);
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  updateBio(
      {required String name,
      required Bio bio,
      required String aboutMe,
      required Links links,
      String? imageUrl}) async {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      name: name,
      bio: bio,
      aboutMe: aboutMe,
      imageUrl: imageUrl,
      links: links,
    );

    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  /*addFriend(String userId) {
    final me = state.asData!.value;
    final temp = me.friendIds.toSet();
    temp.add(userId);
    final friendIds = List<String>.from(temp);
    final updatedUser = me.copyWith(friendIds: friendIds);
    ref.read(firestoreProvider).collection("users").doc(userId).update({
      "friends": FieldValue.arrayUnion([
        ref.read(authProvider).currentUser!.uid,
      ])
    });
    update(updatedUser);
  } */

  updateTopFriends(
    List<String> topFriends,
  ) async {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(topFriends: topFriends);

    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  checkTopFriends(List<String> friendIds) {
    final me = state.asData!.value;
    final topFriends = me.topFriends;
    topFriends.removeWhere((userId) => !friendIds.contains(userId));
    final updatedUser = me.copyWith(topFriends: topFriends);

    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  removeTopFriends(UserAccount user) {
    final me = state.asData!.value;
    final topFriends = me.topFriends;
    topFriends.removeWhere((userId) => userId == user.userId);
    final updatedUser = me.copyWith(topFriends: topFriends);

    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  updatePrivacy(Privacy privacy) {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(privacy: privacy);
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  updateNotificationData(NotificationData notificationData) {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(notificationData: notificationData);

    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  deleteAccount() {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      accountStatus: AccountStatus.deleted,
      isOnline: false,
      lastOpenedAt: Timestamp.now(),
    );
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

  rebootAccount() {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      accountStatus: AccountStatus.normal,
      lastOpenedAt: Timestamp.now(),
    );
    state = AsyncValue.data(updatedUser);
    update(updatedUser);
  }

/*
  _checkInitialUpdates(UserAccount userAccount) {
    //update deviceInfo
    final DeviceInfo deviceInfo =
        ref.read(appConfigNotifierProvider).asData!.value;
    if (ref
        .read(appConfigNotifierProvider.notifier)
        .checkUpdates(userAccount.deviceInfo)) {
      usecase.updateDeviceInfo(deviceInfo);
    }
  }

  

  Future<void> updateProfile(
    File? thumbnailImage,
    File? iconImage,
    String? name,
    String? comment,
  ) async {
    final oldState = state.asData!.value;
    final newState = await usecase.updateProfile(
      oldState,
      thumbnailImage,
      iconImage,
      name,
      comment,
    );
    state = AsyncValue.data(newState);
    ref.read(allUsersNotifierProvider).saveUser(newState, ConnectionType.none);
  }

  //消す
  updateFields({
    String? name,
    String? username,
    int? gender,
    String? comment,
    String? imageUrl,
    String? thumbnailImageUrl,
    bool? isOnline,
    String? lastOpenedAt,
    String? fcmToken,
    List<String>? personalities,
   
    bool? isBanned,
    bool? isDeleted,
    bool? isFreezed,
    String? freezedUntil,
    String? lastLocationId,
    DateTime? birthday,
  }) {}

 */
}
