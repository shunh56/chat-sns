import 'package:app/domain/entity/chat_request.dart';
import 'package:app/domain/usecases/chat_request_usecase.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sentRequestsNotifierProvider = StateNotifierProvider<
    SentRequestsNotifier, AsyncValue<List<ChatRequest>>>(
  (ref) => SentRequestsNotifier(
    ref,
    ref.watch(chatRequestUsecaseProvider),
  )..init(),
);

class SentRequestsNotifier
    extends StateNotifier<AsyncValue<List<ChatRequest>>> {
  SentRequestsNotifier(
    this._ref,
    this._usecase,
  ) : super(const AsyncValue.loading());

  final Ref _ref;
  final ChatRequestUsecase _usecase;

  void init() {
    final stream = _usecase.streamSentRequests();
    final subscription = stream.listen((requests) async {
      // リクエスト受信者のユーザー情報をプリフェッチ
      if (requests.isNotEmpty) {
        await _ref.read(allUsersNotifierProvider.notifier).getUserAccounts(
              requests.map((req) => req.toUserId).toList(),
            );
      }

      if (mounted) {
        state = AsyncValue.data(requests);
      }
    }, onError: (error, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
    });

    _ref.onDispose(subscription.cancel);
  }

  /// リクエストをキャンセル
  Future<void> cancelRequest(ChatRequest request) async {
    try {
      await _usecase.cancelRequest(request.id);
    } catch (e) {
      rethrow;
    }
  }
}
