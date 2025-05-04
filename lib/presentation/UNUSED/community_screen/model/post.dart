import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String userId,
    required String userName,
    required String userImageUrl,
    required String content,
    required DateTime createdAt,
    required int likeCount,
    required int commentCount,
    List<String>? tags,
    List<String>? imageUrls,
    bool? isUrgent,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
