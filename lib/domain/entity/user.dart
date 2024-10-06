import 'package:app/core/utils/theme.dart';
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

class Link {
  final bool isShown;
  final String? path;
  final String urlScheme;
  final String assetString;
  final String title;
  Link({
    required this.isShown,
    required this.path,
    required this.urlScheme,
    required this.assetString,
    required this.title,
  });

  factory Link.fromJson(
    Map<String, dynamic>? json,
    String urlSheme,
    String assetString,
    String title,
  ) {
    return Link(
      isShown: json?["isShown"] ?? false,
      path: json?["path"],
      urlScheme: urlSheme,
      assetString: assetString,
      title: title,
    );
  }
  Link copyWith({bool? isShown, String? path}) {
    return Link(
      isShown: isShown ?? this.isShown,
      path: path ?? this.path,
      urlScheme: urlScheme,
      assetString: assetString,
      title: title,
    );
  }

  toJson() {
    return {
      "isShown": isShown,
      "path": path,
    };
  }

  String? get url {
    if (path == null) return null;
    return urlScheme + path!;
  }
}

class Links {
  final Link line;
  final Link instagram;
  final Link x;

  Links({
    required this.line,
    required this.instagram,
    required this.x,
  });

  factory Links.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Links.defaultLinks();
    }
    return Links(
      line: Link.fromJson(
        json["line"],
        "https://line.me/",
        Images.lineIcon,
        "Line",
      ),
      instagram: Link.fromJson(
        json["instagram"],
        "https://www.instagram.com/",
        Images.instagramIcon,
        "Instagram",
      ),
      x: Link.fromJson(
        json["x"],
        "https://x.com/",
        Images.xIcon,
        "X",
      ),
    );
  }

  factory Links.defaultLinks() {
    return Links(
      line: Link.fromJson(
        null,
        "https://line.me/",
        Images.lineIcon,
        "Line",
      ),
      instagram: Link.fromJson(
        null,
        "https://www.instagram.com/",
        Images.instagramIcon,
        "Instagram",
      ),
      x: Link.fromJson(
        null,
        "https://x.com/",
        Images.xIcon,
        "X",
      ),
    );
  }

  toJson() {
    return {
      "line": line.toJson(),
      "instagram": instagram.toJson(),
      "x": x.toJson(),
    };
  }

  Links copyWith({Link? line, Link? instagram, Link? x}) {
    return Links(
      line: line ?? this.line,
      instagram: instagram ?? this.instagram,
      x: x ?? this.x,
    );
  }

  bool get isShown {
    bool lineShown = line.isShown;
    bool igShown = instagram.isShown;
    bool xShown = x.isShown;
    return lineShown || igShown || xShown;
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
  final Timestamp updatedAt;

  CurrentStatus({
    required this.tags,
    required this.doing,
    required this.eating,
    required this.mood,
    required this.nowAt,
    required this.nextAt,
    required this.nowWith,
    required this.updatedAt,
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
      updatedAt: json["updatedAt"] ??
          Timestamp.fromDate(
            DateTime.now().subtract(
              const Duration(days: 1),
            ),
          ),
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
      "updatedAt": updatedAt,
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
      updatedAt: Timestamp.now(),
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
      updatedAt: Timestamp.now(),
    );
  }

  bool get updatedRecently {
    return (DateTime.now().difference(updatedAt.toDate()).inHours < 4 &&
        bubbles.isNotEmpty);
  }

  List<String> get bubbles {
    List<String> list = [];
    if (doing.isNotEmpty) list.add(doing);
    if (eating.isNotEmpty) list.add(eating);
    if (mood.isNotEmpty) list.add(mood);
    if (nowAt.isNotEmpty) list.add(nowAt);
    if (nextAt.isNotEmpty) list.add(nextAt);
    return list;
  }
}

class CanvasTheme {
  //profile
  final Color bgColor; // = Color(Colors.white.value);
  final Color profileTextColor; // = Color(Colors.black.value);
  final Color profileSecondaryTextColor; // = Color(Colors.black45.value);
  final Color profileLinksColor;
  final Color profileAboutMeColor;
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
    required this.profileLinksColor,
    required this.profileAboutMeColor,

    //
    required this.boxBgColor,
    required this.boxTextColor,
    required this.boxSecondaryTextColor,
    //
    required this.boxWidth,
    required this.boxRadius,
    //
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
      //
      bgColor: json["bgColor"] != null
          ? Color(json["bgColor"])
          : ThemeColor.background,
      profileTextColor: Color(json["profileTextColor"]),
      profileSecondaryTextColor: Color(json["profileSecondaryTextColor"]),
      profileLinksColor: json["profileLinksColor"] != null
          ? Color(json["profileLinksColor"])
          : Colors.white,
      profileAboutMeColor: json["profileAboutMeColor"] != null
          ? Color(json["profileAboutMeColor"])
          : Colors.white,

      //
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
      bgColor: ThemeColor.background,
      profileTextColor: ThemeColor.text,
      profileSecondaryTextColor: ThemeColor.subText,
      profileLinksColor: Colors.white,
      profileAboutMeColor: Colors.white,
      boxBgColor: ThemeColor.accent,
      boxTextColor: ThemeColor.subText,
      boxSecondaryTextColor: ThemeColor.text,
      boxWidth: 0.4,
      boxRadius: 12.0,
      iconGradientStartColor: Color(Colors.purpleAccent.value),
      iconGradientEndColor: Color(Colors.cyan.value),
      iconStrokeWidth: 2.0,
      iconRadius: 12.0,
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
    Color? profileLinksColor,
    Color? profileAboutMeColor,
    //
    Color? boxBgColor,
    Color? boxTextColor,
    Color? boxSecondaryTextColor,
    //
    double? boxWidth,
    double? boxRadius,
    //
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
      profileLinksColor: profileLinksColor ?? this.profileLinksColor,
      profileAboutMeColor: profileAboutMeColor ?? this.profileAboutMeColor,
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

class NotificationData {
  final bool isActive;
  final bool directMessage;
  final bool currentStatusPost;
  final bool post;
  final bool voiceChat;
  final bool friendRequest;
  NotificationData({
    required this.isActive,
    required this.directMessage,
    required this.currentStatusPost,
    required this.post,
    required this.voiceChat,
    required this.friendRequest,
  });

  factory NotificationData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return NotificationData.defaultSettings();
    }
    return NotificationData(
      isActive: json["isActive"] ?? true,
      directMessage: json["directMessage"] ?? true,
      currentStatusPost: json["currentStatusPost"] ?? true,
      post: json["post"] ?? true,
      voiceChat: json["voiceChat"] ?? true,
      friendRequest: json["friendRequest"] ?? true,
    );
  }
  factory NotificationData.defaultSettings() {
    return NotificationData(
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

  NotificationData copyWith({
    bool? isActive,
    bool? directMessage,
    bool? currentStatusPost,
    bool? post,
    bool? voiceChat,
    bool? friendRequest,
  }) {
    return NotificationData(
      isActive: isActive ?? this.isActive,
      directMessage: directMessage ?? this.directMessage,
      currentStatusPost: currentStatusPost ?? this.currentStatusPost,
      post: post ?? this.post,
      voiceChat: voiceChat ?? this.voiceChat,
      friendRequest: friendRequest ?? this.friendRequest,
    );
  }
}

class Privacy {
  final bool privateMode;
  final PublicityRange contentRange;
  final PublicityRange requestRange;

  Privacy({
    required this.privateMode,
    required this.contentRange, // friends, friendOfFriend
    required this.requestRange, // friends, friendOfFriend , public
  });

  factory Privacy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Privacy.defaultPrivacy();
    return Privacy(
      privateMode: json["privateMode"],
      contentRange: PublicityRangeConverter.fromString(json["contentRange"]),
      requestRange: PublicityRangeConverter.fromString(json["requestRange"]),
    );
  }

  factory Privacy.defaultPrivacy() {
    return Privacy(
      privateMode: false,
      contentRange: PublicityRange.friendOfFriend,
      requestRange: PublicityRange.public,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "privateMode": privateMode,
      "contentRange": PublicityRangeConverter.convertToString(contentRange),
      "requestRange": PublicityRangeConverter.convertToString(requestRange),
    };
  }

  Privacy copyWith({
    bool? privateMode,
    PublicityRange? contentRange,
    PublicityRange? requestRange,
  }) {
    return Privacy(
      privateMode: privateMode ?? this.privateMode,
      contentRange: contentRange ?? this.contentRange,
      requestRange: requestRange ?? this.requestRange,
    );
  }
}

enum PublicityRange {
  onlyFriends,
  friendOfFriend,
  public,
}

class PublicityRangeConverter {
  static PublicityRange fromString(String? str) {
    switch (str) {
      case "onlyFriends":
        return PublicityRange.onlyFriends;
      case "friendOfFriend":
        return PublicityRange.friendOfFriend;
      case "public":
        return PublicityRange.public;
      default:
        return PublicityRange.public;
    }
  }

  static String convertToString(PublicityRange range) {
    switch (range) {
      case PublicityRange.onlyFriends:
        return "onlyFriends";
      case PublicityRange.friendOfFriend:
        return "friendOfFriend";
      case PublicityRange.public:
        return "public";
      default:
        return "public";
    }
  }
}

class UserAccount {
  //auto
  final String userId;
  final Timestamp createdAt;
  final Timestamp lastOpenedAt;
  final bool isOnline;

  //backend
  final String? usedCode;
  final String? fcmToken;
  final String? voipToken;

  final AccountStatus accountStatus;
  final DeviceInfo? deviceInfo;

  //info
  final String name;
  final String username;
  String? imageUrl;
  //profile info

  final Links links;
  final Bio bio;
  final String aboutMe;
  final CurrentStatus currentStatus;
  final List<String> topFriends;

  final List<String> wishList;
  final List<String> wantToDoList;
  final SubscriptionStatus subscriptionStatus;
  //canvas
  final CanvasTheme canvasTheme;
  //settings
  final NotificationData notificationData;
  final Privacy privacy;

  UserAccount({
    required this.userId,
    required this.createdAt,
    required this.lastOpenedAt,
    required this.isOnline,
    //
    required this.usedCode,
    required this.fcmToken,
    required this.voipToken,
    required this.accountStatus,
    required this.deviceInfo,
    //
    required this.name,
    required this.username,
    required this.imageUrl,
    //
    required this.links,
    required this.bio,
    required this.aboutMe,
    required this.currentStatus,
    required this.topFriends,
    required this.wishList,
    required this.wantToDoList,
    //
    required this.canvasTheme,
    required this.subscriptionStatus,
    //
    required this.notificationData,
    required this.privacy,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    /*if (json["username"] == null) {
      FirebaseAuth.instance.signOut();
    } */
    return UserAccount(
      userId: json["userId"],
      createdAt: json["createdAt"],
      lastOpenedAt: json["lastOpenedAt"],
      isOnline: json["isOnline"],
      //
      usedCode: json["usedCode"],
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
      name: json["name"] ?? "DEFAULT NAME",
      username: "${json["username"]}",
      imageUrl: json["imageUrl"],

      //
      links: Links.fromJson(json["links"]),
      bio: Bio.fromJson(json["profile"]["bio"]),
      aboutMe: json["profile"]["aboutMe"],
      currentStatus: CurrentStatus.fromJson(json["profile"]["currentStatus"]),
      topFriends: List<String>.from(json["profile"]["topFriends"]),

      wishList: List<String>.from(json['profile']['wishList'] ?? []),
      wantToDoList: List<String>.from(json['profile']['wantToDoList'] ?? []),
      canvasTheme: CanvasTheme.fromJson(json["canvasTheme"]),
      subscriptionStatus: SubscriptionConverter.convertToSubScriptionStatus(
        json["subscription"],
      ),

      //
      notificationData: NotificationData.fromJson(json["notificationData"]),
      privacy: Privacy.fromJson(
        json["privacy"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "createdAt": createdAt,
      "lastOpenedAt": lastOpenedAt,
      "isOnline": isOnline,

      //
      "usedCode": usedCode,
      "fcmToken": fcmToken,
      "voipToken": voipToken,
      "accountStatus": AccountStatusConverter.convertToString(accountStatus),
      "deviceInfo": deviceInfo?.toJson(),

      //
      "name": name,
      "username": username,
      "imageUrl": imageUrl,

      //
      "links": links.toJson(),
      "profile": {
        "bio": bio.toJson(),
        "aboutMe": aboutMe,
        "currentStatus": currentStatus.toJson(),
        "topFriends": topFriends,
        "wishList": wishList,
        "wantToDoList": wantToDoList,
      },
      //canvas
      "canvasTheme": canvasTheme.toJson(),
      "notificationData": notificationData.toJson(),
      "privacy": privacy.toJson()
    };
  }

  factory UserAccount.nullUser() {
    return UserAccount(
      userId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: Timestamp.now(),
      lastOpenedAt: Timestamp.now(),
      isOnline: false,
      //
      usedCode: null,
      fcmToken: null,
      voipToken: null,
      accountStatus: AccountStatus.normal,
      deviceInfo: null,
      //
      name: "null",
      username: "null",
      imageUrl: null,
      links: Links.defaultLinks(),
      bio: Bio.defaultBio(),
      aboutMe: "",
      currentStatus: CurrentStatus.defaultCurrentStatus(), topFriends: [],

      wishList: [],
      wantToDoList: [],
      canvasTheme: CanvasTheme.defaultCanvasTheme(),
      subscriptionStatus: SubscriptionStatus.none,
      //
      notificationData: NotificationData.defaultSettings(),
      privacy: Privacy.defaultPrivacy(),
    );
  }

  factory UserAccount.create({
    required String userId,
    required String username,
    required String name,
    String? imageUrl,
  }) {
    return UserAccount(
      userId: userId,
      createdAt: Timestamp.fromDate(DateTime.now()),
      lastOpenedAt: Timestamp.fromDate(DateTime.now()),
      isOnline: false,
      //
      usedCode: null,
      fcmToken: null,
      voipToken: null,
      accountStatus: AccountStatus.normal,
      deviceInfo: null,
      //
      name: name,
      username: username,
      imageUrl: imageUrl,
      //
      links: Links.defaultLinks(),
      bio: Bio(
        age: null,
        birthday: null,
        gender: null,
        interestedIn: null,
      ),
      aboutMe: "I am cringe, but I am free",
      currentStatus: CurrentStatus.defaultCurrentStatus(), topFriends: [],

      wishList: [],
      wantToDoList: [],
      canvasTheme: CanvasTheme.defaultCanvasTheme(),
      subscriptionStatus: SubscriptionStatus.none,
      //
      notificationData: NotificationData.defaultSettings(),
      privacy: Privacy.defaultPrivacy(),
    );
  }
  isNull() {
    return username == "null";
  }

  UserAccount copyWith({
    String? name,
    String? imageUrl,
    String? fcmToken,
    String? usedCode,
    String? voipToken,
    bool? isOnline,
    Timestamp? lastOpenedAt,
    bool? privateMode,
    Gender? gender,
    AccountStatus? status,
    DeviceInfo? deviceInfo,
    Links? links,
    Bio? bio,
    String? aboutMe,
    CurrentStatus? currentStatus,
    List<String>? topFriends,
    CanvasTheme? canvasTheme,
    NotificationData? notificationData,
    Privacy? privacy,
  }) {
    return UserAccount(
      userId: userId,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isOnline: isOnline ?? this.isOnline,

      //
      usedCode: usedCode ?? this.usedCode,
      fcmToken: fcmToken ?? this.fcmToken,
      voipToken: voipToken ?? this.voipToken,
      accountStatus: accountStatus,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      //
      name: name ?? this.name,
      username: username,
      imageUrl: imageUrl ?? this.imageUrl,
      //
      links: links ?? this.links,
      bio: bio ?? this.bio,
      aboutMe: aboutMe ?? this.aboutMe,
      currentStatus: currentStatus ?? this.currentStatus,
      topFriends: topFriends ?? this.topFriends,
      wishList: wishList,
      wantToDoList: wantToDoList,
      canvasTheme: canvasTheme ?? this.canvasTheme,
      subscriptionStatus: subscriptionStatus,
      //
      notificationData: notificationData ?? this.notificationData,
      privacy: privacy ?? this.privacy,
    );
  }

  UserAccount create({
    required String userId,
    required String username,
    required String name,
    String? imageUrl,
  }) {
    return UserAccount(
      userId: userId,
      createdAt: createdAt,
      lastOpenedAt: lastOpenedAt,
      isOnline: isOnline,

      //
      usedCode: usedCode,
      fcmToken: fcmToken,
      voipToken: voipToken,
      accountStatus: accountStatus,
      deviceInfo: deviceInfo,
      //
      name: name,
      username: username,
      imageUrl: imageUrl,
      //
      links: links,
      bio: bio,
      aboutMe: aboutMe,
      currentStatus: currentStatus,
      topFriends: topFriends,

      wishList: wishList,
      wantToDoList: wantToDoList,
      canvasTheme: canvasTheme,
      subscriptionStatus: subscriptionStatus,
      //
      notificationData: notificationData,
      privacy: privacy,
    );
  }

  bool get validCode {
    return (usedCode != null &&
        usedCode != "WAITING" &&
        usedCode != "NO_CODE" &&
        usedCode?.length == 8);
  }

  bool get greenBadge {
    return isOnline &&
        DateTime.now().difference(lastOpenedAt.toDate()).inMinutes < 10;
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
