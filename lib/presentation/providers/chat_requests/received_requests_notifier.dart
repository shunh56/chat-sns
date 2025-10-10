import 'package:app/domain/entity/chat_request.dart';
import 'package:app/domain/usecases/chat_request_usecase.dart';
import 'package:app/presentation/providers/shared/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receivedRequestsNotifierProvider = StateNotifierProvider<
    ReceivedRequestsNotifier, AsyncValue<List<ChatRequest>>>(
  (ref) => ReceivedRequestsNotifier(
    ref,
    ref.watch(chatRequestUsecaseProvider),
  )..init(),
);

class ReceivedRequestsNotifier
    extends StateNotifier<AsyncValue<List<ChatRequest>>> {
  ReceivedRequestsNotifier(
    this._ref,
    this._usecase,
  ) : super(const AsyncValue.loading());

  final Ref _ref;
  final ChatRequestUsecase _usecase;

  void init() {
    final stream = _usecase.streamReceivedRequests();
    final subscription = stream.listen((requests) async {
      // リクエスト送信者のユーザー情報をプリフェッチ
      if (requests.isNotEmpty) {
        await _ref.read(allUsersNotifierProvider.notifier).getUserAccounts(
              requests.map((req) => req.fromUserId).toList(),
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

  /// リクエストを承認
  Future<void> acceptRequest(ChatRequest request) async {
    try {
      await _usecase.acceptRequest(request.id);
    } catch (e) {
      rethrow;
    }
  }

  /// リクエストを却下
  Future<void> rejectRequest(ChatRequest request) async {
    try {
      await _usecase.rejectRequest(request.id);
    } catch (e) {
      rethrow;
    }
  }
}
