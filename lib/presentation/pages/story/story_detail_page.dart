import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/usecases/story/toggle_story_like_usecase.dart';
import 'package:app/domain/usecases/tag/get_tags_usecase.dart';
import 'package:app/presentation/pages/story/story_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryDetailPage extends ConsumerStatefulWidget {
  final Story story;
  final List<Story> allStories;
  final int initialIndex;

  const StoryDetailPage({
    Key? key,
    required this.story,
    required this.allStories,
    required this.initialIndex,
  }) : super(key: key);

  @override
  ConsumerState<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends ConsumerState<StoryDetailPage> {
  late PageController _pageController;
  late int _currentIndex;
  late List<Story> _stories;
  bool _isLiking = false;
  bool _userInteracting = false;

  // アニメーションや視覚効果のための変数
  double _progressValue = 0.0;
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    _stories = widget.allStories;
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    
    // システムのUIを非表示にする（フルスクリーン体験）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // ストーリーの閲覧を記録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordView(_stories[_currentIndex]);
      
      // 自動的にコントロールを隠す
      Future.delayed(Duration(seconds: 3), () {
        if (!_userInteracting && mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // システムのUIを元に戻す
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  // ストーリーの閲覧を記録
  Future<void> _recordView(Story story) async {
    final currentUserId = ref.read(currentUserProvider);
    try {
      DebugPrint("VIEW STORY USECASE mark as Story as viewed");
      /*await ref.read(viewStoryUsecaseProvider).markStoryAsViewed(
        story.id,
        currentUserId,
      ); */
      
      // ビュー数を更新（UI更新のためだけ）
      final index = _stories.indexWhere((s) => s.id == story.id);
      if (index != -1) {
        setState(() {
          _stories[index] = _stories[index].copyWith(
            viewCount: _stories[index].viewCount + 1
          );
        });
      }
    } catch (e) {
      print('Failed to record view: $e');
    }
  }

  // いいねを切り替え
  Future<void> _toggleLike(Story story) async {
    if (_isLiking) return;
    
    setState(() {
      _isLiking = true;
    });
    
    try {
      final currentUserId = ref.read(currentUserProvider);
      final isLiked = await ref.read(toggleStoryLikeUsecaseProvider).execute(
        storyId: story.id,
        userId: currentUserId,
      );
      
      // いいね状態とカウントを更新
      final index = _stories.indexWhere((s) => s.id == story.id);
      if (index != -1) {
        setState(() {
          _stories[index] = _stories[index].copyWith(
            likeCount: isLiked 
                ? _stories[index].likeCount + 1 
                : _stories[index].likeCount - 1,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $e')),
      );
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  // 画面タップでコントロールの表示・非表示を切り替え
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  // スワイプでページ切り替え時の処理
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _progressValue = index / (_stories.length - 1);
    });
    _recordView(_stories[index]);
  }

  // スライダーでの手動ページ移動
  void _onProgressChanged(double value) {
    setState(() {
      _progressValue = value;
    });
    final targetIndex = (value * (_stories.length - 1)).round();
    _pageController.jumpToPage(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final currentStory = _stories[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onLongPress: () {
          setState(() {
            _userInteracting = true;
          });
        },
        onLongPressEnd: (details) {
          setState(() {
            _userInteracting = false;
            
            // 3秒後にコントロールを自動的に隠す
            Future.delayed(Duration(seconds: 3), () {
              if (!_userInteracting && mounted) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          });
        },
        child: Stack(
          children: [
            // ストーリーの画像・コンテンツ
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final story = _stories[index];
                return _StoryContent(
                  story: story,
                  onDoubleTap: () => _toggleLike(story),
                );
              },
            ),
            
            // オーバーレイUI（上部）
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 上部のヘッダー
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // 戻るボタン
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            
                            Expanded(
                              child: Slider(
                                value: _progressValue,
                                onChanged: _onProgressChanged,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            
                            // ストーリー数表示
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_currentIndex + 1}/${_stories.length}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // タグリストをここに表示
                      if (currentStory.tags.isNotEmpty)
                        Container(
                          height: 36,
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: currentStory.tags.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: FutureBuilder<Tag?>(
                                  future: ref.read(getTagsUsecaseProvider).getTagById(
                                    currentStory.tags[index]
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return SizedBox.shrink();
                                    }
                                    
                                    final tag = snapshot.data!;
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        "#${tag.name}",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // オーバーレイUI（下部）
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // キャプション
                          if (currentStory.caption != null && currentStory.caption!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                currentStory.caption!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // インタラクションボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // いいねボタン
                              _InteractionButton(
                                icon: currentStory.likeCount > 0 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                label: '${currentStory.likeCount}',
                                color: currentStory.likeCount > 0 ? Colors.red : Colors.white,
                                onTap: () => _toggleLike(currentStory),
                                isLoading: _isLiking,
                              ),
                              
                              // コメントボタン
                              _InteractionButton(
                                icon: Icons.chat_bubble_outline,
                                label: 'コメント',
                                onTap: () {
                                  // コメント機能の実装
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('コメント機能は実装中です')),
                                  );
                                },
                              ),
                              
                              // シェアボタン
                              _InteractionButton(
                                icon: Icons.share,
                                label: 'シェア',
                                onTap: () {
                                  // シェア機能の実装
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('シェア機能は実装中です')),
                                  );
                                },
                              ),
                              
                              // ビュー数表示
                              _InteractionButton(
                                icon: Icons.visibility,
                                label: '${currentStory.viewCount}',
                                onTap: null, // タップアクションなし（表示のみ）
                              ),
                            ],
                          ),
                          
                          // 場所情報（あれば表示）
                          if (currentStory.location != null && currentStory.location!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    currentStory.location!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          // スワイプアップインジケーター
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    'スワイプして次のストーリー',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // サイドメニュー（右側）- TikTokスタイル
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SideActionButton(
                        icon: Icons.favorite,
                        count: currentStory.likeCount.toString(),
                        onTap: () => _toggleLike(currentStory),
                        isActive: currentStory.likeCount > 0,
                      ),
                      SizedBox(height:
  16),
                      _SideActionButton(
                        icon: Icons.chat_bubble,
                        count: '0',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('コメント機能は実装中です')),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _SideActionButton(
                        icon: Icons.bookmark,
                        count: currentStory.isHighlighted ? 'ブックマーク中' : '',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ブックマーク機能は実装中です')),
                          );
                        },
                        isActive: currentStory.isHighlighted,
                      ),
                      SizedBox(height: 16),
                      _SideActionButton(
                        icon: Icons.share,
                        count: '',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('シェア機能は実装中です')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ストーリーのコンテンツを表示するウィジェット
class _StoryContent extends StatefulWidget {
  final Story story;
  final VoidCallback onDoubleTap;

  const _StoryContent({
    Key? key,
    required this.story,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  State<_StoryContent> createState() => _StoryContentState();
}

class _StoryContentState extends State<_StoryContent> with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimController;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showHeart = false;
        });
        _heartAnimController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      _showHeart = true;
    });
    _heartAnimController.forward();
    widget.onDoubleTap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ストーリー画像
        Hero(
          tag: 'story-${widget.story.id}',
          child: GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 3.0,
              child: Container(
                color: Colors.black,
                child: Image.network(
                  widget.story.mediaUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.blue,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '画像を読み込めませんでした',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        
        // 動画の場合は再生ボタンを表示
        if (widget.story.mediaType == StoryMediaType.video)
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        
        // いいねハートアニメーション
        if (_showHeart)
          Center(
            child: AnimatedBuilder(
              animation: _heartAnimController,
              builder: (context, child) {
                return Transform.scale(
                  scale: Tween<double>(begin: 0.8, end: 1.5)
                      .chain(CurveTween(curve: Curves.elasticOut))
                      .evaluate(_heartAnimController),
                  child: Opacity(
                    opacity: Tween<double>(begin: 1.0, end: 0.0)
                        .animate(CurvedAnimation(
                          parent: _heartAnimController,
                          curve: Interval(0.5, 1.0),
                        ))
                        .value,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// インタラクションボタン（いいね、コメント、シェアなど）
class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _InteractionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.color = Colors.white,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                  ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// サイドメニューボタン（TikTokスタイル）
class _SideActionButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;
  final bool isActive;

  const _SideActionButton({
    Key? key,
    required this.icon,
    required this.count,
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
        ),
        if (count.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}