import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_room.freezed.dart';
part 'voice_room.g.dart';

@freezed
class VoiceRoom with _$VoiceRoom {
  const factory VoiceRoom({
    required String id,
    required String name,
    required String subGenreId,
    required int participantCount,
    required int maxParticipants,
    required bool isActive,
    required String description,
  }) = _VoiceRoom;

  factory VoiceRoom.fromJson(Map<String, dynamic> json) => 
      _$VoiceRoomFromJson(json);
}