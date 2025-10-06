import 'package:app/presentation/pages/search/sub_pages/search_params_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/core/utils/theme.dart';

/// タイムラインフィルターの状態
enum TimelineFilter { public, following }

/// タイムラインフィルターの状態を管理するプロバイダー
final timelineFilterProvider =
    StateProvider<TimelineFilter>((ref) => TimelineFilter.public);

/// タイムラインページのロゴヘッダーコンポーネント
class TimelineLogoHeader extends ConsumerWidget {
  const TimelineLogoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Stack(
        children: [
          // 中央のロゴ
          Center(
            child: SizedBox(
              height: 72,
              width: 72,
              child: SvgPicture.asset(
                'assets/images/icons/bg_transparent.svg',
              ),
            ),
          ),
          // 右側のアイコン群
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildActionIcons(),
          ),
        ],
      ),
    );
  }

  /// 右側のアクションアイコン群を構築
  Widget _buildActionIcons() {
    return Consumer(
      builder: (context, ref, child) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 検索アイコン
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchParamsScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.search_rounded,
                        color: ThemeColor.white.withOpacity(0.8),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              // フィルターアイコン
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _showFilterBottomSheet(context, ref);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// フィルター選択のボトムシートを表示
  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ドラッグハンドル
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),

              // タイトルセクション
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeColor.button.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: ThemeColor.button,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  const Text(
                    'タイムラインを絞り込み',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Gap(8),

              // サブタイトル
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '表示する投稿の種類を選択してください',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Gap(32),

              // フィルターオプション
              _buildModernFilterOption(
                context,
                ref,
                TimelineFilter.public,
                '全ての投稿',
                'すべてのユーザーの投稿を表示',
                Icons.public_rounded,
              ),
              const Gap(16),
              _buildModernFilterOption(
                context,
                ref,
                TimelineFilter.following,
                'フォロー中の投稿',
                'フォローしているユーザーの投稿のみ表示',
                Icons.people_rounded,
              ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  /// モダンなフィルターオプションカード
  Widget _buildModernFilterOption(
    BuildContext context,
    WidgetRef ref,
    TimelineFilter filter,
    String title,
    String description,
    IconData icon,
  ) {
    final currentFilter = ref.watch(timelineFilterProvider);
    final isSelected = currentFilter == filter;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeColor.button.withOpacity(0.1)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? ThemeColor.button.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(timelineFilterProvider.notifier).state = filter;
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // アイコン
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeColor.button.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? ThemeColor.button
                        : Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
                const Gap(16),

                // テキスト部分
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? ThemeColor.button : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // チェックアイコン
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ThemeColor.button,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
