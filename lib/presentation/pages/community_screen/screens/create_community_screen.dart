// lib/presentation/pages/community/screens/create_community_screen.dart

import 'dart:io';

import 'package:app/presentation/pages/community_screen/screens/create_community_state.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunityScreen extends ConsumerWidget {
  const CreateCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createCommunityNotifierProvider);
    final notifier = ref.read(createCommunityNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'コミュニティを作成',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                state.isLoading ? null : () => _handleSubmit(context, ref),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '作成',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThumbnailPicker(
              thumbnailFile: state.thumbnailFile,
            ),
            const SizedBox(height: 32),
            _InputField(
              label: 'コミュニティ名',
              hint: '50文字以内で入力してください',
              onChanged: notifier.updateName,
              maxLength: 50,
            ),
            const SizedBox(height: 24),
            _InputField(
              label: '説明',
              hint: 'コミュニティの説明を入力（200文字以内）',
              onChanged: notifier.updateDescription,
              maxLength: 200,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _TagInput(
              onTagAdded: notifier.addTag,
              tags: state.tags,
              onTagRemoved: notifier.removeTag,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(createCommunityNotifierProvider.notifier);
    try {
      await notifier.createCommunity();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final Function(String) onChanged;
  final int? maxLength;
  final int? maxLines;

  const _InputField({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailPicker extends ConsumerWidget {
  final File? thumbnailFile;

  const _ThumbnailPicker({
    required this.thumbnailFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(ref),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: thumbnailFile == null
              ? Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.grey[400],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.file(
                    thumbnailFile!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final image = await ref.read(imageProcessorNotifierProvider).getIconImage();
    if (image != null) {
      ref
          .read(createCommunityNotifierProvider.notifier)
          .updateThumbnailFile(File(image.path));
    }
  }
}

class _TagInput extends StatelessWidget {
  final Function(String) onTagAdded;
  final Function(String) onTagRemoved;
  final List<String> tags;

  const _TagInput({
    required this.onTagAdded,
    required this.onTagRemoved,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'タグ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onSubmitted: onTagAdded,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enterで追加',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.white.withOpacity(0.1),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white70,
                ),
                onDeleted: () => onTagRemoved(tag),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
