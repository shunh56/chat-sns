class Thread {
  final String id;
  final String title;
  final String subTitle;
  final String imageUrl;
  final String thumbnailImageUrl;

  final int postCount;
  final int followerCount;

  Thread({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.imageUrl,
    required this.thumbnailImageUrl,
    required this.followerCount,
    required this.postCount,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json["id"],
      title: json["title"],
      subTitle: json["subTitle"],
      imageUrl: json["imageUrl"],
      thumbnailImageUrl: json["thumbnailImageUrl"],
      followerCount: json["followerCount"],
      postCount: json["postCount"],
    );
  }
}
