import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/pages/community_screen/provider/states/topic_state.dart';
import 'package:app/usecase/topics_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

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
                  Gap(24),
                  TextInput(),
                  Gap(24),
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
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "タイトル",
          style: textStyle.w600(
            fontSize: 16,
            color: ThemeColor.white,
          ),
        ),
        const Gap(8),
        TextFormField(
          initialValue: ref.watch(titleProvider),
          decoration: InputDecoration(
            hintText: 'トピックのタイトルを入力してください',
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            isDense: true,
            fillColor: ThemeColor.accent,
          ),
          maxLength: 32, // タイトルの最大文字数
          onChanged: (value) {
            if (value.isNotEmpty) {
              ref.read(titleProvider.notifier).state = value;
            } else {
              ref.read(titleProvider.notifier).state = null;
            }
          },
        ),
      ],
    );
  }
}

class TextInput extends ConsumerWidget {
  const TextInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "内容",
          style: textStyle.w600(
            fontSize: 16,
            color: ThemeColor.white,
          ),
        ),
        const Gap(8),
        TextField(
          minLines: 4,
          maxLines: 10,
          cursorColor: ThemeColor.text,
          style: textStyle.w600(),
          onChanged: (text) {
            if (text.isNotEmpty) {
              ref.read(textProvider.notifier).state = text;
            } else {
              ref.read(textProvider.notifier).state = null;
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            hintText: "ここで文章を入力",
            hintStyle: textStyle.w600(
              color: ThemeColor.subText,
            ),
            fillColor: ThemeColor.accent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _TagsInput extends ConsumerWidget {
  const _TagsInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tags = ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タグ',
          style: textStyle.w600(
            fontSize: 16,
            color: ThemeColor.white,
          ),
        ),
        Gap(8),
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
                backgroundColor: ThemeColor.accent,
                label: const Text('タグを追加'),
                onPressed: () => _showAddTagDialog(context, ref, tags),
              ),
          ],
        ),
        if (tags.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'タグを追加してトピックを見つけやすくしましょう',
              style: textStyle.w600(
                color: ThemeColor.subText,
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
            hintText: ' 例: テスト対策',
            prefixText: '#',
            hintStyle: TextStyle(
              color: ThemeColor.subText,
            ),
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
    final formattedTag = newTag; //newTag.startsWith('#') ? newTag : '#$newTag';
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
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: isReadyToUpload
              ? () async {
                  try {
                    ref.read(communityIdProvider.notifier).state = community.id;
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
            backgroundColor: isReadyToUpload ? Colors.blue : ThemeColor.stroke,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(
            'トピックを作成',
            style: textStyle.w600(
              fontSize: 16,
              color: ThemeColor.white,
            ),
          ),
        ),
      ),
    );
  }
}
