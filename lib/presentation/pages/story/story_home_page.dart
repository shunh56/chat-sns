import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/providers/tag_providers.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/usecases/story/get_stories_usecase.dart';
import 'package:app/presentation/pages/story/create_story_page.dart';
import 'package:app/presentation/pages/story/story_detail_page.dart';
import 'package:app/presentation/providers/tag/tag_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// タグに基づいてストーリーを取得するプロバイダー
final tagStoriesProvider =
    FutureProvider.family<List<Story>, String>((ref, tagId) async {
  return ref.watch(getStoriesUsecaseProvider).getStoriesByTag(tagId);
});

class StoryHomePage extends ConsumerStatefulWidget {
  final Tag? initialTag;

  const StoryHomePage({
    Key? key,
    this.initialTag,
  }) : super(key: key);

  @override
  ConsumerState<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends ConsumerState<StoryHomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  Tag? _selectedTag;
  bool _isTabControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.initialTag;

    // タグデータを読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagProvider.notifier).loadAllTags();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // タグが読み込まれた後にタブコントローラーを初期化（まだ初期化されていない場合のみ）
    final tags = ref.watch(tagProvider).tags;
    if (tags.isNotEmpty && !_isTabControllerInitialized) {
      final initialIndex = _selectedTag != null
          ? tags.indexWhere((tag) => tag.id == _selectedTag!.id)
          : 0;

      _tabController = TabController(
        length: tags.length,
        vsync: this,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      );

      // タブが変更された時にタグも更新
      _tabController?.addListener(() {
        if (_tabController != null && !_tabController!.indexIsChanging) {
          setState(() {
            _selectedTag = tags[_tabController!.index];
          });
        }
      });

      _isTabControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _navigateToCreateStory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateStoryPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) {
      // 戻ってきたときにタグデータを再読み込み
      ref.read(tagProvider.notifier).loadAllTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tagState = ref.watch(tagProvider);

    if (tagState.status == TagStatus.loading) {
      return _buildLoadingScaffold();
    }

    if (tagState.status == TagStatus.error) {
      // エラーの詳細はコンソールにのみ出力
      print('タグ読み込みエラー: ${tagState.errorMessage}');
      return _buildErrorScaffold(() {
        ref.read(tagProvider.notifier).loadAllTags();
      });
    }

    final tags = tagState.tags;

    if (tags.isEmpty) {
      return _buildEmptyScaffold(() {
        ref.read(tagProvider.notifier).loadAllTags();
      });
    }

    // タブコントローラーがnullの場合（まだ初期化されていない場合）
    if (_tabController == null) {
      return _buildLoadingScaffold();
    }

    // 初期化されていない場合はローディング表示
    if (_selectedTag == null && tags.isNotEmpty) {
      _selectedTag = tags.first;
    }

    // タブコントローラーの長さがタグの数と一致しない場合は更新
    if (_tabController != null && _tabController!.length != tags.length) {
      // 既存のコントローラーを破棄
      _tabController!.dispose();
      // 新しいコントローラーを作成
      _tabController = TabController(
        length: tags.length,
        vsync: this,
        initialIndex: 0,
      );
      _isTabControllerInitialized = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // カスタムヘッダー
            _buildHeader(tags),

            // タブバービュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tags.map((tag) => _StoryGridByTag(tag: tag)).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton(
          onPressed: _navigateToCreateStory,
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<Tag> tags) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // アプリバー
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ストーリー',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // タブバー
          Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "#${tag.name}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(VoidCallback onRetry) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'タグの読み込みに失敗しました',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScaffold(VoidCallback onRetry) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'タグがありません',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('再読み込み'),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateStoryPage(),
              ),
            );
          },
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

// タグごとのストーリーグリッド

class _StoryGridByTag extends ConsumerWidget {
  final Tag tag;

  const _StoryGridByTag({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(tagStoriesProvider(tag.id));

    return storiesAsync.when(
      data: (stories) {
        if (stories.isEmpty) {
          // 空の場合でもRefreshIndicatorを提供
          return RefreshIndicator(
            color: Colors.blue,
            backgroundColor: const Color(0xFF1E1E1E),
            onRefresh: () async {
              ref.refresh(tagStoriesProvider(tag.id));
            },
            child: ListView(
              // 物理スクロールを可能にする
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      'このタグのストーリーはまだありません',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // RefreshIndicatorでGridViewをラップ
        return RefreshIndicator(
          color: Colors.blue,
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            // リフレッシュ時にプロバイダーを更新
            ref.refresh(tagStoriesProvider(tag.id));
          },
          child: GridView.builder(
            // 物理スクロールを可能にする
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return _StoryGridItem(
                story: story,
                index: index,
                stories: stories,
              );
            },
          ),
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: Colors.blue)),
      error: (error, stackTrace) {
        // エラーの詳細をコンソールに出力
        print('ストーリー取得エラー: $error');
        print('スタックトレース: $stackTrace');

        // RefreshIndicatorを使用してエラー状態でも引っ張り更新を可能に
        return RefreshIndicator(
          color: Colors.blue,
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            // リフレッシュ時にプロバイダーを更新
            ref.refresh(tagStoriesProvider(tag.id));
          },
          child: ListView(
            // 物理スクロールを可能にする
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ストーリーの読み込みに失敗しました',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '下に引っ張って更新',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // 再読み込みのためにプロバイダーをリフレッシュ
                          ref.refresh(tagStoriesProvider(tag.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text('再試行'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ストーリーグリッドアイテム
class _StoryGridItem extends StatelessWidget {
  final Story story;
  final int index;
  final List<Story> stories;

  const _StoryGridItem({
    Key? key,
    required this.story,
    required this.index,
    required this.stories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ストーリー詳細ページに遷移（ページスライド効果付き）
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                StoryDetailPage(
                    story: story, allStories: stories, initialIndex: index),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutQuart;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: 'story-${story.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ストーリー画像
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.7, 1.0],
                  ),
                ),
                child: Image.network(
                  story.mediaUrl,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
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
                    return Container(
                      color: Colors.grey.shade800,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),

              // グラデーションオーバーレイ
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // インフォオーバーレイ（下部）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // いいね数とビュー数
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${story.likeCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${story.viewCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // キャプション（あれば表示）
                      if (story.caption != null && story.caption!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            story.caption!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 動画アイコン（もし動画の場合）
              if (story.mediaType == StoryMediaType.video)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

              // ハイライト表示（もしハイライトされている場合）
              if (story.isHighlighted)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ハイライト',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
