import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/tag/user_tag.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:app/presentation/pages/user_tag/create_tag_page.dart';
import 'package:app/presentation/pages/user_tag/tag_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マイタグ一覧画面
class MyTagsPage extends HookConsumerWidget {
  const MyTagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: const Text('マイタグ'),
        backgroundColor: ThemeColor.background,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserTag>>(
        stream: usecase.watchMyTags(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTags = snapshot.data!;
          final systemTags =
              allTags.where((tag) => tag.isSystemTag).toList();
          final customTags =
              allTags.where((tag) => !tag.isSystemTag).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // システムタグ
                const Text(
                  'システムタグ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeColor.text,
                  ),
                ),
                const SizedBox(height: 12),
                ...systemTags.map((tag) => _TagCard(
                      tag: tag,
                      onTap: () => _navigateToTagDetail(context, tag),
                    )),

                const SizedBox(height: 24),

                // カスタムタグ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'カスタムタグ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeColor.text,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _navigateToCreateTag(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('作成'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (customTags.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'カスタムタグを作成して\n自分だけの整理方法を見つけよう',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeColor.subText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...customTags.map((tag) => _TagCard(
                        tag: tag,
                        onTap: () => _navigateToTagDetail(context, tag),
                      )),
              ],
            ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColor(tag.color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    tag.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // タグ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(
                          tag.priority,
                          (index) => const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${tag.userCount}人',
                          style: const TextStyle(
                            fontSize: 14,
                            color: ThemeColor.subText,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (tag.showInTimeline)
                          Row(
                            children: const [
                              Icon(Icons.visibility,
                                  size: 14, color: ThemeColor.subText),
                              SizedBox(width: 4),
                              Text(
                                'TL表示',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                        if (tag.enableNotifications)
                          Row(
                            children: const [
                              SizedBox(width: 8),
                              Icon(Icons.notifications_active,
                                  size: 14, color: ThemeColor.subText),
                              SizedBox(width: 4),
                              Text(
                                '通知ON',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ThemeColor.subText),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(
          int.parse(colorString.replaceFirst('#', '0xFF'), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
