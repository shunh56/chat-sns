import 'package:app/presentation/providers/chat_requests/received_requests_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 未読のチャットリクエスト数を提供するプロバイダー
final pendingRequestCountProvider = Provider<int>((ref) {
  final asyncValue = ref.watch(receivedRequestsNotifierProvider);

  return asyncValue.when(
    data: (requests) => requests.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
