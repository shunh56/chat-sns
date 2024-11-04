import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_genre.freezed.dart';
part 'sub_genre.g.dart';

@freezed
class SubGenre with _$SubGenre {
  const factory SubGenre({
    required String id,
    required String name,
    required String description,
    required String iconUrl,
    required String color,
    required int postCount,
    required int dailyPostCount,
    required int memberCount,
    required List<String> activeTopics,
    required int order,
  }) = _SubGenre;

  factory SubGenre.fromJson(Map<String, dynamic> json) =>
      _$SubGenreFromJson(json);
}
