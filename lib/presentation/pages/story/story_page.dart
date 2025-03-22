// lib/presentation/pages/story/story_page.dart

import 'dart:io';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/usecases/story/delete_story_usecase.dart';
import 'package:app/domain/usecases/story/toggle_story_like_usecase.dart';
import 'package:app/domain/usecases/story/update_story_caption_usecase.dart';
import 'package:app/domain/usecases/story/upload_story_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 現在のユーザーIDを取得するプロバイダー（実際の認証システムに合わせて実装）
final currentUserProvider = Provider<String>((ref) => 'user123');

// ストーリーリストを取得するプロバイダー
final storiesProvider = StreamProvider<List<Story>>((ref) {
  return FirebaseFirestore.instance
      .collection('stories')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Story.fromFirestore(doc))
            .toList();
      });
});

class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({super.key});

  @override
  ConsumerState<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {
  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  
  // 編集モード用の変数
  String? _editingStoryId;
  
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
  
  // 画像選択
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
  // ストーリーアップロード
  Future<void> _uploadStory() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を選択してください')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final userId = ref.read(currentUserProvider);
      
      await ref.read(uploadStoryUsecaseProvider).execute(
        userId: userId,
        localMediaPath: _selectedImage!.path,
        caption: _captionController.text.trim(),
        mediaType: StoryMediaType.image,
        visibility: StoryVisibility.public,
        expirationDuration: const Duration(hours: 24),
      );
      
      // アップロード成功後、フォームをリセット
      setState(() {
        _selectedImage = null;
        _captionController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ストーリーがアップロードされました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アップロードエラー: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  // キャプション編集
  Future<void> _updateCaption(String storyId) async {
    setState(() {
      _isUploading = true;
    });
    
    try {
      final userId = ref.read(currentUserProvider);
      
      await ref.read(updateStoryCaptionUsecaseProvider).execute(
        storyId: storyId,
        userId: userId,
        newCaption: _captionController.text.trim(),
      );
      
      // 編集成功後、フォームをリセット
      setState(() {
        _editingStoryId = null;
        _captionController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('キャプションが更新されました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新エラー: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  
  // 編集モード開始
  void _startEditMode(Story story) {
    setState(() {
      _editingStoryId = story.id;
      _captionController.text = story.caption ?? '';
    });
    
    // 画面上部のフォーム部分にスクロール
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
      );
    });
  }
  
  // ストーリー削除
  Future<void> _deleteStory(String storyId) async {
    try {
      final userId = ref.read(currentUserProvider);
      
      await ref.read(deleteStoryUsecaseProvider).execute(
        storyId: storyId,
        userId: userId,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ストーリーが削除されました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除エラー: $e')),
      );
    }
  }
  
  // いいねの切り替え
  Future<void> _toggleLike(String storyId) async {
    try {
      final userId = ref.read(currentUserProvider);
      
      final isLiked = await ref.read(toggleStoryLikeUsecaseProvider).execute(
        storyId: storyId,
        userId: userId,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLiked ? 'いいねしました' : 'いいねを取り消しました'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider);
    final currentUserId = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ストーリー'),
        actions: [
          if (_editingStoryId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _editingStoryId = null;
                  _captionController.clear();
                });
              },
              child: const Text('キャンセル'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 投稿/編集フォーム部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editingStoryId == null ? 'ストーリーを投稿' : 'キャプションを編集',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 画像表示/選択部分（編集モードでなければ表示）
                if (_editingStoryId == null) ...[
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // キャプション入力
                TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    hintText: 'キャプションを入力...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  enabled: !_isUploading,
                ),
                const SizedBox(height: 12),
                
                // 投稿/更新ボタン
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                          if (_editingStoryId != null) {
                            _updateCaption(_editingStoryId!);
                          } else {
                            _uploadStory();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _editingStoryId != null ? '更新する' : '投稿する',
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // タブバー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'すべてのストーリー',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // ストーリーリスト
          Expanded(
            child: storiesAsync.when(
              data: (stories) {
                if (stories.isEmpty) {
                  return const Center(
                    child: Text('ストーリーがありません'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    final isCurrentUserStory = story.userId == currentUserId;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ストーリー画像
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: story.mediaUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              placeholder: (context, url) => Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                          
                          // アクションボタン
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // いいねボタン
                                IconButton(
                                  icon: Icon(
                                    story.likeCount > 0
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: story.likeCount > 0
                                        ? Colors.red
                                        : null,
                                  ),
                                  onPressed: () => _toggleLike(story.id),
                                  tooltip: 'いいね',
                                ),
                                
                                // いいね数
                                Text(
                                  '${story.likeCount}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                // 時間表示
                                Text(
                                  _formatTimestamp(story.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                
                                // 自分の投稿のみ表示するアクションボタン
                                if (isCurrentUserStory) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _startEditMode(story),
                                    tooltip: '編集',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _showDeleteConfirmation(story.id),
                                    tooltip: '削除',
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // キャプション
                          if (story.caption != null && story.caption!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(story.caption!),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('エラーが発生しました: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 削除確認ダイアログ
  Future<void> _showDeleteConfirmation(String storyId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ストーリーを削除'),
        content: const Text('この投稿を削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStory(storyId);
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  // タイムスタンプを表示用にフォーマット
  String _formatTimestamp(Timestamp timestamp) {
    final now = Timestamp.now();
    final difference = now.seconds - timestamp.seconds;
    
    if (difference < 60) {
      return '今';
    } else if (difference < 3600) {
      return '${(difference / 60).floor()}分前';
    } else if (difference < 86400) {
      return '${(difference / 3600).floor()}時間前';
    } else {
      final date = timestamp.toDate();
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}