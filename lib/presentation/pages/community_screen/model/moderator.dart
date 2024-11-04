import 'package:freezed_annotation/freezed_annotation.dart';

part 'moderator.freezed.dart';
part 'moderator.g.dart';

@freezed
class Moderator with _$Moderator {
  const factory Moderator({
    required String id,
    required String name,
    required String imageUrl,
    required String role,
    required DateTime joinedAt,
  }) = _Moderator;

  factory Moderator.fromJson(Map<String, dynamic> json) =>
      _$ModeratorFromJson(json);
}
