import 'dart:io';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/providers/tag_providers.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/usecases/story/upload_story_usecase.dart';
import 'package:app/presentation/pages/story/story_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateStoryPage extends ConsumerStatefulWidget {
  const CreateStoryPage({super.key});

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  final List<Tag> _selectedTags = [];
  bool _isEditing = false;
  late TabController _tabController;
  
  // フィルター効果のためのパラメータ
  double _brightness = 0.0;
  double _contrast = 0.0;
  double _saturation = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // システムUIを設定
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // タグをロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tagProvider.notifier).loadAllTags();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tabController.dispose();
    // システムUIを元に戻す
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  // 画像選択
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isEditing = true;
      });
    }
  }
  
  // カメラで撮影
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isEditing = true;
      });
    }
  }

  // タグ選択ボトムシートを表示
  Future<void> _showTagSelectionBottomSheet() async {
    final tags = ref.read(tagProvider).tags;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ドラッグハンドル
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // タイトル
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'タグを選択',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '完了',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 検索バー
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'タグを検索...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  
                  // タグリスト
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        final isSelected = _selectedTags.any((t) => t.id == tag.id);
                        
                        return ListTile(
                          title: Text(
                            '#${tag.name}',
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: tag.description != null && tag.description!.isNotEmpty
                              ? Text(
                                  tag.description!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.blue)
                              : const Icon(Icons.add_circle_outline, color: Colors.grey),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _selectedTags.removeWhere((t) => t.id == tag.id);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                            setState(() {});  // メイン画面も更新
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ストーリーをアップロード
  Future<void> _uploadStory() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('画像を選択してください');
      return;
    }

    if (_selectedTags.isEmpty) {
      _showErrorSnackBar('少なくとも1つのタグを選択してください');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = ref.read(currentUserProvider);
      final tagIds = _selectedTags.map((tag) => tag.id).toList();

      await ref.read(uploadStoryUsecaseProvider).execute(
            userId: userId,
            localMediaPath: _selectedImage!.path,
            caption: _captionController.text.trim(),
            mediaType: StoryMediaType.image,
            visibility: StoryVisibility.public,
            tags: tagIds,
          );

      // タグの使用回数を増加
      for (final tag in _selectedTags) {
        await ref.read(tagProvider.notifier).useTag(tag);
      }

      // アップロード成功、前の画面に戻る
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ストーリーをアップロードしました'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      _showErrorSnackBar('アップロードエラー: $e');
    }
  }
  
  // エラースナックバーを表示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: GestureDetector(
        onTap: () {
          primaryFocus?.unfocus();
        },
        child: SafeArea(
          child: _selectedImage == null 
              ? _buildImageSelectionScreen()
              : _isEditing 
                  ? _buildEditingScreen(screenSize)
                  : _buildCaptionScreen(textStyle),
        ),
      ),
    );
  }
  
  // 画像選択画面
  Widget _buildImageSelectionScreen() {
    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '新しいストーリー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // バランスを取るためのスペーサー
            ],
          ),
        ),
        
        // メイン選択エリア
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ギャラリーから選択ボタン
              _buildSelectionButton(
                icon: Icons.photo_library,
                label: 'ギャラリーから選択',
                onTap: _pickImage,
              ),
              const SizedBox(height: 24),
              
              // カメラで撮影ボタン
              _buildSelectionButton(
                icon: Icons.camera_alt,
                label: 'カメラで撮影',
                onTap: _takePicture,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 画像編集画面
  Widget _buildEditingScreen(Size screenSize) {
    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
              const Text(
                '画像を編集',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                child: const Text(
                  '次へ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 画像プレビュー
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix([
                1 + _contrast / 10, 0, 0, 0, _brightness * 25.5,
                0, 1 + _contrast / 10, 0, 0, _brightness * 25.5,
                0, 0, 1 + _contrast / 10, 0, _brightness * 25.5,
                0, 0, 0, 1, 0,
              ]),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        
        // 編集ツール
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // タブバー
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'フィルター'),
                  Tab(text: '調整'),
                ],
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
              ),
              
              // タブコンテンツ
              SizedBox(
                height: 160,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // フィルタータブ
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterOption('オリジナル'),
                          _buildFilterOption('モノクロ'),
                          _buildFilterOption('セピア'),
                          _buildFilterOption('ビンテージ'),
                          _buildFilterOption('クラシック'),
                          _buildFilterOption('ドラマ'),
                        ],
                      ),
                    ),
                    
                    // 調整タブ
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          // 明るさ調整
                          Row(
                            children: [
                              const Icon(Icons.brightness_6, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text('明るさ', style: TextStyle(color: Colors.white)),
                              Expanded(
                                child: Slider(
                                  value: _brightness,
                                  min: -1.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _brightness = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          
                          // コントラスト調整
                          Row(
                            children: [
                              const Icon(Icons.contrast, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text('コントラスト', style: TextStyle(color: Colors.white)),
                              Expanded(
                                child: Slider(
                                  value: _contrast,
                                  min: -1.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _contrast = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          
                          // 彩度調整
                          Row(
                            children: [
                              const Icon(Icons.color_lens, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text('彩度', style: TextStyle(color: Colors.white)),
                              Expanded(
                                child: Slider(
                                  value: _saturation,
                                  min: -1.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    setState(() {
                                      _saturation = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // キャプション入力画面
  Widget _buildCaptionScreen(ThemeTextStyle textStyle) {
    return Column(
      children: [
        // ヘッダー
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              const Text(
                '新しいストーリー',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : TextButton(
                      onPressed: _uploadStory,
                      child: const Text(
                        '投稿',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        
        // メインコンテンツ
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // コンテンツプレビュー
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 画像サムネイル
                    Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // キャプション入力
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'キャプション',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _captionController,
                            decoration: InputDecoration(
                              hintText: 'キャプションを入力...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 5,
                            maxLength: 200,
                            enabled: !_isUploading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // タグセクション
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'タグ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _showTagSelectionBottomSheet,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('タグを選択'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 選択されたタグの表示
                _selectedTags.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'タグが選択されていません',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "#${tag.name}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: _isUploading
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedTags.removeWhere(
                                                (t) => t.id == tag.id);
                                          });
                                        },
                                  child: Icon(
                                    Icons.cancel,
                                    size: 16,
                                    color: Colors.blue.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                
                const SizedBox(height: 24),
                
                // 公開範囲セクション
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '公開範囲',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildVisibilityOption(
                        Icons.public, 
                        'すべてのユーザー', 
                        '誰でも閲覧可能', 
                        true
                      ),
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      _buildVisibilityOption(
                        Icons.people, 
                        'フォロワーのみ', 
                        'フォロワーのみ閲覧可能', 
                        false
                      ),
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      _buildVisibilityOption(
                        Icons.lock, 
                        '親しい友人のみ', 
                        '選択した友人のみ閲覧可能', 
                        false
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 選択ボタンウィジェット
  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // フィルターオプションウィジェット
  Widget _buildFilterOption(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: name == 'オリジナル' ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: name == 'オリジナル' ? Colors.blue : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  // 公開範囲オプションウィジェット
  Widget _buildVisibilityOption(
    IconData icon, 
    String title, 
    String subtitle, 
    bool isSelected
  ) {
    return InkWell(
      onTap: () {
        // 公開範囲選択の実装
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}