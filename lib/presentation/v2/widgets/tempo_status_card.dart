import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants/tempo_colors.dart';
import '../constants/tempo_text_styles.dart';
import '../constants/tempo_spacing.dart';
import '../providers/tempo_status_provider.dart';
import '../pages/edit_status/edit_status_page.dart';

class TempoStatusCard extends ConsumerWidget {
  final bool isMyStatus;

  const TempoStatusCard({
    super.key,
    this.isMyStatus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(tempoStatusProvider);
    
    // ローディング中の場合
    if (statusState.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TempoSpacing.cardPadding),
        decoration: BoxDecoration(
          color: TempoColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: TempoColors.primary,
          ),
        ),
      );
    }

    // ステータスデータを取得
    final status = statusState.status;
    final location = status?.location.shortDisplayName ?? '';
    final activity = status?.status ?? '';
    final mood = status?.mood ?? '😊';
    final weather = status?.weather;

    // ステータスが設定されていない場合
    if (!isMyStatus && status == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TempoSpacing.cardPadding),
      decoration: BoxDecoration(
        // より控えめな背景色で情報を際立たせる
        gradient: isMyStatus
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TempoColors.primary.withOpacity(0.05),
                  TempoColors.secondary.withOpacity(0.03),
                ],
              )
            : null,
        color: isMyStatus ? null : TempoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isMyStatus
            ? Border.all(
                color: TempoColors.primary.withOpacity(0.2),
                width: 1.5,
              )
            : Border.all(
                color: TempoColors.textTertiary.withOpacity(0.1),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: (isMyStatus ? TempoColors.primary : Colors.black)
                .withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  mood,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
              Row(
                children: [
                  Text(
                    location,
                    style: TempoTextStyles.bodySmall.copyWith(
                      color: isMyStatus
                          ? Colors.white.withOpacity(0.8)
                          : TempoColors.textSecondary,
                    ),
                  ),
                  const Gap(8),
                  if (weather != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${weather.emoji} ${weather.temperatureDisplay}",
                        style: TempoTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: isMyStatus
                              ? Colors.white.withOpacity(0.8)
                              : TempoColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                activity.isNotEmpty ? activity : (isMyStatus ? 'ステータスを設定' : ''),
                style: TempoTextStyles.headline3.copyWith(
                  color: isMyStatus ? Colors.white : TempoColors.textPrimary,
                  fontStyle: activity.isEmpty && isMyStatus ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              if (activity.length > 10) ...[  // 長いステータスの場合は詳細表示
                const SizedBox(height: TempoSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TempoSpacing.md,
                    vertical: TempoSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isMyStatus
                        ? Colors.white.withOpacity(0.2)
                        : TempoColors.textTertiary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: isMyStatus
                            ? Colors.white.withOpacity(0.8)
                            : TempoColors.textTertiary,
                        size: 16,
                      ),
                      const SizedBox(width: TempoSpacing.sm),
                      Expanded(
                        child: Text(
                          activity,
                          style: TempoTextStyles.bodySmall.copyWith(
                            color: isMyStatus
                                ? Colors.white
                                : TempoColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isMyStatus)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditStatusPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(TempoSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
