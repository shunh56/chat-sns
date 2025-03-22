// lib/utils/story_generator.dart

import 'dart:math';
import 'package:app/data/providers/story_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/repositories/story_repository.dart';
import 'package:app/data/providers/tag_providers.dart';

class StoryGenerator {
  final StoryRepository storyRepository;
  final List<Tag> availableTags;
  final List<String> userIds;

  StoryGenerator({
    required this.storyRepository,
    required this.availableTags,
    required this.userIds,
  });

  // ランダムな文字列を生成する関数
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // サンプルのキャプション一覧
  final List<String> _sampleCaptions = [
    '素敵な一日でした！',
    'このシーンが好きです',
    '新しい発見がありました',
    'みんなに共有したいと思いました',
    'こんな景色見たことない',
    '思い出に残る瞬間',
    'ハッピーな気分',
    'シンプルだけど意味のある瞬間',
    'こういう時間が大切',
    'また来たいな',
    'みんなはどう思う？',
    'いつもと違う視点',
    '何気ない日常',
    '心が落ち着く場所',
    'エネルギーをもらえる',
  ];

  // ランダムなストーリーを生成する関数
  Story _generateRandomStory(String userId) {
    final random = Random();
    const uuid = Uuid();
    final storyId = uuid.v4();
    
    // ランダムなシード値を生成
    final seed = _generateRandomString(8);
    
    // 画像URL
    final mediaUrl = 'https://picsum.photos/seed/$seed/500/400';
    
    // ランダムなキャプション (50%の確率でキャプションなし)
    final String? caption = random.nextBool() 
        ? _sampleCaptions[random.nextInt(_sampleCaptions.length)]
        : null;
    
    // ランダムなタグを1〜3個選択
    final tagCount = random.nextInt(3) + 1;
    final selectedTags = <String>[];
    
    if (availableTags.isNotEmpty) {
      for (int i = 0; i < tagCount; i++) {
        final tag = availableTags[random.nextInt(availableTags.length)];
        if (!selectedTags.contains(tag.id)) {
          selectedTags.add(tag.id);
        }
      }
    }
    
    // 現在時刻
    final now = Timestamp.now();
    
    // 有効期限 (24〜48時間)
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(Duration(hours: 24 + random.nextInt(24))),
    );
    
    // ランダムなビュー数・いいね数
    final viewCount = random.nextInt(100);
    final likeCount = random.nextInt(viewCount + 1); // ビュー数以下のいいね数
    
    return Story(
      id: storyId,
      userId: userId,
      mediaUrl: mediaUrl,
      caption: caption,
      mediaType: StoryMediaType.image,
      visibility: StoryVisibility.public,
      createdAt: now,
      expiresAt: expiresAt,
      viewCount: viewCount,
      likeCount: likeCount,
      tags: selectedTags,
      isHighlighted: random.nextDouble() < 0.2, // 20%の確率でハイライト
    );
  }

  // 指定した数だけストーリーをアップロードする関数
  Future<void> generateAndUploadStories(int count) async {
    if (userIds.isEmpty || availableTags.isEmpty) {
      throw Exception('ユーザーIDまたはタグが不足しています');
    }
    
    final random = Random();
    
    for (int i = 0; i < count; i++) {
      try {
        // ランダムなユーザーを選択
        final userId = userIds[random.nextInt(userIds.length)];
        
        // ランダムなストーリーを生成
        final story = _generateRandomStory(userId);
        
        // Firestoreに直接保存
        await FirebaseFirestore.instance
            .collection('stories')
            .doc(story.id)
            .set(story.toFirestore());
        
        // アップロード進捗をコンソールに出力
        print('ストーリーをアップロード: ${i + 1}/$count');
        
        // タグの使用回数を更新
        for (final tagId in story.tags) {
          await FirebaseFirestore.instance
              .collection('tags')
              .doc(tagId)
              .update({
                'usageCount': FieldValue.increment(1),
              });
        }
        
        // 連続アップロードによるレート制限を避けるための遅延
        if (i < count - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        print('ストーリーのアップロードに失敗: $e');
      }
    }
    
    print('$count件のストーリーを生成・アップロードしました');
  }
}

// Riverpodプロバイダー
final storyGeneratorProvider = Provider.autoDispose((ref) {
  final tags = ref.watch(tagProvider).tags;
  // ここでは例として固定のユーザーIDリストを使用
  // 実際の実装ではユーザーのリストを動的に取得する方法も考慮する
  final userIds = ['user123', 'user456', 'user789']; 
  
  return StoryGenerator(
    storyRepository: ref.watch(storyRepositoryProvider),
    availableTags: tags,
    userIds: userIds,
  );
});

// 50件のサンプルストーリーを生成・アップロードする関数
Future<void> generateSampleStories(WidgetRef ref) async {
  final generator = ref.read(storyGeneratorProvider);
  await generator.generateAndUploadStories(50);
}