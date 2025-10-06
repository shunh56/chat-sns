import 'package:app/core/utils/theme.dart';
import 'package:app/domain/usecases/user_tag_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// カスタムタグ作成画面
class CreateTagPage extends HookConsumerWidget {
  const CreateTagPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.watch(userTagUsecaseProvider);
    final nameController = useTextEditingController();
    final selectedIcon = useState('✨');
    final selectedColor = useState('#9370DB');
    final selectedPriority = useState(3);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: const Text('新しいタグを作成'),
        backgroundColor: ThemeColor.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('タグ名を入力してください')),
                );
                return;
              }

              try {
                await usecase.createCustomTag(
                  name: nameController.text.trim(),
                  icon: selectedIcon.value,
                  color: selectedColor.value,
                  priority: selectedPriority.value,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${selectedIcon.value} ${nameController.text} を作成しました')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('タグの作成に失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text(
              '作成',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プレビュー
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _parseColor(selectedColor.value).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      selectedIcon.value,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nameController.text.isEmpty
                          ? 'タグ名'
                          : nameController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        selectedPriority.value,
                        (index) => const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // タグ名
            const Text(
              'タグ名',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: '例: ゲーム友達',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLength: 20,
            ),

            const SizedBox(height: 24),

            // アイコン選択
            const Text(
              'アイコン',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _IconPicker(
              selectedIcon: selectedIcon.value,
              onSelected: (icon) => selectedIcon.value = icon,
            ),

            const SizedBox(height: 24),

            // カラー選択
            const Text(
              'カラー',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _ColorPicker(
              selectedColor: selectedColor.value,
              onSelected: (color) => selectedColor.value = color,
            ),

            const SizedBox(height: 24),

            // 優先度選択
            const Text(
              '優先度 (高いほどリスト上位)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final priority = index + 1;
                final isSelected = selectedPriority.value == priority;
                return GestureDetector(
                  onTap: () => selectedPriority.value = priority,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$priority',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : ThemeColor.text,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // 説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'カスタムタグを使って、自分だけの人間関係マップを作成できます。'
                'タグは自分にしか見えないので、自由に整理しましょう。',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColor.text,
                ),
              ),
            ),
          ],
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

/// アイコンピッカー
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedIcon,
    required this.onSelected,
  });

  final String selectedIcon;
  final ValueChanged<String> onSelected;

  static const icons = [
    '✨',
    '⭐',
    '❤️',
    '💕',
    '💙',
    '💚',
    '💜',
    '🧡',
    '🎮',
    '🎸',
    '⚽',
    '🎨',
    '📚',
    '💼',
    '🍕',
    '☕',
    '✈️',
    '🏠',
    '🎬',
    '🎵',
    '🌟',
    '🔥',
    '💎',
    '🎯',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: icons.map((icon) {
          final isSelected = selectedIcon == icon;
          return GestureDetector(
            onTap: () => onSelected(icon),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// カラーピッカー
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.selectedColor,
    required this.onSelected,
  });

  final String selectedColor;
  final ValueChanged<String> onSelected;

  static const colors = [
    '#9370DB', // 紫
    '#FFD700', // 金
    '#90EE90', // 緑
    '#4682B4', // 青
    '#87CEEB', // 水色
    '#FF69B4', // ピンク
    '#FF6347', // 赤
    '#FFA500', // オレンジ
    '#32CD32', // ライム
    '#8B4513', // 茶色
    '#696969', // グレー
    '#000000', // 黒
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors.map((color) {
          final isSelected = selectedColor == color;
          return GestureDetector(
            onTap: () => onSelected(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _parseColor(color),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.white,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
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
