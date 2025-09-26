import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../constants/tempo_colors.dart';
import '../../constants/tempo_text_styles.dart';
import '../../constants/tempo_spacing.dart';
import '../../providers/tempo_status_provider.dart';

class EditStatusPage extends HookConsumerWidget {
  const EditStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusController = useTextEditingController();
    final selectedMood = useState<String>('😊');

    final statusState = ref.watch(tempoStatusProvider);
    final statusNotifier = ref.read(tempoStatusProvider.notifier);

    // 初期値を設定
    useEffect(() {
      if (statusState.status != null) {
        statusController.text = statusState.status!.status;
        selectedMood.value = statusState.status!.mood.isNotEmpty
            ? statusState.status!.mood
            : '😊';
      }
      return null;
    }, [statusState.status]);

    final moods = [
      '😊',
      '😴',
      '🍔',
      '☕',
      '📚',
      '🎵',
      '🏃',
      '🎮',
      '😎',
      '🤔',
      '💻',
      '🎨',
      '🌟',
      '❤️',
      '🌈',
      '🔥'
    ];

    return Scaffold(
      backgroundColor: TempoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: TempoColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ステータス編集',
          style: TempoTextStyles.headline3.copyWith(
            color: TempoColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: statusState.isLoading
                ? null
                : () async {
                    try {
                      final status = statusController.text.trim();
                      debugPrint(
                          '保存処理開始: status="$status", mood="${selectedMood.value}"');

                      if (status.isNotEmpty) {
                        if (statusState.status == null) {
                          debugPrint('新規ステータス作成');
                          await statusNotifier.createStatus(
                            status: status,
                            mood: selectedMood.value,
                          );
                        } else {
                          debugPrint('既存ステータス更新');
                          await statusNotifier.updateStatus(
                            status: status,
                            mood: selectedMood.value,
                          );
                        }

                        // 少し待ってから状態をチェック
                        await Future.delayed(const Duration(milliseconds: 100));
                        final newStatusState = ref.read(tempoStatusProvider);

                        // エラーチェック
                        if (newStatusState.error != null) {
                          debugPrint('ステータス保存エラー: ${newStatusState.error}');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '保存に失敗しました: ${newStatusState.error}')),
                            );
                          }
                          return;
                        }

                        debugPrint('ステータス保存成功');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else {
                        debugPrint('ステータスが空のため保存をスキップ');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ステータスを入力してください')),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('保存処理でエラー: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('エラーが発生しました: $e')),
                        );
                      }
                    }
                  },
            child: Text(
              '保存',
              style: TempoTextStyles.buttonMedium.copyWith(
                color: TempoColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TempoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 気分選択
            _buildSection(
              title: '今の気分',
              child: Container(
                padding: const EdgeInsets.all(TempoSpacing.md),
                decoration: BoxDecoration(
                  color: TempoColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TempoColors.textTertiary.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    // 選択された気分の表示
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TempoColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          selectedMood.value,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: TempoSpacing.md),
                    // 気分選択グリッド
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: moods.length,
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final isSelected = selectedMood.value == mood;

                        return GestureDetector(
                          onTap: () => selectedMood.value = mood,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? TempoColors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? TempoColors.primary
                                    : TempoColors.textTertiary.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                mood,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TempoSpacing.xl),

            // ステータス入力
            _buildSection(
              title: '今の状況（20字以内）',
              child: _buildTextField(
                controller: statusController,
                hintText: '例: カフェでまったり、お家でのんびり、勉強中',
                prefixIcon: Icons.edit,
                maxLength: 20,
              ),
            ),

            const SizedBox(height: TempoSpacing.xl),

            // クリアボタン
            Center(
              child: TextButton(
                onPressed: statusState.isLoading
                    ? null
                    : () async {
                        statusController.clear();
                        selectedMood.value = '😊';
                        await statusNotifier.deleteStatus();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: Text(
                  'ステータスをクリア',
                  style: TempoTextStyles.buttonMedium.copyWith(
                    color: TempoColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TempoTextStyles.headline3.copyWith(
            color: TempoColors.textPrimary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: TempoSpacing.sm),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: TempoTextStyles.bodyMedium.copyWith(
        color: TempoColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TempoTextStyles.bodyMedium.copyWith(
          color: TempoColors.textTertiary,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: TempoColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: TempoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: TempoColors.textTertiary.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: TempoColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TempoSpacing.md,
          vertical: TempoSpacing.md,
        ),
      ),
    );
  }
}
