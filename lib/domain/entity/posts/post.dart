import 'package:app/domain/entity/posts/timeline_post.dart';

class Post extends PostBase {
  final String text;
  final List<String> mediaUrls;
  final List<double> aspectRatios;
  final bool isPublic;

  Post({
    required this.text,
    required this.mediaUrls,
    required this.aspectRatios,
    required this.isPublic,
    //
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
    required super.likeCount,
    required super.replyCount,
    required super.isDeletedByUser,
    required super.isDeletedByAdmin,
    required super.isDeletedByModerator,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      text: json["text"],
      mediaUrls: List<String>.from(json["mediaUrls"]),
      aspectRatios: List<double>.from(json["aspectRatios"]),
      //
      id: json["id"],
      userId: json["userId"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"] ?? json["createdAt"],
      likeCount: json["likeCount"] ?? 0,
      replyCount: json["replyCount"],
      isDeletedByUser: json["isDeletedByUser"],
      isDeletedByAdmin: json["isDeletedByAdmin"],
      isDeletedByModerator: json["isDeletedByModerator"],
      isPublic: json["isPublic"] ?? false,
    );
  }
  Post copyWith({
    int? likeCount,
    int? replyCount,
    bool? isDeletedByUser,
    bool? isDeletedByAdmin,
    bool? isDeletedByModerator,
  }) {
    return Post(
      text: text,
      mediaUrls: mediaUrls,
      aspectRatios: aspectRatios,
      //
      id: id,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isDeletedByUser: isDeletedByUser ?? this.isDeletedByUser,
      isDeletedByAdmin: isDeletedByAdmin ?? this.isDeletedByAdmin,
      isDeletedByModerator: isDeletedByModerator ?? this.isDeletedByModerator,
      isPublic: isPublic,
    );
  }
}

/*リストの作成とクラスの識別
これで、PostBase型のリストにCurrentStatusPostとPostのインスタンスを混在させることができます。また、各エレメントのタイプを識別するためにはis演算子を使って型チェックを行います。

dart
コードをコピーする
void main() {
  List<PostBase> posts = [];

  // Sample data
  posts.add(CurrentStatusPost(
    id: '1',
    userId: 'user1',
    createdAt: Timestamp.now(),
    before: CurrentStatus(...),  // Assuming CurrentStatus constructor
    after: CurrentStatus(...),
    likeCount: 10,
    replyCount: 5,
  ));

  posts.add(Post(
    id: '2',
    userId: 'user2',
    createdAt: Timestamp.now(),
    text: 'Hello world!',
    mediaUrls: ['url1', 'url2'],
    aspectRatios: [1.0, 1.5],
    likeCount: 20,
    replyCount: 10,
    isDeletedByUser: false,
    isDeletedByAdmin: false,
    isDeletedByModerator: false,
  ));

  // Loop through the list and check the type
  for (var post in posts) {
    if (post is CurrentStatusPost) {
      print('This is a CurrentStatusPost: ${post.before} -> ${post.after}');
    } else if (post is Post) {
      print('This is a Post: ${post.text}');
    }
  }
} */