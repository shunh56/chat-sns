import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/chat_request.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/components/user_widget.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_ff_screen.dart';
import 'package:app/presentation/providers/chat_requests/received_requests_notifier.dart';
import 'package:app/presentation/providers/chat_requests/sent_requests_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatRequestListScreen extends HookConsumerWidget {
  const ChatRequestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final tabController = useTabController(initialLength: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "チャットリクエスト",
          style: textStyle.w600(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: ThemeColor.background,
      ),
      body: Column(
        children: [
          Container(
            color: ThemeColor.background,
            child: TabBar(
              controller: tabController,
              labelColor: ThemeColor.text,
              unselectedLabelColor: ThemeColor.subText,
              indicatorColor: ThemeColor.highlight,
              dividerColor: Colors.transparent,
              indicatorWeight: 0,
              indicator: GradientTabIndicator(
                colors: const [
                  ThemeColor.highlight,
                  Colors.cyan,
                ],
                weight: 2,
                width: themeSize.screenWidth / 2.4,
                radius: 8,
              ),
              tabs: [
                Tab(
                  child: SizedBox(
                    width: themeSize.screenWidth / 2.4,
                    child: Center(
                      child: Text(
                        "受信",
                        style: textStyle.w600(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: themeSize.screenWidth / 2.4,
                    child: Center(
                      child: Text(
                        "送信",
                        style: textStyle.w600(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                ReceivedRequestsList(),
                SentRequestsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 受信リクエスト一覧
class ReceivedRequestsList extends ConsumerWidget {
  const ReceivedRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(receivedRequestsNotifierProvider);

    return asyncValue.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: ThemeColor.subText.withOpacity(0.5),
                ),
                const Gap(16),
                Text(
                  "リクエストはありません",
                  style: textStyle.w400(
                    fontSize: 14,
                    color: ThemeColor.subText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return ReceivedRequestCard(request: requests[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(
        child: Text(
          'エラーが発生しました',
          style: TextStyle(color: ThemeColor.subText),
        ),
      ),
    );
  }
}

/// 受信リクエストカード
class ReceivedRequestCard extends ConsumerWidget {
  const ReceivedRequestCard({
    super.key,
    required this.request,
  });

  final ChatRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return UserWidget(
      userId: request.fromUserId,
      builder: (user) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserIcon(user: user, r: 32),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: textStyle.w600(fontSize: 17),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    request.createdAt.xxAgo,
                                    style: textStyle.w400(
                                      fontSize: 12,
                                      color: ThemeColor.subText,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(2),
                              Row(
                                children: [
                                  Icon(
                                    user.greenBadge
                                        ? Icons.verified
                                        : Icons.person_outline,
                                    size: 14,
                                    color: user.greenBadge
                                        ? Colors.green
                                        : ThemeColor.subText,
                                  ),
                                  const Gap(4),
                                  Text(
                                    user.badgeStatus,
                                    style: textStyle.w400(
                                      fontSize: 13,
                                      color: user.greenBadge
                                          ? Colors.green
                                          : ThemeColor.subText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (request.message != null) ...[
                      const Gap(14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ThemeColor.background.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ThemeColor.stroke.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          request.message!,
                          style: textStyle.w400(
                            fontSize: 14,
                            color: ThemeColor.text,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleReject(context, ref),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ThemeColor.text,
                              side: BorderSide(
                                color: ThemeColor.stroke.withOpacity(0.5),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.close, size: 18),
                                const Gap(4),
                                Text(
                                  '却下',
                                  style: textStyle.w600(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  ThemeColor.highlight,
                                  Colors.cyan,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeColor.highlight.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _handleAccept(context, ref, user.userId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, size: 18),
                                  const Gap(4),
                                  Text(
                                    '承認',
                                    style: textStyle.w600(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.accent,
        title: const Text('リクエストを却下'),
        content: const Text('このリクエストを却下しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('却下'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(receivedRequestsNotifierProvider.notifier)
            .rejectRequest(request);

        if (context.mounted) {
          showMessage('リクエストを却下しました');
        }
      } catch (e) {
        if (context.mounted) {
          showMessage('エラーが発生しました: $e');
        }
      }
    }
  }

  Future<void> _handleAccept(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    try {
      await ref
          .read(receivedRequestsNotifierProvider.notifier)
          .acceptRequest(request);

      if (context.mounted) {
        // チャット画面に遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChattingScreen(userId: userId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showMessage('エラーが発生しました: $e');
      }
    }
  }
}

/// 送信リクエスト一覧
class SentRequestsList extends ConsumerWidget {
  const SentRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(sentRequestsNotifierProvider);

    return asyncValue.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: ThemeColor.subText.withOpacity(0.5),
                ),
                const Gap(16),
                Text(
                  "送信したリクエストはありません",
                  style: textStyle.w400(
                    fontSize: 14,
                    color: ThemeColor.subText,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return SentRequestCard(request: requests[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const Center(
        child: Text(
          'エラーが発生しました',
          style: TextStyle(color: ThemeColor.subText),
        ),
      ),
    );
  }
}

/// 送信リクエストカード
class SentRequestCard extends ConsumerWidget {
  const SentRequestCard({
    super.key,
    required this.request,
  });

  final ChatRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    return UserWidget(
      userId: request.toUserId,
      builder: (user) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserIcon(user: user, r: 32),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: textStyle.w600(fontSize: 17),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                request.createdAt.xxAgo,
                                style: textStyle.w400(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeColor.highlight.withOpacity(0.2),
                                  Colors.cyan.withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ThemeColor.highlight.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.send,
                                  size: 12,
                                  color: ThemeColor.highlight,
                                ),
                                const Gap(4),
                                Text(
                                  '送信済み',
                                  style: textStyle.w600(
                                    fontSize: 12,
                                    color: ThemeColor.highlight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (request.message != null) ...[
                  const Gap(14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColor.background.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeColor.stroke.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      request.message!,
                      style: textStyle.w400(
                        fontSize: 14,
                        color: ThemeColor.text,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const Gap(14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _handleCancel(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(
                        color: Colors.red.shade400.withOpacity(0.4),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_outlined, size: 18),
                        const Gap(6),
                        Text(
                          'リクエストをキャンセル',
                          style: textStyle.w600(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColor.accent,
        title: const Text('リクエストをキャンセル'),
        content: const Text('このリクエストをキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(sentRequestsNotifierProvider.notifier)
            .cancelRequest(request);

        if (context.mounted) {
          showMessage('リクエストをキャンセルしました');
        }
      } catch (e) {
        if (context.mounted) {
          showMessage('エラーが発生しました: $e');
        }
      }
    }
  }
}
