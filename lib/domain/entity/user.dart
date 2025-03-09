import 'dart:math';

import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/value/user/gender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserAccountHive extends HiveObject {
  @HiveField(0)
  final Timestamp updatedAt;

  @HiveField(1)
  final ConnectionType type;

  @HiveField(2)
  final UserAccount user;

  UserAccountHive({
    required this.updatedAt,
    required this.type,
    required this.user,
  });

  UserAccount toUserAccount() {
    return user;
  }
}

@HiveType(typeId: 1)
class UserAccount extends HiveObject {
  //auto
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final Timestamp createdAt;
  @HiveField(2)
  final Timestamp lastOpenedAt;
  @HiveField(3)
  final bool isOnline;

  //backend
  @HiveField(4)
  final String? usedCode;
  @HiveField(5)
  final String? fcmToken;
  @HiveField(6)
  final String? voipToken;

  @HiveField(7)
  final AccountStatus accountStatus;
  @HiveField(8)
  final DeviceInfo? deviceInfo;

  //info
  @HiveField(9)
  final String name;
  @HiveField(10)
  final String username;
  @HiveField(11)
  String? imageUrl;
  //profile info

  @HiveField(12)
  final Links links;
  @HiveField(13)
  final Bio bio;
  @HiveField(14)
  final String aboutMe;
  @HiveField(15)
  final CurrentStatus currentStatus;
  @HiveField(16)
  final List<String> topFriends;

  @HiveField(17)
  final List<String> wishList;
  @HiveField(18)
  final List<String> tags;
  @HiveField(19)
  final SubscriptionStatus subscriptionStatus;
  //canvas
  @HiveField(20)
  final CanvasTheme canvasTheme;
  //settings
  @HiveField(21)
  final NotificationData notificationData;
  @HiveField(22)
  final Privacy privacy;
  @HiveField(23)
  final String location;
  @HiveField(24)
  final String job;

  @HiveField(25)
  final List<String> friendIds;

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
    required this.tags,
    //
    required this.canvasTheme,
    required this.subscriptionStatus,
    //
    required this.notificationData,
    required this.privacy,
    required this.location,
    required this.job,
    required this.friendIds,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
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
      tags: List<String>.from(json['profile']['tags'] ?? []),
      canvasTheme: CanvasTheme.fromJson(json["canvasTheme"]),
      subscriptionStatus: SubscriptionConverter.convertToSubScriptionStatus(
        json["subscription"],
      ),

      //
      notificationData: NotificationData.fromJson(json["notificationData"]),
      privacy: Privacy.fromJson(
        json["privacy"],
      ),
      location: json["profile"]["location"] ?? "", // 追加
      job: json["profile"]["job"] ?? "",
      friendIds: json["friendIds"] ?? [],
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
        "tags": tags,
        "location": location,
        "job": job,
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
      tags: [],
      canvasTheme: CanvasTheme.defaultCanvasTheme(),
      subscriptionStatus: SubscriptionStatus.none,
      //
      notificationData: NotificationData.defaultSettings(),
      privacy: Privacy.defaultPrivacy(),
      location: "",
      job: "",
      friendIds: [],
    );
  }

  static List<String> defaultAboutMeTemplates = [
    "人生の目標は「寝ても覚めてもアイスクリーム」",
    "趣味は考えすぎて頭から煙を出すこと",
    "真面目に働いて不真面目に遊ぶスペシャリスト",
    "好きな食べ物は炭水化物に炭水化物を添えたもの",
    "運動不足を心配してたら運が不足してました",
    "寝る前のスマホが生きがい（そして今）",
    "天才肩こり師（経験27年）",
    "諦めたらそこで甘いもの食べ時です",
    "カロリーは気にしない主義（気にしたら負け）",
    "昼寝の時間を確保するために早起きします",
    "食べることとベッドの往復が日課です",
    "プロ級の積読家です（読書じゃないよ積読だよ）",
    "お布団から出られない重度の引き籠もり",
    "休日は布団と一心同体になります",
  ];

  UserAccount copyWith({
    Timestamp? lastOpenedAt,
    bool? isOnline,
    //
    String? usedCode,
    String? fcmToken,
    String? voipToken,
    AccountStatus? accountStatus,
    //
    String? name,
    String? imageUrl,
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
    String? location,
    String? job,
    List<String>? tags,
    List<String>? friendIds,
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
      accountStatus: accountStatus ?? this.accountStatus,
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
      tags: tags ?? this.tags,
      canvasTheme: canvasTheme ?? this.canvasTheme,
      subscriptionStatus: subscriptionStatus,
      //
      notificationData: notificationData ?? this.notificationData,
      privacy: privacy ?? this.privacy,
      location: location ?? this.location,
      job: job ?? this.job,
      friendIds: friendIds ?? this.friendIds,
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
      aboutMe: defaultAboutMeTemplates[
          Random().nextInt(defaultAboutMeTemplates.length)],
      currentStatus: currentStatus,
      topFriends: topFriends,

      wishList: wishList,
      tags: tags,
      canvasTheme: canvasTheme,
      subscriptionStatus: subscriptionStatus,
      //
      notificationData: notificationData,
      privacy: privacy,
      location: "",
      job: "",
      friendIds: [],
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
        DateTime.now().difference(lastOpenedAt.toDate()).inMinutes < 3;
  }

  String get badgeStatus {
    if (greenBadge) {
      return "オンライン";
    } else {
      if (DateTime.now().difference(lastOpenedAt.toDate()).inHours < 8) {
        return "${lastOpenedAt.xxAgo}にオンライン";
      } else {
        return "最終ログイン: ${lastOpenedAt.xxAgo}";
      }
    }
  }

  bool get isAdmin {
    final admins = [
      "Bp9DWVP8PGXEZmcdx5LZrqL5apw2",
      "AJNL9L1qGVhlDAmiqFaH7nikSOX2",
    ];
    return admins.contains(userId);
  }

  bool get isMe {
    return userId == FirebaseAuth.instance.currentUser!.uid;
  }
}

//
@HiveType(typeId: 2)
enum AccountStatus {
  @HiveField(0)
  normal,
  @HiveField(1)
  banned,
  @HiveField(2)
  deleted,
  @HiveField(3)
  freezed,
}

@HiveType(typeId: 3)
class DeviceInfo extends HiveObject {
  @HiveField(0)
  final Timestamp updatedAt;
  @HiveField(1)
  final String version;
  @HiveField(2)
  final String buildNumber;
  @HiveField(3)
  final String device;
  @HiveField(4)
  final String osVersion;
  @HiveField(5)
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

@HiveType(typeId: 4)
class Links extends HiveObject {
  @HiveField(0)
  final Link line;
  @HiveField(1)
  final Link instagram;
  @HiveField(2)
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

@HiveType(typeId: 5)
class Link {
  @HiveField(0)
  final bool isShown;
  @HiveField(1)
  final String? path;
  @HiveField(2)
  final String urlScheme;
  @HiveField(3)
  final String assetString;
  @HiveField(4)
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

@HiveType(typeId: 6)
class Bio {
  @HiveField(0)
  final int? age;
  @HiveField(1)
  final Timestamp? birthday;
  @HiveField(2)
  final String? gender;
  @HiveField(3)
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

@HiveType(typeId: 7)
class CurrentStatus {
  @HiveField(0)
  final List<String> tags;
  //final String? listening;
  //final String? watching;
  //final String? reading;
  @HiveField(1)
  final String doing;
  @HiveField(2)
  final String eating;
  @HiveField(3)
  final String mood;
  @HiveField(4)
  final String nowAt;
  @HiveField(5)
  final String nextAt;
  @HiveField(6)
  final List<String> nowWith;
  @HiveField(7)
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

@HiveType(typeId: 8)
enum SubscriptionStatus {
  @HiveField(0)
  none,
  @HiveField(1)
  basic,
  @HiveField(2)
  pro,
  @HiveField(3)
  ultra,
}

@HiveType(typeId: 9)
class CanvasTheme {
  //profile
  @HiveField(0)
  final Color bgColor; // = Color(Colors.white.value);
  @HiveField(1)
  final Color profileTextColor; // = Color(Colors.black.value);
  @HiveField(2)
  final Color profileSecondaryTextColor; // = Color(Colors.black45.value);
  @HiveField(3)
  final Color profileLinksColor;
  @HiveField(4)
  final Color profileAboutMeColor;
  //box
  @HiveField(5)
  final Color boxBgColor; // = Color(Colors.black12.value);
  @HiveField(6)
  final Color boxTextColor; // = Color(Colors.black38.value);
  @HiveField(7)
  final Color boxSecondaryTextColor; // = Color(Colors.black54.value);

  @HiveField(8)
  final double boxWidth; // = 4.0;
  @HiveField(9)
  final double boxRadius; // = 12.0;
  //icon
  @HiveField(10)
  final Color iconGradientStartColor; // = Color(Colors.purpleAccent.value);
  @HiveField(11)
  final Color iconGradientEndColor; // = Color(Colors.cyan.value);
  @HiveField(12)
  final double iconStrokeWidth; // = 2.0;
  @HiveField(13)
  final double iconRadius; // = 24.0;
  @HiveField(14)
  final bool iconHideBorder; // = false;
  @HiveField(15)
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
      profileLinksColor: ThemeColor.highlight,
      profileAboutMeColor: ThemeColor.text,
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
      "profileLinksColor": profileLinksColor.value,
      "profileAboutMeColor": profileAboutMeColor.value,

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

@HiveType(typeId: 10)
class NotificationData {
  @HiveField(0)
  final bool isActive;
  @HiveField(1)
  final bool directMessage;
  @HiveField(2)
  final bool currentStatusPost;
  @HiveField(3)
  final bool post;
  @HiveField(4)
  final bool voiceChat;
  @HiveField(5)
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

@HiveType(typeId: 11)
class Privacy {
  @HiveField(0)
  final bool privateMode;
  @HiveField(1)
  final PublicityRange contentRange;
  @HiveField(2)
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

@HiveType(typeId: 12)
enum PublicityRange {
  @HiveField(0)
  onlyFriends,
  @HiveField(1)
  friendOfFriend,
  @HiveField(2)
  public,
}

@HiveType(typeId: 13)
enum ConnectionType {
  @HiveField(0)
  me,
  @HiveField(1)
  friend,
  @HiveField(2)
  friendOfFriend,
  @HiveField(3)
  others,
}

//

class TimestampAdapter extends TypeAdapter<Timestamp> {
  @override
  final int typeId = 100; // ユニークなtypeIdを設定

  @override
  Timestamp read(BinaryReader reader) {
    final int seconds = reader.readInt();
    final int nanoseconds = reader.readInt();
    return Timestamp(seconds, nanoseconds);
  }

  @override
  void write(BinaryWriter writer, Timestamp obj) {
    writer.writeInt(obj.seconds);
    writer.writeInt(obj.nanoseconds);
  }
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 101; // ユニークなtypeIdを設定

  @override
  Color read(BinaryReader reader) {
    // ARGB値を整数として読み込む
    final int colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    // ColorオブジェクトのARGB値を整数として書き込む
    writer.writeInt(obj.value);
  }
}

//CONVERTER
class AccountStatusConverter {
  static AccountStatus convertToStatus(String? status) {
    switch (status) {
      case "normal":
        return AccountStatus.normal;
      case "banned":
        return AccountStatus.banned;
      case "deleted":
        return AccountStatus.deleted;
      case "freezed":
        return AccountStatus.freezed;
      default:
        return AccountStatus.normal;
    }
  }

  static String convertToString(AccountStatus status) {
    switch (status) {
      case AccountStatus.normal:
        return "normal";
      case AccountStatus.banned:
        return "banned";
      case AccountStatus.deleted:
        return "deleted";
      case AccountStatus.freezed:
        return "freezed";
      default:
        return "normal";
    }
  }
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
