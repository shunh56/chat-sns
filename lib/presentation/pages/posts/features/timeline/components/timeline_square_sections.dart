import 'package:app/presentation/pages/footprint/footprint_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:app/presentation/pages/activities/activities_screen.dart';
import 'package:app/presentation/pages/chat_request/chat_request_list_screen.dart';
import 'package:app/presentation/providers/activities_list_notifier.dart';
import 'package:app/presentation/providers/chat_requests/pending_request_count_provider.dart';
import 'package:app/presentation/providers/footprint/cached_recent_visitors_provider.dart';

/// タイムラインページのアクション通知セクション
///
/// ユーザーへのアクション情報（リクエスト・足あと・通知）を表示
/// 3つのカードを横並びで均等配置
class TimelineActionNotificationSection extends StatelessWidget {
  const TimelineActionNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          for (int cardIndex = 0; cardIndex < 3; cardIndex++) ...[
            Expanded(
                child: _ActionNotificationCard(
                    cardType: ActionNotificationType.values[cardIndex])),
            if (cardIndex < 2) const Gap(12),
          ],
        ],
      ),
    );
  }
}

/// アクション通知の種類
enum ActionNotificationType {
  requests, // リクエスト
  footprints, // 足あと
  notifications // 通知
}

/// 個別のアクション通知カード
class _ActionNotificationCard extends ConsumerWidget {
  const _ActionNotificationCard({required this.cardType});

  final ActionNotificationType cardType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleCardTap(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // アイコンとタイトル（上部）
                Row(
                  children: [
                    _buildIconForCardType(cardType),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        _getTitleForCardType(cardType),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // 件数（下部・左寄せ）
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _getCountForCardType(cardType, ref),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
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

  Widget _buildIconForCardType(ActionNotificationType cardType) {
    switch (cardType) {
      case ActionNotificationType.requests:
        return Icon(
          Icons.person_add_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 18,
        );
      case ActionNotificationType.footprints:
        return SvgPicture.asset(
          "assets/svg/footprint.svg",
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.7),
            BlendMode.srcIn,
          ),
        );
      case ActionNotificationType.notifications:
        return Icon(
          Icons.notifications_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 18,
        );
    }
  }

  String _getTitleForCardType(ActionNotificationType cardType) {
    switch (cardType) {
      case ActionNotificationType.requests:
        return 'リクエスト';
      case ActionNotificationType.footprints:
        return '足あと';
      case ActionNotificationType.notifications:
        return '通知';
    }
  }

  String _getCountForCardType(ActionNotificationType cardType, WidgetRef ref) {
    switch (cardType) {
      case ActionNotificationType.requests:
        final count = ref.watch(pendingRequestCountProvider);
        return count.toString();
      case ActionNotificationType.footprints:
        final count = ref.watch(safeRecentVisitorsCountProvider);
        return count.toString();
      case ActionNotificationType.notifications:
        final asyncValue = ref.watch(activitiesListNotifierProvider);
        return asyncValue.when(
          data: (activities) {
            final unreadCount = activities.where((item) => !item.isSeen).length;
            return unreadCount.toString();
          },
          loading: () => '-',
          error: (_, __) => '0',
        );
    }
  }

  void _handleCardTap(BuildContext context, WidgetRef ref) {
    switch (cardType) {
      case ActionNotificationType.requests:
        // リクエスト画面への遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ChatRequestListScreen(),
          ),
        );
        break;
      case ActionNotificationType.footprints:
        // 足あと画面への遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FootprintScreen(),
          ),
        );
        break;
      case ActionNotificationType.notifications:
        // 通知画面への遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ActivitiesScreen(),
          ),
        );
        break;
    }
  }
}
