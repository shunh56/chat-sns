// models/community.dart
class Community {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<String> tags;
  final int memberCount;
  final String category;
  final bool isOfficial;
  final DateTime createdAt;
  final List<CommunityPost> recentPosts;
  final List<CommunityMember> topMembers;
  final String backgroundImageUrl;
  final List<String> rules;
  final Map<String, int> statistics;

  Community({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.tags,
    required this.memberCount,
    required this.category,
    required this.isOfficial,
    required this.createdAt,
    required this.recentPosts,
    required this.topMembers,
    required this.backgroundImageUrl,
    required this.rules,
    required this.statistics,
  });
}

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });
}

class CommunityMember {
  final String id;
  final String name;
  final String imageUrl;
  final String role;
  final bool isOnline;

  CommunityMember({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.role,
    required this.isOnline,
  });
}

// モックデータの拡張
final mockCommunityDetail = Community(
  id: "gaming-community",
  title: "ゲーム仲間募集中！",
  description:
      "ApexやValo、スプラ、原神など。フレンド募集から攻略情報まで、ゲーム好き集まれ！毎日アクティブなメンバーと一緒にゲームを楽しもう。初心者からプロまで、みんなで盛り上がれる空間です。",
  thumbnailUrl: "assets/images/community/gaming.jpeg",
  backgroundImageUrl: "https://picsum.photos/1200/400",
  tags: ["ゲーム好きと繋がりたい", "フレンド募集", "協力プレイ", "攻略"],
  memberCount: 234,
  category: "gaming",
  isOfficial: true,
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
  rules: [
    "誹謗中傷は禁止です",
    "個人情報の交換は控えめに",
    "楽しくゲームを楽しみましょう",
    "初心者への配慮をお願いします",
  ],
  statistics: {
    "今日の投稿数": 24,
    "今週のアクティブメンバー": 156,
    "先週比": 12,
  },
  recentPosts: [
    CommunityPost(
      id: "1",
      userId: "user1",
      userName: "ゲーマーA",
      userImageUrl: "https://picsum.photos/200/200?random=1",
      content: "今日のApexプラチナ帯、誰か一緒にやりませんか？",
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      likeCount: 12,
      commentCount: 5,
    ),
    CommunityPost(
      id: "2",
      userId: "user2",
      userName: "ゲーマーB",
      userImageUrl: "https://picsum.photos/200/200?random=2",
      content: "原神の新キャラの性能がやばい！皆さんどう思いますか？",
      imageUrl: "https://picsum.photos/400/300?random=3",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 34,
      commentCount: 12,
    ),
  ],
  topMembers: [
    CommunityMember(
      id: "mod1",
      name: "コミュニティリーダー",
      imageUrl: "https://picsum.photos/200/200?random=4",
      role: "管理者",
      isOnline: true,
    ),
    CommunityMember(
      id: "mod2",
      name: "サブリーダー",
      imageUrl: "https://picsum.photos/200/200?random=5",
      role: "モデレーター",
      isOnline: false,
    ),
  ],
);
