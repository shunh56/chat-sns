// Package imports:
import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/value/user/gender.dart';
import 'package:app/presentation/pages/onboarding_page/onboarding_page.dart';
import 'package:app/presentation/providers/notifier/image/image_uploader_notifier.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/usecase/posts/current_status_post_usecase.dart';
import 'package:app/usecase/user_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    DebugPrint("initializing myAccount");
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
      }
    }
    /*if (!userAccount.isDummy()) {
      ref
          .read(allUsersNotifierProvider)
          .saveUser(userAccount, ConnectionType.me);
      _checkInitialUpdates(userAccount);
    } */
  }

  onOpen() async {
    final user = state.asData!.value;
    final token = await FirebaseMessaging.instance.getToken();
    final voipToken = Platform.isIOS
        ? await FlutterCallkitIncoming.getDevicePushTokenVoIP()
        : null;
    //final token = await FirebaseMessaging.instance.getAPNSToken();
    final updatedUser = user.copyWith(
      isOnline: true,
      lastOpenedAt: Timestamp.now(),
      fcmToken: token,
      voipToken: voipToken,
    );

    state = AsyncValue.data(updatedUser);
    usecase.updateUser(updatedUser);
  }

  onClosed() {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(
      isOnline: false,
      lastOpenedAt: Timestamp.now(),
    );
    state = AsyncValue.data(updatedUser);
    usecase.updateUser(updatedUser);
  }

  createUser(
    String username,
    String name,
    File? iconImage,
  ) async {
    ref.read(creatingProcessProvider.notifier).state = true;
    final String userId = ref.watch(authProvider).currentUser!.uid;
    //Isolate
    //get compressedImage
    //compressedImage = ...
    //userAccount =
    String? imageUrl = iconImage != null
        ? await ref
            .read(imageUploaderNotifierProvider)
            .uploadIconImage(iconImage)
        : null;
    final user = UserAccount.create(
      userId: userId,
      username: username,
      name: name,
      imageUrl: imageUrl,
    );
    usecase.createUser(user);
    state = AsyncValue.data(user);
  }

  changeColor(CanvasTheme canvasTheme) {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(canvasTheme: canvasTheme);
    state = AsyncValue.data(updatedUser);
    usecase.updateUser(updatedUser);
  }

  updateBio(Bio bio, String aboutMe, {String? imageUrl}) async {
    final user = state.asData!.value;
    final updatedUser =
        user.copyWith(bio: bio, aboutMe: aboutMe, imageUrl: imageUrl);
    usecase.updateUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }

  updateTopFriends(
    List<String> topFriends,
  ) async {
    final user = state.asData!.value;
    final updatedUser = user.copyWith(topFriends: topFriends);
    usecase.updateUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }

  removeTopFriends(UserAccount user) {
    final user = state.asData!.value;
    final topFriends = user.topFriends;
    topFriends.removeWhere((userId) => userId == user.userId);
    final updatedUser = user.copyWith(topFriends: topFriends);
    usecase.updateUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }

  updateCurrentStatus(CurrentStatus currentStatus) async {
    final user = state.asData!.value;
    final before = user.currentStatus;
    if (before != currentStatus) {
      final updatedUser = user.copyWith(currentStatus: currentStatus);
      usecase.updateUser(updatedUser);
      ref
          .read(currentStatusPostUsecaseProvider)
          .addPost(before.toJson(), currentStatus.toJson());
      state = AsyncValue.data(updatedUser);
    }
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
