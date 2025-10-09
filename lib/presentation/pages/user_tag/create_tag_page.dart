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
    final isCreating = useState(false);

    return Scaffold(
      backgroundColor: ThemeColor.background,
      appBar: AppBar(
        title: const Text(
          '新しいタグを作成',
          style: TextStyle(color: ThemeColor.text),
        ),
        backgroundColor: ThemeColor.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeColor.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プレビューカード
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _parseColor(selectedColor.value).withOpacity(0.2),
                      _parseColor(selectedColor.value).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _parseColor(selectedColor.value).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _parseColor(selectedColor.value).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _parseColor(selectedColor.value)
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          selectedIcon.value,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nameController.text.isEmpty
                          ? 'タグ名を入力...'
                          : nameController.text,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: nameController.text.isEmpty
                            ? ThemeColor.textSecondary
                            : ThemeColor.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        selectedPriority.value,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // タグ名入力
            const _SectionHeader(title: 'タグ名', icon: Icons.edit),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              style: const TextStyle(
                fontSize: 16,
                color: ThemeColor.text,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: '例: ゲーム友達、学校の友達',
                hintStyle: const TextStyle(color: ThemeColor.textSecondary),
                filled: true,
                fillColor: ThemeColor.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: ThemeColor.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: ThemeColor.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: ThemeColor.primary, width: 2),
                ),
              ),
              maxLength: 20,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 28),

            // アイコン選択
            const _SectionHeader(title: 'アイコン', icon: Icons.emoji_emotions),
            const SizedBox(height: 12),
            _IconPicker(
              selectedIcon: selectedIcon.value,
              onSelected: (icon) => selectedIcon.value = icon,
              selectedColor: selectedColor.value,
            ),

            const SizedBox(height: 28),

            // カラー選択
            const _SectionHeader(title: 'カラー', icon: Icons.palette),
            const SizedBox(height: 12),
            _ColorPicker(
              selectedColor: selectedColor.value,
              onSelected: (color) => selectedColor.value = color,
            ),

            const SizedBox(height: 28),

            // 優先度選択
            const _SectionHeader(
              title: '優先度',
              icon: Icons.trending_up,
              subtitle: '数字が大きいほどリスト上位に表示されます',
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final priority = index + 1;
                final isSelected = selectedPriority.value == priority;
                return GestureDetector(
                  onTap: () => selectedPriority.value = priority,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _parseColor(selectedColor.value),
                                _parseColor(selectedColor.value)
                                    .withOpacity(0.7),
                              ],
                            )
                          : null,
                      color: isSelected ? null : ThemeColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _parseColor(selectedColor.value)
                            : ThemeColor.stroke,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _parseColor(selectedColor.value)
                                    .withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
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

            // 説明カード
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColor.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ThemeColor.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ThemeColor.primary,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'カスタムタグは自分だけが見ることができます。友達を自由に整理して、効率的なコミュニケーションを楽しみましょう。',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColor.text,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 作成ボタン
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isCreating.value
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('タグ名を入力してください'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                          return;
                        }

                        isCreating.value = true;
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
                                content: Row(
                                  children: [
                                    Text(
                                      selectedIcon.value,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${nameController.text} を作成しました'),
                                  ],
                                ),
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
                                content: Text('タグの作成に失敗しました: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        } finally {
                          isCreating.value = false;
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: ThemeColor.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isCreating.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'タグを作成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
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

/// セクションヘッダー
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ThemeColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: ThemeColor.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ThemeColor.text,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeColor.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// アイコンピッカー
class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selectedIcon,
    required this.onSelected,
    required this.selectedColor,
  });

  final String selectedIcon;
  final ValueChanged<String> onSelected;
  final String selectedColor;

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
    final color = _parseColor(selectedColor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColor.stroke),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: icons.map((icon) {
          final isSelected = selectedIcon == icon;
          return GestureDetector(
            onTap: () => onSelected(icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : ThemeColor.accent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
          );
        }).toList(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColor.stroke),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: colors.map((color) {
          final isSelected = selectedColor == color;
          final colorValue = _parseColor(color);
          return GestureDetector(
            onTap: () => onSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorValue,
                    colorValue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected ? Colors.white : colorValue.withOpacity(0.3),
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorValue.withOpacity(isSelected ? 0.4 : 0.2),
                    blurRadius: isSelected ? 12 : 6,
                    offset: Offset(0, isSelected ? 4 : 2),
                  ),
                ],
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                    )
                  : null,
            ),
          );
        }).toList(),
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
