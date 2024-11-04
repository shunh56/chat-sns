import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/provider/states/topic_state.dart';
import 'package:app/usecase/topics_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateTopicScreen extends ConsumerWidget {
  const CreateTopicScreen({super.key, required this.community});
  final Community community;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('トピックを作成'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _TitleInput(),
                  SizedBox(height: 24),
                  _TagsInput(),
                ],
              ),
            ),
            _CreateButton(community: community),
          ],
        ),
      ),
    );
  }
}

class _TitleInput extends ConsumerWidget {
  const _TitleInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タイトル',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: ref.watch(titleProvider),
          decoration: const InputDecoration(
            hintText: 'トピックのタイトルを入力してください',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLength: 50, // タイトルの最大文字数
          onChanged: (value) {
            ref.read(titleProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}

class _TagsInput extends ConsumerWidget {
  const _TagsInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タグ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map((tag) => Chip(
                  backgroundColor: ThemeColor.stroke,
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final newTags = List<String>.from(tags)..remove(tag);
                    ref.read(tagsProvider.notifier).state = newTags;
                  },
                )),
            if (tags.length < 5) // タグの最大数を制限
              InputChip(
                backgroundColor: ThemeColor.stroke,
                label: const Text('タグを追加'),
                onPressed: () => _showAddTagDialog(context, ref, tags),
              ),
          ],
        ),
        if (tags.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'タグを追加してトピックを見つけやすくしましょう',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showAddTagDialog(
    BuildContext context,
    WidgetRef ref,
    List<String> currentTags,
  ) async {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.background,
        title: const Text('タグを追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例: #テスト対策',
            prefixText: '#',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addTag(ref, currentTags, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTag(ref, currentTags, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _addTag(WidgetRef ref, List<String> currentTags, String newTag) {
    // #が付いていない場合は追加
    final formattedTag = newTag.startsWith('#') ? newTag : '#$newTag';
    if (!currentTags.contains(formattedTag)) {
      ref.read(tagsProvider.notifier).state = [...currentTags, formattedTag];
    }
  }
}

class _CreateButton extends ConsumerWidget {
  const _CreateButton({required this.community});
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final topicState = ref.watch(topicStateProvider);
    final isReadyToUpload = topicState.isReadyToUpload;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: isReadyToUpload
              ? () async {
                  try {
                    ref.read(communityIdProvider.notifier).state = community.id;
                    await Future.delayed(const Duration(milliseconds: 100));
                    final topic = ref.read(topicStateProvider);
                    ref.read(topicsUsecaseProvider).createTopic(topic);
                    showMessage("TOPIC CREATED!");
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('トピックの作成に失敗しました: ${e.toString()}'),
                      ),
                    );
                  }
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: ThemeColor.stroke,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            'トピックを作成',
            style: textStyle.w600(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
