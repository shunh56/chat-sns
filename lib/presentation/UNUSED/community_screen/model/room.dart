import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String communityId,
    required String title,
    required String userId,
    required int currentParticipants,
    required int maxParticipants,
    required DateTime createdAt,
    required List<String> tags,
    required bool isLive,
    required List<String> joinedUserIds,
    List<String>? participantImageUrls,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}
