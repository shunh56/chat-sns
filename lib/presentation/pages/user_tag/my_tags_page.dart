import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:app/presentation/pages/user_tag/create_tag_page.dart';
import 'package:app/presentation/pages/user_tag/tag_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マイタグ一覧画面
class MyTagsPage extends HookConsumerWidget {
  const MyTagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInitializing = useState(false);

    // 認証状態を確認
    UserTagUsecase? usecase;
    try {
      usecase = ref.watch(userTagUsecaseProvider);
    } catch (e) {
      return Scaffold(
        backgroundColor: ThemeColor.background,
        appBar: AppBar(
          title: const Text('マイタグ', style: TextStyle(color: ThemeColor.text)),
          backgroundColor: ThemeColor.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: ThemeColor.text),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: ThemeColor.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.label_outline,
                    size: 40,
                    color: ThemeColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ログインが必要です',
                  style: TextStyle(
                    color: ThemeColor.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'タグ機能を使用するには\nログインしてください',
                  style:
                      TextStyle(color: ThemeColor.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: const Text('マイタグ', style: TextStyle(color: ThemeColor.text)),
        backgroundColor: ThemeColor.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeColor.text),
      ),
      body: StreamBuilder<List<UserTag>>(
        stream: usecase!.watchMyTags(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTags = snapshot.data!;

          // 既存ユーザー対応: タグが空の場合は自動初期化
          if (allTags.isEmpty && !isInitializing.value) {
            isInitializing.value = true;
            Future.microtask(() async {
              try {
                await usecase!.initializeSystemTags();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('システムタグを初期化しました'),
                      backgroundColor: ThemeColor.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('タグの初期化に失敗しました: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } finally {
                isInitializing.value = false;
              }
            });
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeColor.primary),
                  SizedBox(height: 16),
                  Text(
                    'システムタグを初期化しています...',
                    style: TextStyle(color: ThemeColor.textSecondary),
                  ),
                ],
              ),
            );
          }

          final systemTags = allTags.where((tag) => tag.isSystemTag).toList();
          final customTags = allTags.where((tag) => !tag.isSystemTag).toList();

          return CustomScrollView(
            slivers: [
              // ヘッダー説明
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'タグで友達を整理して、快適なコミュニケーションを',
                    style: TextStyle(
                      color: ThemeColor.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // システムタグセクション
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: ThemeColor.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'システムタグ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TagCard(
                      tag: systemTags[index],
                      onTap: () =>
                          _navigateToTagDetail(context, systemTags[index]),
                    ),
                    childCount: systemTags.length,
                  ),
                ),
              ),

              // カスタムタグセクション
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ThemeColor.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'カスタムタグ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeColor.text,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: ThemeColor.primary,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => _navigateToCreateTag(context),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  '新規作成',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (customTags.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: ThemeColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColor.stroke,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: ThemeColor.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.label_outline,
                            size: 32,
                            color: ThemeColor.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'カスタムタグを作成',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeColor.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '自分だけの整理方法で\n友達を管理しましょう',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ThemeColor.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TagCard(
                        tag: customTags[index],
                        onTap: () =>
                            _navigateToTagDetail(context, customTags[index]),
                      ),
                      childCount: customTags.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToTagDetail(BuildContext context, UserTag tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TagDetailPage(tag: tag),
      ),
    );
  }

  void _navigateToCreateTag(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateTagPage(),
      ),
    );
  }
}

/// タグカード
class _TagCard extends StatelessWidget {
  const _TagCard({
    required this.tag,
    required this.onTap,
  });

  final UserTag tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = _parseColor(tag.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColor.stroke,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // アイコン
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tagColor.withOpacity(0.2),
                        tagColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: tagColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tag.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // タグ情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tag.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.text,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: tagColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${tag.userCount}人',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: tagColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (tag.priority > 0) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                tag.priority.clamp(0, 3),
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.amber.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (tag.showInTimeline || tag.enableNotifications) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (tag.showInTimeline)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      size: 10,
                                      color: ThemeColor.textSecondary,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'TL表示',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ThemeColor.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (tag.enableNotifications)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColor.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      size: 10,
                                      color: ThemeColor.textSecondary,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      '通知',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: ThemeColor.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ThemeColor.textSecondary.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
