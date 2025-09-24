/*import 'package:app/domain/value/server/server_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Server {
  final String id;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String lastMessage;
  final String senderId;
  final ServerType type;
  Map<String, bool> usersMap;
  Map<String, UserInfo> userInfoMap;

  Server({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.senderId,
    required this.type,
    required this.usersMap,
    required this.userInfoMap,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json["id"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      lastMessage: json["lastMessage"],
      senderId: json["senderId"],
      type: ServerTypeConverter.convertToServerType(json["type"]),
      usersMap: Map<String, bool>.from(json["usersMap"]),
      userInfoMap: (json["userInfoMap"] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, UserInfo.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}
 */
