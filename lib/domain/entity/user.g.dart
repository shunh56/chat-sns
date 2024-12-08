// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAccountHiveAdapter extends TypeAdapter<UserAccountHive> {
  @override
  final int typeId = 0;

  @override
  UserAccountHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccountHive(
      updatedAt: fields[0] as Timestamp,
      type: fields[1] as ConnectionType,
      user: fields[2] as UserAccount,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccountHive obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.updatedAt)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccountHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAccountAdapter extends TypeAdapter<UserAccount> {
  @override
  final int typeId = 1;

  @override
  UserAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAccount(
      userId: fields[0] as String,
      createdAt: fields[1] as Timestamp,
      lastOpenedAt: fields[2] as Timestamp,
      isOnline: fields[3] as bool,
      usedCode: fields[4] as String?,
      fcmToken: fields[5] as String?,
      voipToken: fields[6] as String?,
      accountStatus: fields[7] as AccountStatus,
      deviceInfo: fields[8] as DeviceInfo?,
      name: fields[9] as String,
      username: fields[10] as String,
      imageUrl: fields[11] as String?,
      links: fields[12] as Links,
      bio: fields[13] as Bio,
      aboutMe: fields[14] as String,
      currentStatus: fields[15] as CurrentStatus,
      topFriends: (fields[16] as List).cast<String>(),
      wishList: (fields[17] as List).cast<String>(),
      tags: (fields[18] as List).cast<String>(),
      canvasTheme: fields[20] as CanvasTheme,
      subscriptionStatus: fields[19] as SubscriptionStatus,
      notificationData: fields[21] as NotificationData,
      privacy: fields[22] as Privacy,
      location: fields[23] as String,
      job: fields[24] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserAccount obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.lastOpenedAt)
      ..writeByte(3)
      ..write(obj.isOnline)
      ..writeByte(4)
      ..write(obj.usedCode)
      ..writeByte(5)
      ..write(obj.fcmToken)
      ..writeByte(6)
      ..write(obj.voipToken)
      ..writeByte(7)
      ..write(obj.accountStatus)
      ..writeByte(8)
      ..write(obj.deviceInfo)
      ..writeByte(9)
      ..write(obj.name)
      ..writeByte(10)
      ..write(obj.username)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.links)
      ..writeByte(13)
      ..write(obj.bio)
      ..writeByte(14)
      ..write(obj.aboutMe)
      ..writeByte(15)
      ..write(obj.currentStatus)
      ..writeByte(16)
      ..write(obj.topFriends)
      ..writeByte(17)
      ..write(obj.wishList)
      ..writeByte(18)
      ..write(obj.tags)
      ..writeByte(19)
      ..write(obj.subscriptionStatus)
      ..writeByte(20)
      ..write(obj.canvasTheme)
      ..writeByte(21)
      ..write(obj.notificationData)
      ..writeByte(22)
      ..write(obj.privacy)
      ..writeByte(23)
      ..write(obj.location)
      ..writeByte(24)
      ..write(obj.job);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceInfoAdapter extends TypeAdapter<DeviceInfo> {
  @override
  final int typeId = 3;

  @override
  DeviceInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceInfo(
      updatedAt: fields[0] as Timestamp,
      version: fields[1] as String,
      buildNumber: fields[2] as String,
      device: fields[3] as String,
      osVersion: fields[4] as String,
      platForm: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.updatedAt)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.buildNumber)
      ..writeByte(3)
      ..write(obj.device)
      ..writeByte(4)
      ..write(obj.osVersion)
      ..writeByte(5)
      ..write(obj.platForm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LinksAdapter extends TypeAdapter<Links> {
  @override
  final int typeId = 4;

  @override
  Links read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Links(
      line: fields[0] as Link,
      instagram: fields[1] as Link,
      x: fields[2] as Link,
    );
  }

  @override
  void write(BinaryWriter writer, Links obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.line)
      ..writeByte(1)
      ..write(obj.instagram)
      ..writeByte(2)
      ..write(obj.x);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinksAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 5;

  @override
  Link read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Link(
      isShown: fields[0] as bool,
      path: fields[1] as String?,
      urlScheme: fields[2] as String,
      assetString: fields[3] as String,
      title: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isShown)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.urlScheme)
      ..writeByte(3)
      ..write(obj.assetString)
      ..writeByte(4)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BioAdapter extends TypeAdapter<Bio> {
  @override
  final int typeId = 6;

  @override
  Bio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bio(
      age: fields[0] as int?,
      birthday: fields[1] as Timestamp?,
      gender: fields[2] as String?,
      interestedIn: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Bio obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.age)
      ..writeByte(1)
      ..write(obj.birthday)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.interestedIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrentStatusAdapter extends TypeAdapter<CurrentStatus> {
  @override
  final int typeId = 7;

  @override
  CurrentStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentStatus(
      tags: (fields[0] as List).cast<String>(),
      doing: fields[1] as String,
      eating: fields[2] as String,
      mood: fields[3] as String,
      nowAt: fields[4] as String,
      nextAt: fields[5] as String,
      nowWith: (fields[6] as List).cast<String>(),
      updatedAt: fields[7] as Timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentStatus obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.tags)
      ..writeByte(1)
      ..write(obj.doing)
      ..writeByte(2)
      ..write(obj.eating)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.nowAt)
      ..writeByte(5)
      ..write(obj.nextAt)
      ..writeByte(6)
      ..write(obj.nowWith)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CanvasThemeAdapter extends TypeAdapter<CanvasTheme> {
  @override
  final int typeId = 9;

  @override
  CanvasTheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CanvasTheme(
      bgColor: fields[0] as Color,
      profileTextColor: fields[1] as Color,
      profileSecondaryTextColor: fields[2] as Color,
      profileLinksColor: fields[3] as Color,
      profileAboutMeColor: fields[4] as Color,
      boxBgColor: fields[5] as Color,
      boxTextColor: fields[6] as Color,
      boxSecondaryTextColor: fields[7] as Color,
      boxWidth: fields[8] as double,
      boxRadius: fields[9] as double,
      iconGradientStartColor: fields[10] as Color,
      iconGradientEndColor: fields[11] as Color,
      iconStrokeWidth: fields[12] as double,
      iconRadius: fields[13] as double,
      iconHideBorder: fields[14] as bool,
      iconHideLevel: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CanvasTheme obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.bgColor)
      ..writeByte(1)
      ..write(obj.profileTextColor)
      ..writeByte(2)
      ..write(obj.profileSecondaryTextColor)
      ..writeByte(3)
      ..write(obj.profileLinksColor)
      ..writeByte(4)
      ..write(obj.profileAboutMeColor)
      ..writeByte(5)
      ..write(obj.boxBgColor)
      ..writeByte(6)
      ..write(obj.boxTextColor)
      ..writeByte(7)
      ..write(obj.boxSecondaryTextColor)
      ..writeByte(8)
      ..write(obj.boxWidth)
      ..writeByte(9)
      ..write(obj.boxRadius)
      ..writeByte(10)
      ..write(obj.iconGradientStartColor)
      ..writeByte(11)
      ..write(obj.iconGradientEndColor)
      ..writeByte(12)
      ..write(obj.iconStrokeWidth)
      ..writeByte(13)
      ..write(obj.iconRadius)
      ..writeByte(14)
      ..write(obj.iconHideBorder)
      ..writeByte(15)
      ..write(obj.iconHideLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationDataAdapter extends TypeAdapter<NotificationData> {
  @override
  final int typeId = 10;

  @override
  NotificationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationData(
      isActive: fields[0] as bool,
      directMessage: fields[1] as bool,
      currentStatusPost: fields[2] as bool,
      post: fields[3] as bool,
      voiceChat: fields[4] as bool,
      friendRequest: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isActive)
      ..writeByte(1)
      ..write(obj.directMessage)
      ..writeByte(2)
      ..write(obj.currentStatusPost)
      ..writeByte(3)
      ..write(obj.post)
      ..writeByte(4)
      ..write(obj.voiceChat)
      ..writeByte(5)
      ..write(obj.friendRequest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivacyAdapter extends TypeAdapter<Privacy> {
  @override
  final int typeId = 11;

  @override
  Privacy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Privacy(
      privateMode: fields[0] as bool,
      contentRange: fields[1] as PublicityRange,
      requestRange: fields[2] as PublicityRange,
    );
  }

  @override
  void write(BinaryWriter writer, Privacy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.privateMode)
      ..writeByte(1)
      ..write(obj.contentRange)
      ..writeByte(2)
      ..write(obj.requestRange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountStatusAdapter extends TypeAdapter<AccountStatus> {
  @override
  final int typeId = 2;

  @override
  AccountStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccountStatus.normal;
      case 1:
        return AccountStatus.banned;
      case 2:
        return AccountStatus.deleted;
      case 3:
        return AccountStatus.freezed;
      default:
        return AccountStatus.normal;
    }
  }

  @override
  void write(BinaryWriter writer, AccountStatus obj) {
    switch (obj) {
      case AccountStatus.normal:
        writer.writeByte(0);
        break;
      case AccountStatus.banned:
        writer.writeByte(1);
        break;
      case AccountStatus.deleted:
        writer.writeByte(2);
        break;
      case AccountStatus.freezed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionStatusAdapter extends TypeAdapter<SubscriptionStatus> {
  @override
  final int typeId = 8;

  @override
  SubscriptionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionStatus.none;
      case 1:
        return SubscriptionStatus.basic;
      case 2:
        return SubscriptionStatus.pro;
      case 3:
        return SubscriptionStatus.ultra;
      default:
        return SubscriptionStatus.none;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionStatus obj) {
    switch (obj) {
      case SubscriptionStatus.none:
        writer.writeByte(0);
        break;
      case SubscriptionStatus.basic:
        writer.writeByte(1);
        break;
      case SubscriptionStatus.pro:
        writer.writeByte(2);
        break;
      case SubscriptionStatus.ultra:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PublicityRangeAdapter extends TypeAdapter<PublicityRange> {
  @override
  final int typeId = 12;

  @override
  PublicityRange read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PublicityRange.onlyFriends;
      case 1:
        return PublicityRange.friendOfFriend;
      case 2:
        return PublicityRange.public;
      default:
        return PublicityRange.onlyFriends;
    }
  }

  @override
  void write(BinaryWriter writer, PublicityRange obj) {
    switch (obj) {
      case PublicityRange.onlyFriends:
        writer.writeByte(0);
        break;
      case PublicityRange.friendOfFriend:
        writer.writeByte(1);
        break;
      case PublicityRange.public:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicityRangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConnectionTypeAdapter extends TypeAdapter<ConnectionType> {
  @override
  final int typeId = 13;

  @override
  ConnectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConnectionType.me;
      case 1:
        return ConnectionType.friend;
      case 2:
        return ConnectionType.friendOfFriend;
      case 3:
        return ConnectionType.others;
      default:
        return ConnectionType.me;
    }
  }

  @override
  void write(BinaryWriter writer, ConnectionType obj) {
    switch (obj) {
      case ConnectionType.me:
        writer.writeByte(0);
        break;
      case ConnectionType.friend:
        writer.writeByte(1);
        break;
      case ConnectionType.friendOfFriend:
        writer.writeByte(2);
        break;
      case ConnectionType.others:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
