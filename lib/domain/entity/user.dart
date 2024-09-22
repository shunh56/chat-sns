import 'package:app/core/utils/debug_print.dart';
import 'package:app/domain/value/user/account_status.dart';
import 'package:app/domain/value/user/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ConnectionType {
  me,
  follow,
  followed,
  none,
}

class DeviceInfo {
  final Timestamp updatedAt;
  final String version;
  final String buildNumber;
  final String device;
  final String osVersion;
  final String platForm;

  DeviceInfo({
    required this.updatedAt,
    required this.version,
    required this.buildNumber,
    required this.device,
    required this.osVersion,
    required this.platForm,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      updatedAt: json["updatedAt"],
      version: json["version"],
      buildNumber: json["buildNumber"],
      device: json["device"],
      osVersion: json["osVersion"],
      platForm: json["platform"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "updatedAt": updatedAt,
      "version": version,
      "buildNumber": buildNumber,
      "device": device,
      "osVersion": osVersion,
      "platform": platForm,
    };
  }
}

class Bio {
  final int? age;
  final Timestamp? birthday;
  final String? gender;
  final String? interestedIn;
  Bio({
    required this.age,
    required this.birthday,
    required this.gender,
    required this.interestedIn,
  });

  factory Bio.fromJson(Map<String, dynamic> json) {
    return Bio(
      age: json["age"],
      birthday: json["birthday"],
      gender: json["gender"],
      interestedIn: json["interestedIn"],
    );
  }
  factory Bio.defaultBio() {
    return Bio(
      age: null,
      birthday: null,
      gender: null,
      interestedIn: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "age": age,
      "birthday": birthday,
      "gender": gender,
      "interestedIn": interestedIn,
    };
  }

  Bio copyWith({
    int? age,
    Timestamp? birthday,
    String? gender,
    String? interestedIn,
  }) {
    return Bio(
      age: age ?? this.age,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
    );
  }
}

class CurrentStatus {
  final List<String> tags;
  //final String? listening;
  //final String? watching;
  //final String? reading;

  final String doing;
  final String eating;
  final String mood;
  final String nowAt;
  final String nextAt;
  final List<String> nowWith;

  CurrentStatus({
    required this.tags,
    required this.doing,
    required this.eating,
    required this.mood,
    required this.nowAt,
    required this.nextAt,
    required this.nowWith,
  });

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
      tags: List<String>.from(json["tags"]),
      doing: json["doing"] ?? "",
      eating: json["eating"] ?? "",
      mood: json["mood"] ?? "",
      nowAt: json["nowAt"] ?? "",
      nextAt: json["nextAt"] ?? "",
      nowWith: List<String>.from(json["nowWith"] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tags": tags,
      "doing": doing,
      "eating": eating,
      "mood": mood,
      "nowAt": nowAt,
      "nextAt": nextAt,
      "nowWith": nowWith,
    };
  }

  factory CurrentStatus.defaultCurrentStatus() {
    return CurrentStatus(
      tags: [],
      doing: "",
      eating: "",
      mood: "",
      nowAt: "",
      nextAt: "",
      nowWith: [],
    );
  }

  CurrentStatus copyWith({
    List<String>? tags,
    String? doing,
    String? eating,
    String? mood,
    String? nowAt,
    String? nextAt,
    List<String>? nowWith,
  }) {
    return CurrentStatus(
      tags: tags ?? this.tags,
      doing: doing ?? this.doing,
      eating: eating ?? this.eating,
      mood: mood ?? this.mood,
      nowAt: nowAt ?? this.nowAt,
      nextAt: nextAt ?? this.nextAt,
      nowWith: nowWith ?? this.nowWith,
    );
  }
}

class CanvasTheme {
  //profile
  final Color bgColor; // = Color(Colors.white.value);
  final Color profileTextColor; // = Color(Colors.black.value);
  final Color profileSecondaryTextColor; // = Color(Colors.black45.value);
  //box
  final Color boxBgColor; // = Color(Colors.black12.value);
  final Color boxTextColor; // = Color(Colors.black38.value);
  final Color boxSecondaryTextColor; // = Color(Colors.black54.value);

  final double boxWidth; // = 4.0;
  final double boxRadius; // = 12.0;
  //icon
  final Color iconGradientStartColor; // = Color(Colors.purpleAccent.value);
  final Color iconGradientEndColor; // = Color(Colors.cyan.value);
  final double iconStrokeWidth; // = 2.0;
  final double iconRadius; // = 24.0;
  final bool iconHideBorder; // = false;
  final bool iconHideLevel; // = false;
  CanvasTheme({
    required this.bgColor,
    required this.profileTextColor,
    required this.profileSecondaryTextColor,
    required this.boxBgColor,
    required this.boxTextColor,
    required this.boxSecondaryTextColor,
    required this.boxWidth,
    required this.boxRadius,
    required this.iconGradientStartColor,
    required this.iconGradientEndColor,
    required this.iconStrokeWidth,
    required this.iconRadius,
    required this.iconHideBorder,
    required this.iconHideLevel,
  });

  factory CanvasTheme.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return defaultCanvasTheme();
    }
    return CanvasTheme(
      bgColor: Color(json["bgColor"]),
      profileTextColor: Color(json["profileTextColor"]),
      profileSecondaryTextColor: Color(json["profileSecondaryTextColor"]),
      boxBgColor: Color(json["boxBgColor"]),
      boxTextColor: Color(json["boxTextColor"]),
      boxSecondaryTextColor: Color(json["boxSecondaryTextColor"]),
      boxWidth: json["boxWidth"],
      boxRadius: json["boxRadius"],
      iconGradientStartColor: Color(json["iconGradientStartColor"]),
      iconGradientEndColor: Color(json["iconGradientEndColor"]),
      iconStrokeWidth: json["iconStrokeWidth"],
      iconRadius: json["iconRadius"],
      iconHideBorder: json["iconHideBorder"],
      iconHideLevel: json["iconHideLevel"],
    );
  }

  static CanvasTheme defaultCanvasTheme() {
    return CanvasTheme(
      bgColor: Color(Colors.white.value),
      profileTextColor: Color(Colors.black.value),
      profileSecondaryTextColor: Color(Colors.black45.value),
      boxBgColor: const Color(0xFFE0E0E0),
      boxTextColor: Colors.grey,
      boxSecondaryTextColor: const Color(0xFF424242),
      boxWidth: 4.0,
      boxRadius: 12.0,
      iconGradientStartColor: Color(Colors.purpleAccent.value),
      iconGradientEndColor: Color(Colors.cyan.value),
      iconStrokeWidth: 2.0,
      iconRadius: 24.0,
      iconHideBorder: false,
      iconHideLevel: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //profile
      "bgColor": bgColor.value,
      "profileTextColor": profileTextColor.value,
      "profileSecondaryTextColor": profileSecondaryTextColor.value,
      //box
      "boxBgColor": boxBgColor.value,
      "boxTextColor": boxTextColor.value,
      "boxSecondaryTextColor": boxSecondaryTextColor.value,
      "boxWidth": boxWidth,
      "boxRadius": boxRadius,
      //icon
      "iconGradientStartColor": iconGradientStartColor.value,
      "iconGradientEndColor": iconGradientEndColor.value,
      "iconStrokeWidth": iconStrokeWidth,
      "iconRadius": iconRadius,
      "iconHideBorder": iconHideBorder,
      "iconHideLevel": iconHideLevel,
    };
  }

  CanvasTheme copyWith({
    Color? bgColor,
    Color? profileTextColor,
    Color? profileSecondaryTextColor,
    Color? boxBgColor,
    Color? boxTextColor,
    Color? boxSecondaryTextColor,
    double? boxWidth,
    double? boxRadius,
    Color? iconGradientStartColor,
    Color? iconGradientEndColor,
    double? iconStrokeWidth,
    double? iconRadius,
    bool? iconHideBorder,
    bool? iconHideLevel,
  }) {
    return CanvasTheme(
      bgColor: bgColor ?? this.bgColor,
      profileTextColor: profileTextColor ?? this.profileTextColor,
      profileSecondaryTextColor:
          profileSecondaryTextColor ?? this.profileSecondaryTextColor,
      boxBgColor: boxBgColor ?? this.boxBgColor,
      boxTextColor: boxTextColor ?? this.boxTextColor,
      boxSecondaryTextColor:
          boxSecondaryTextColor ?? this.boxSecondaryTextColor,
      boxWidth: boxWidth ?? this.boxWidth,
      boxRadius: boxRadius ?? this.boxRadius,
      iconGradientStartColor:
          iconGradientStartColor ?? this.iconGradientStartColor,
      iconGradientEndColor: iconGradientEndColor ?? this.iconGradientEndColor,
      iconStrokeWidth: iconStrokeWidth ?? this.iconStrokeWidth,
      iconRadius: iconRadius ?? this.iconRadius,
      iconHideBorder: iconHideBorder ?? this.iconHideBorder,
      iconHideLevel: iconHideLevel ?? this.iconHideLevel,
    );
  }
}

class NotificationSettings {
  final bool isActive;
  final bool directMessage;
  final bool currentStatusPost;
  final bool post;
  final bool voiceChat;
  final bool friendRequest;
  NotificationSettings({
    required this.isActive,
    required this.directMessage,
    required this.currentStatusPost,
    required this.post,
    required this.voiceChat,
    required this.friendRequest,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isActive: json["isActive"] ?? true,
      directMessage: json["directMessage"] ?? true,
      currentStatusPost: json["currentStatusPost"] ?? true,
      post: json["post"] ?? true,
      voiceChat: json["voiceChat"] ?? true,
      friendRequest: json["friendRequest"] ?? true,
    );
  }
  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      isActive: true,
      directMessage: true,
      currentStatusPost: true,
      post: true,
      voiceChat: true,
      friendRequest: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isActive": isActive,
      "directMessage": directMessage,
      "currentStatusPost": currentStatusPost,
      "post": post,
      "voiceChat": voiceChat,
      "friendRequest": friendRequest,
    };
  }

  NotificationSettings copyWith({
    bool? isActive,
    bool? directMessage,
    bool? currentStatusPost,
    bool? post,
    bool? voiceChat,
    bool? friendRequest,
  }) {
    return NotificationSettings(
      isActive: isActive ?? this.isActive,
      directMessage: directMessage ?? this.directMessage,
      currentStatusPost: currentStatusPost ?? this.currentStatusPost,
      post: post ?? this.post,
      voiceChat: voiceChat ?? this.voiceChat,
      friendRequest: friendRequest ?? this.friendRequest,
    );
  }
}

class PrivacySettings {
  final bool isPrivate;
  final String availableFriendRequests; // friend_of_friend or anyone
  //final String profilePublicity; //
  //final String contentPublicity;

  PrivacySettings({
    required this.isPrivate,
    required this.availableFriendRequests,
    // required this.profilePublicity,
    // required this.contentPublicity,
  });
}

class UserAccount {
  //auto
  final String userId;
  final Timestamp createdAt;
  final Timestamp lastOpenedAt;
  final bool isOnline;
  //backend
  final String? fcmToken;
  final String? voipToken;
  final AccountStatus accountStatus;
  final DeviceInfo? deviceInfo;
  //info
  final String username;
  String? imageUrl;
  //profile info
  final Bio bio;
  final String aboutMe;
  final CurrentStatus currentStatus;
  final List<String> topFriends;
  final int friendCount;
  final List<String> wishList;
  final List<String> wantToDoList;
  final SubscriptionStatus subscriptionStatus;
  //canvas
  final CanvasTheme canvasTheme;
  //settings
  final NotificationSettings notificationSettings;

  UserAccount({
    required this.userId,
    required this.createdAt,
    required this.lastOpenedAt,
    required this.isOnline,
    //
    required this.fcmToken,
    required this.voipToken,
    required this.accountStatus,
    required this.deviceInfo,
    //
    required this.username,
    required this.imageUrl,
    //
    required this.bio,
    required this.aboutMe,
    required this.currentStatus,
    required this.topFriends,
    required this.friendCount,
    required this.wishList,
    required this.wantToDoList,
    //
    required this.canvasTheme,
    required this.subscriptionStatus,
    //
    required this.notificationSettings,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    if (json["username"] == null) {
      FirebaseAuth.instance.signOut();
    }
    return UserAccount(
      userId: json["userId"],
      createdAt: json["createdAt"],
      lastOpenedAt: json["lastOpenedAt"],
      isOnline: json["isOnline"],
      //
      fcmToken: json["fcmToken"],
      voipToken: json["voipToken"],
      accountStatus: AccountStatusConverter.convertToStatus(
        json["accountStatus"],
      ),
      deviceInfo: json["deviceInfo"] != null
          ? DeviceInfo.fromJson(
              json["deviceInfo"],
            )
          : null,
      //
      username: json["username"],
      imageUrl: json["imageUrl"],
      //profile
      bio: Bio.fromJson(json["profile"]["bio"]),
      aboutMe: json["profile"]["aboutMe"],
      currentStatus: CurrentStatus.fromJson(json["profile"]["currentStatus"]),
      topFriends: List<String>.from(json["profile"]["topFriends"]),
      friendCount: json["profile"]["friendCount"],
      wishList: List<String>.from(json['profile']['wishList'] ?? []),
      wantToDoList: List<String>.from(json['profile']['wantToDoList'] ?? []),
      canvasTheme: CanvasTheme.fromJson(json["canvasTheme"]),
      subscriptionStatus: SubscriptionConverter.convertToSubScriptionStatus(
        json["subscription"],
      ),
      //
      notificationSettings:
          NotificationSettings.fromJson(json["settings_notification"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    DebugPrint("JSON :$topFriends $wantToDoList");
    return {
      //"userId":userId,
      //"createdAt":createdAt,
      // "name": name,
      // "imageUrl": imageUrl,
      // "aboutMe": aboutMe,
      // "fcmToken": fcmToken,
      // "isOnline": isOnline,
      // "lastOpenedAt": lastOpenedAt,
      //"friendCount":friendCount
      //"gender"
      //status
      //deviceInfo
      "lastOpenedAt": lastOpenedAt,
      "isOnline": isOnline,
      //
      "fcmToken": fcmToken,
      "voipToken":voipToken,
      "accountStatus": AccountStatusConverter.convertToString(accountStatus),
      "deviceInfo": deviceInfo?.toJson(),
      //
      "imageUrl": imageUrl,
      //
      "profile.bio": bio.toJson(),
      "profile.aboutMe": aboutMe,
      "profile.currentStatus": currentStatus.toJson(),
      "profile.topFriends": topFriends,
      "profile.wishList": wishList,
      "profile.wantToDoList": wantToDoList,
      //canvas
      "canvasTheme": canvasTheme.toJson(),
    };
  }

  factory UserAccount.nullUser() {
    return UserAccount(
      userId: "nullUser",
      createdAt: Timestamp.now(),
      lastOpenedAt: Timestamp.now(),
      isOnline: false,
      //
      fcmToken: null,
      voipToken: null,
      accountStatus: AccountStatus.normal,
      deviceInfo: null,
      //
      username: "null",
      imageUrl: null,
      bio: Bio.defaultBio(),
      aboutMe: "",
      currentStatus: CurrentStatus.defaultCurrentStatus(), topFriends: [],
      friendCount: 0,
      wishList: [],
      wantToDoList: [],
      canvasTheme: CanvasTheme.defaultCanvasTheme(),
      subscriptionStatus: SubscriptionStatus.none,
      //
      notificationSettings: NotificationSettings.defaultSettings(),
    );
  }

  factory UserAccount.create({
    required String userId,
    required String username,
    String? imageUrl,
  }) {
    return UserAccount(
      userId: userId,
      createdAt: Timestamp.fromDate(DateTime.now()),
      lastOpenedAt: Timestamp.fromDate(DateTime.now()),
      isOnline: false,
      //
      fcmToken: null,
      voipToken: null,
      accountStatus: AccountStatus.normal,
      deviceInfo: null,
      //
      username: username,
      imageUrl: imageUrl,
      //
      bio: Bio(
        age: null,
        birthday: null,
        gender: null,
        interestedIn: null,
      ),
      aboutMe: "I am cringe, but I am free",
      currentStatus: CurrentStatus.defaultCurrentStatus(), topFriends: [],
      friendCount: 0,
      wishList: [],
      wantToDoList: [],
      canvasTheme: CanvasTheme.defaultCanvasTheme(),
      subscriptionStatus: SubscriptionStatus.none,
      //
      notificationSettings: NotificationSettings.defaultSettings(),
    );
  }
  isNull() {
    return userId == "nullUser";
  }

  UserAccount copyWith({
    String? imageUrl,
    String? fcmToken,
    String? voipToken,
    bool? isOnline,
    Timestamp? lastOpenedAt,
    bool? privateMode,
    Gender? gender,
    AccountStatus? status,
    DeviceInfo? deviceInfo,
    Bio? bio,
    String? aboutMe,
    CurrentStatus? currentStatus,
    List<String>? topFriends,
    CanvasTheme? canvasTheme,
    NotificationSettings? notificationSettings,
  }) {
    return UserAccount(
      userId: userId,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isOnline: isOnline ?? this.isOnline,
      //
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      accountStatus: accountStatus,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      //
      username: username,
      imageUrl: imageUrl ?? this.imageUrl,
      //
      bio: bio ?? this.bio,
      aboutMe: aboutMe ?? this.aboutMe,
      currentStatus: currentStatus ?? this.currentStatus,
      topFriends: topFriends ?? this.topFriends,
      friendCount: friendCount,
      wishList: wishList,
      wantToDoList: wantToDoList,
      canvasTheme: canvasTheme ?? this.canvasTheme,
      subscriptionStatus: subscriptionStatus,
      //
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

enum SubscriptionStatus {
  none,
  basic,
  pro,
  ultra,
}

class SubscriptionConverter {
  static SubscriptionStatus convertToSubScriptionStatus(String? str) {
    switch (str) {
      case "basic":
        return SubscriptionStatus.basic;
      case "pro":
        return SubscriptionStatus.pro;
      case "ultra":
        return SubscriptionStatus.ultra;
      default:
        return SubscriptionStatus.none;
    }
  }

  static String? convertToString(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.basic:
        return "basic";
      case SubscriptionStatus.pro:
        return "pro";
      case SubscriptionStatus.ultra:
        return "ultra";
      default:
        return null;
    }
  }
}
